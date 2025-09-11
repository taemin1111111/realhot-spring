package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Hpost;
import com.wherehot.spring.entity.Course;
import com.wherehot.spring.entity.CourseStep;
import com.wherehot.spring.entity.Notification;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.AdminService;
import com.wherehot.spring.service.HpostService;
import com.wherehot.spring.service.CourseService;
import com.wherehot.spring.service.NotificationService;
import com.wherehot.spring.service.MemberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 관리자 페이지 컨트롤러
 * index.jsp에 include되는 구조
 */
@Controller
@RequestMapping("/admin")
public class AdminController {
    
    @Autowired
    private AdminService adminService;
    
    @Autowired
    private HpostService hpostService;
    
    @Autowired
    private CourseService courseService;
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private MemberService memberService;
    
    @Value("${app.upload.dir:}")
    private String uploadPath;
    
    /**
     * 핫플썰 관리 페이지
     */
    @GetMapping("/hpost")
    public String hpostAdmin(Model model) {
        model.addAttribute("mainPage", "adminpage/hpostadmin.jsp");
        return "index";
    }
    
    /**
     * 코스 관리 페이지
     */
    @GetMapping("/course")
    public String courseAdmin(Model model) {
        model.addAttribute("mainPage", "adminpage/courseadmin.jsp");
        return "index";
    }
    
    /**
     * 신고된 코스 목록 조회 (신고 개수 순)
     */
    @GetMapping("/course/reports/count")
    @ResponseBody
    public List<Map<String, Object>> getReportedCoursesByCount() {
        return adminService.getReportedCoursesByReportCount();
    }
    
    /**
     * 신고된 코스 목록 조회 (최신 신고 순)
     */
    @GetMapping("/course/reports/latest")
    @ResponseBody
    public List<Map<String, Object>> getReportedCoursesByLatest() {
        return adminService.getReportedCoursesByLatestReport();
    }
    
    /**
     * 특정 코스의 신고 상세 정보 조회
     */
    @GetMapping("/course/reports/details")
    @ResponseBody
    public List<Map<String, Object>> getCourseReportDetails(@RequestParam int courseId) {
        if (courseId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 코스 ID입니다: " + courseId);
        }
        return adminService.getCourseReportDetailsByCourseId(courseId);
    }
    
    /**
     * 관리자용 코스 삭제 (비밀번호 불필요)
     */
    @DeleteMapping("/course/{id}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteCourseByAdmin(@PathVariable int id) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 코스 조회
            Course course = courseService.getCourseById(id);
            if (course == null) {
                response.put("success", false);
                response.put("message", "코스를 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 알림 전송 (삭제 전에 실행)
            sendCourseDeleteNotifications(course);
            
            // 신고 데이터 삭제 (알림 전송 후)
            adminService.deleteCourseReportsByCourseId(id);
            
            // 코스 삭제 (연관된 데이터도 함께 삭제)
            boolean deleteResult = adminService.deleteCourseWithAllRelatedData(id);
            
            if (deleteResult) {
                // 파일 삭제
                deleteCourseFiles(course);
                
                response.put("success", true);
                response.put("message", "코스가 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "코스 삭제에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "코스 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * MD 관리 페이지
     */
    @GetMapping("/md")
    public String mdAdmin(Model model) {
        model.addAttribute("mainPage", "adminpage/mdadmin.jsp");
        return "index";
    }
    
    /**
     * 신고된 게시물 목록 조회 (신고 개수 순)
     */
    @GetMapping("/reports/count")
    @ResponseBody
    public List<Map<String, Object>> getReportedPostsByCount() {
        return adminService.getReportedPostsByReportCount();
    }
    
    /**
     * 신고된 게시물 목록 조회 (최신 신고 순)
     */
    @GetMapping("/reports/latest")
    @ResponseBody
    public List<Map<String, Object>> getReportedPostsByLatest() {
        return adminService.getReportedPostsByLatestReport();
    }
    
    /**
     * 특정 게시물의 신고 상세 정보 조회
     */
    @GetMapping("/reports/details")
    @ResponseBody
    public List<Map<String, Object>> getReportDetails(@RequestParam(required = true) Integer postId) {
        if (postId == null || postId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 게시물 ID입니다: " + postId);
        }
        return adminService.getReportDetailsByPostId(postId);
    }
    
    /**
     * 관리자용 게시물 삭제 (비밀번호 불필요)
     */
    @DeleteMapping("/hpost/{id}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteHpostByAdmin(@PathVariable int id) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 게시글 조회 (조회수 증가 없음)
            Hpost hpost = hpostService.getHpostByIdWithoutIncrement(id);
            if (hpost == null) {
                response.put("success", false);
                response.put("message", "게시글을 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 알림 전송 (삭제 전에 실행)
            sendDeleteNotifications(hpost);
            
            // 신고 데이터 삭제 (알림 전송 후)
            adminService.deleteReportsByPostId(id);
            
            // 게시글 삭제 (연관된 데이터도 함께 삭제)
            boolean deleteResult = adminService.deleteHpostWithAllRelatedData(id);
            
            if (deleteResult) {
                // 파일 삭제
                deleteHpostFiles(hpost);
                
                response.put("success", true);
                response.put("message", "게시글이 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "게시글 삭제에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "게시글 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 게시글 관련 파일 삭제
     */
    private void deleteHpostFiles(Hpost hpost) {
        try {
            if (uploadPath != null && !uploadPath.isEmpty()) {
                // photo1 삭제
                if (hpost.getPhoto1() != null && !hpost.getPhoto1().trim().isEmpty()) {
                    File photo1File = new File(uploadPath + "/hpostsave/" + hpost.getPhoto1());
                    if (photo1File.exists()) {
                        photo1File.delete();
                        System.out.println("파일 삭제 완료: " + hpost.getPhoto1());
                    }
                }
                
                // photo2 삭제
                if (hpost.getPhoto2() != null && !hpost.getPhoto2().trim().isEmpty()) {
                    File photo2File = new File(uploadPath + "/hpostsave/" + hpost.getPhoto2());
                    if (photo2File.exists()) {
                        photo2File.delete();
                        System.out.println("파일 삭제 완료: " + hpost.getPhoto2());
                    }
                }
                
                // photo3 삭제
                if (hpost.getPhoto3() != null && !hpost.getPhoto3().trim().isEmpty()) {
                    File photo3File = new File(uploadPath + "/hpostsave/" + hpost.getPhoto3());
                    if (photo3File.exists()) {
                        photo3File.delete();
                        System.out.println("파일 삭제 완료: " + hpost.getPhoto3());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("파일 삭제 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 게시물 삭제 시 알림 전송
     */
    private void sendDeleteNotifications(Hpost hpost) {
        try {
            // 1. 게시물 작성자에게 정책위반 삭제 알림
            if (hpost.getUserid() != null && !hpost.getUserid().trim().isEmpty()) {
                // member 테이블에서 userid로 사용자 정보 조회
                Member authorMember = memberService.findByUserid(hpost.getUserid());
                if (authorMember != null && authorMember.getNickname() != null) {
                    Notification authorNotification = new Notification();
                    authorNotification.setUserid(hpost.getUserid()); // 실제 userid 사용
                    authorNotification.setMessage(authorMember.getNickname() + "님, 귀하가 작성하신 게시물 \"" + hpost.getTitle() + "\"이 정책위반 사항으로 삭제되었습니다.");
                    authorNotification.setType("WARNING");
                    notificationService.createNotification(authorNotification);
                }
            }
            
            // 2. 신고자들에게 삭제 완료 알림
            List<Map<String, Object>> reportDetails = adminService.getReportDetailsByPostId(hpost.getId());
            System.out.println("=== 신고자 알림 디버깅 ===");
            System.out.println("게시글 ID: " + hpost.getId());
            System.out.println("신고자 수: " + reportDetails.size());
            System.out.println("신고자 데이터: " + reportDetails);
            
            for (Map<String, Object> report : reportDetails) {
                String reporterUserid = (String) report.get("user_id"); // hottalk_report의 user_id (member의 userid)
                System.out.println("신고자 userid: " + reporterUserid);
                
                if (reporterUserid != null && !reporterUserid.trim().isEmpty()) {
                    // member 테이블에서 userid로 사용자 정보 조회
                    Member reporterMember = memberService.findByUserid(reporterUserid);
                    System.out.println("신고자 member 조회 결과: " + (reporterMember != null ? "존재함" : "없음"));
                    
                    if (reporterMember != null && reporterMember.getNickname() != null) {
                        System.out.println("신고자 닉네임: " + reporterMember.getNickname());
                        Notification reporterNotification = new Notification();
                        reporterNotification.setUserid(reporterUserid); // 실제 userid 사용
                        reporterNotification.setMessage(reporterMember.getNickname() + "님, 신고하신 게시물 \"" + hpost.getTitle() + "\"이 정책위반 사항으로 삭제되었습니다.");
                        reporterNotification.setType("INFO");
                        notificationService.createNotification(reporterNotification);
                        System.out.println("신고자 알림 생성 완료: " + reporterUserid);
                    } else {
                        System.out.println("신고자 알림 생성 실패 - member 없음 또는 닉네임 없음");
                    }
                } else {
                    System.out.println("신고자 userid가 null이거나 비어있음");
                }
            }
            
        } catch (Exception e) {
            System.err.println("알림 전송 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 코스 삭제 시 알림 전송
     */
    private void sendCourseDeleteNotifications(Course course) {
        try {
            // 1. 코스 작성자에게 정책위반 삭제 알림
            if (course.getUserId() != null && !course.getUserId().trim().isEmpty()) {
                // member 테이블에서 userid로 사용자 정보 조회
                Member authorMember = memberService.findByUserid(course.getUserId());
                if (authorMember != null && authorMember.getNickname() != null) {
                    Notification authorNotification = new Notification();
                    authorNotification.setUserid(course.getUserId()); // 실제 userid 사용
                    authorNotification.setMessage(authorMember.getNickname() + "님, 귀하가 작성하신 코스 \"" + course.getTitle() + "\"이 정책위반 사항으로 삭제되었습니다.");
                    authorNotification.setType("WARNING");
                    notificationService.createNotification(authorNotification);
                }
            }
            
            // 2. 신고자들에게 삭제 완료 알림
            List<Map<String, Object>> reportDetails = adminService.getCourseReportDetailsByCourseId(course.getId());
            System.out.println("=== 코스 신고자 알림 디버깅 ===");
            System.out.println("코스 ID: " + course.getId());
            System.out.println("신고자 수: " + reportDetails.size());
            System.out.println("신고자 데이터: " + reportDetails);
            
            for (Map<String, Object> report : reportDetails) {
                String reporterUserid = (String) report.get("user_key"); // course_report의 user_key
                System.out.println("신고자 userid: " + reporterUserid);
                
                if (reporterUserid != null && !reporterUserid.trim().isEmpty()) {
                    // member 테이블에서 userid로 사용자 정보 조회
                    Member reporterMember = memberService.findByUserid(reporterUserid);
                    System.out.println("신고자 member 조회 결과: " + (reporterMember != null ? "존재함" : "없음"));
                    
                    if (reporterMember != null && reporterMember.getNickname() != null) {
                        System.out.println("신고자 닉네임: " + reporterMember.getNickname());
                        Notification reporterNotification = new Notification();
                        reporterNotification.setUserid(reporterUserid); // 실제 userid 사용
                        reporterNotification.setMessage(reporterMember.getNickname() + "님, 신고하신 코스 \"" + course.getTitle() + "\"이 정책위반 사항으로 삭제되었습니다.");
                        reporterNotification.setType("INFO");
                        notificationService.createNotification(reporterNotification);
                        System.out.println("신고자 알림 생성 완료: " + reporterUserid);
                    } else {
                        System.out.println("신고자 알림 생성 실패 - member 없음 또는 닉네임 없음");
                    }
                } else {
                    System.out.println("신고자 userid가 null이거나 비어있음");
                }
            }
            
        } catch (Exception e) {
            System.err.println("코스 알림 전송 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 코스 관련 파일 삭제
     */
    private void deleteCourseFiles(Course course) {
        try {
            if (uploadPath != null && !uploadPath.isEmpty()) {
                // 코스 스텝의 이미지 파일들 삭제
                List<CourseStep> courseSteps = courseService.getCourseSteps(course.getId());
                for (CourseStep step : courseSteps) {
                    if (step.getPhotoUrl() != null && !step.getPhotoUrl().trim().isEmpty()) {
                        File imageFile = new File(uploadPath + "/course/" + step.getPhotoUrl());
                        if (imageFile.exists()) {
                            imageFile.delete();
                            System.out.println("코스 이미지 파일 삭제 완료: " + step.getPhotoUrl());
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("코스 파일 삭제 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 회원 상태 변경 (관리자용)
     */
    @PostMapping("/member/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> changeMemberStatus(@RequestBody Map<String, String> requestData) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userid = requestData.get("userid");
            String newStatus = requestData.get("status");
            
            if (userid == null || userid.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "사용자 ID가 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (newStatus == null || !isValidStatus(newStatus)) {
                response.put("success", false);
                response.put("message", "유효하지 않은 상태입니다. (A, B, C, W 중 하나)");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 관리자 계정은 상태 변경 불가
            if ("admin".equals(userid)) {
                response.put("success", false);
                response.put("message", "관리자 계정의 상태는 변경할 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 회원 상태 변경
            boolean result = memberService.updateMemberStatus(userid, newStatus);
            
            if (result) {
                // 회원 상태 변경 알림 전송
                sendMemberStatusChangeNotification(userid, newStatus);
                
                response.put("success", true);
                response.put("message", "회원 상태가 성공적으로 변경되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "회원 상태 변경에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "회원 상태 변경 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 유효한 상태인지 확인
     */
    private boolean isValidStatus(String status) {
        return "A".equals(status) || "B".equals(status) || "C".equals(status) || "W".equals(status);
    }
    
    /**
     * 회원 상태 변경 시 알림 전송
     */
    private void sendMemberStatusChangeNotification(String userid, String newStatus) {
        try {
            // member 테이블에서 userid로 사용자 정보 조회
            Member member = memberService.findByUserid(userid);
            if (member != null && member.getNickname() != null) {
                String statusText = getStatusText(newStatus);
                String message = "";
                String type = "";
                
                switch (newStatus) {
                    case "A":
                        message = member.getNickname() + "님, 회원 상태가 정상으로 변경되었습니다.";
                        type = "INFO";
                        break;
                    case "B":
                        message = member.getNickname() + "님, 회원 상태가 경고로 변경되었습니다. 일부 기능이 제한될 수 있습니다.";
                        type = "WARNING";
                        break;
                    case "C":
                        message = member.getNickname() + "님, 회원 상태가 정지로 변경되었습니다. 로그인이 제한됩니다.";
                        type = "WARNING";
                        break;
                    case "W":
                        message = member.getNickname() + "님, 회원 상태가 삭제로 변경되었습니다. 계정이 비활성화됩니다.";
                        type = "WARNING";
                        break;
                    default:
                        message = member.getNickname() + "님, 회원 상태가 " + statusText + "로 변경되었습니다.";
                        type = "INFO";
                        break;
                }
                
                Notification notification = new Notification();
                notification.setUserid(userid);
                notification.setMessage(message);
                notification.setType(type);
                notificationService.createNotification(notification);
                
                System.out.println("회원 상태 변경 알림 전송 완료: " + userid + " -> " + newStatus);
            } else {
                System.out.println("회원 상태 변경 알림 전송 실패 - member 없음 또는 닉네임 없음: " + userid);
            }
            
        } catch (Exception e) {
            System.err.println("회원 상태 변경 알림 전송 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * 상태 코드를 텍스트로 변환
     */
    private String getStatusText(String status) {
        switch (status) {
            case "A": return "정상";
            case "B": return "경고";
            case "C": return "정지";
            case "W": return "삭제";
            default: return status;
        }
    }
    
    /**
     * 회원 관리 페이지
     */
    @GetMapping("/member")
    public String memberAdmin(Model model) {
        model.addAttribute("mainPage", "adminpage/memberadmin.jsp");
        return "index";
    }
    
    /**
     * 회원 통계 조회
     */
    @GetMapping("/member/stats")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMemberStats() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Map<String, Object> stats = memberService.getMemberStatistics();
            response.put("success", true);
            response.put("stats", stats);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "회원 통계 조회 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 회원 목록 조회
     */
    @GetMapping("/member/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMemberList() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<Member> members = memberService.findAllMembers(0, 100); // 최대 100명
            response.put("success", true);
            response.put("members", members);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "회원 목록 조회 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 회원 검색
     */
    @GetMapping("/member/search")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> searchMembers(@RequestParam String keyword) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (keyword == null || keyword.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "검색어를 입력해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            List<Member> members = memberService.searchMembers(keyword.trim(), null, null, 0, 100);
            response.put("success", true);
            response.put("members", members);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "회원 검색 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 상태별 회원 목록 조회
     */
    @GetMapping("/member/list/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMembersByStatus(@RequestParam String status) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (status == null || status.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "상태를 선택해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            
            List<Member> members = memberService.findMembersByStatus(status.trim(), 0, 100);
            response.put("success", true);
            response.put("members", members);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "상태별 회원 조회 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
}
