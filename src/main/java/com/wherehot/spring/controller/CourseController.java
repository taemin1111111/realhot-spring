package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Course;
import com.wherehot.spring.entity.CourseStep;
import com.wherehot.spring.entity.CourseComment;
import com.wherehot.spring.entity.CourseReport;
import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.entity.Region;
import com.wherehot.spring.service.CourseService;
import com.wherehot.spring.service.CourseReactionService;
import com.wherehot.spring.service.CourseCommentService;
import com.wherehot.spring.service.CourseCommentReactionService;
import com.wherehot.spring.service.CourseReportService;
import com.wherehot.spring.service.HotplaceService;
import com.wherehot.spring.service.RegionService;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.ServletContext;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

@Controller
@RequestMapping("/course")
public class CourseController {
    
    @Value("${file.upload.course-path:src/main/webapp/uploads/course}")
    private String courseUploadPath;
    
    @Autowired
    private ServletContext servletContext;
    
    @Autowired
    private ResourceLoader resourceLoader;
    
    @Autowired
    private CourseService courseService;
    
    @Autowired
    private HotplaceService hotplaceService;
    
    @Autowired
    private RegionService regionService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private CourseReactionService courseReactionService;
    
    @Autowired
    private CourseCommentService courseCommentService;
    
    @Autowired
    private CourseCommentReactionService courseCommentReactionService;
    
    @Autowired
    private CourseReportService courseReportService;
    
    // SHA-256 해시 함수
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // IP 주소 가져오기
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty() && !"unknown".equalsIgnoreCase(xRealIp)) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    // 사용자 ID 결정 (로그인된 사용자면 userid, 아니면 IP)
    private String determineUserId(HttpServletRequest request) {
        // Spring Security의 Authentication 객체에서 사용자 정보 가져오기
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // 인증된 사용자인지, 그리고 익명 사용자가 아닌지 확인
        if (authentication != null && authentication.isAuthenticated() && !"anonymousUser".equals(authentication.getPrincipal())) {
            return authentication.getName();
        }

        // 인증되지 않은 사용자의 경우 IP 주소 반환
        return getClientIpAddress(request);
    }
    
    // 사용자 로그인 상태 확인
    private boolean isUserLoggedIn(HttpServletRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && authentication.isAuthenticated() && !"anonymousUser".equals(authentication.getPrincipal());
    }
    
    // 코스 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("")
    public String courseList(@RequestParam(name = "page", defaultValue = "1") int page,
                           @RequestParam(name = "sort", defaultValue = "latest") String sort,
                           @RequestParam(name = "sido", required = false) String sido,
                           @RequestParam(name = "sigungu", required = false) String sigungu,
                           @RequestParam(name = "dong", required = false) String dong,
                           @RequestParam(name = "search", required = false) String search,
                           Model model) {
        

        
        List<Course> courseList;
        int totalCount;
        
        if (search != null && !search.trim().isEmpty()) {
            // 검색 기능
            if ("popular".equals(sort)) {
                courseList = courseService.getPopularCourseListBySearch(search.trim(), page);
            } else {
                courseList = courseService.getLatestCourseListBySearch(search.trim(), page);
            }
            totalCount = courseService.getCourseCountBySearch(search.trim());
        } else if (sido != null || sigungu != null || dong != null) {
            // 지역별 필터링
            if ("popular".equals(sort)) {
                courseList = courseService.getPopularCourseListByRegion(sido, sigungu, dong, page);
            } else {
                courseList = courseService.getLatestCourseListByRegion(sido, sigungu, dong, page);
            }
            totalCount = courseService.getCourseCountByRegion(sido, sigungu, dong);
        } else {
            // 전체 목록
            if ("popular".equals(sort)) {
                courseList = courseService.getPopularCourseList(page);
            } else {
                courseList = courseService.getLatestCourseList(page);
            }
            totalCount = courseService.getTotalCourseCount();
        }
        

        
        model.addAttribute("courseList", courseList);
        model.addAttribute("currentPage", page);
        model.addAttribute("sort", sort);
        model.addAttribute("sido", sido);
        model.addAttribute("sigungu", sigungu);
        model.addAttribute("dong", dong);
        model.addAttribute("search", search);
        model.addAttribute("totalCount", totalCount);
        
        // 지역 데이터 추가
        loadRegionData(model);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "pullcourse/course.jsp");
        return "index";
    }
    
    // 코스 상세 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/{id}")
    public String courseDetail(@PathVariable(name = "id") int id, Model model, HttpSession session, HttpServletRequest request) {
        try {
            // ID 유효성 검사
            if (id <= 0) {
                return "redirect:/course";
            }
            
            // 조회수 증가 (세션 기반 중복 방지)
            String viewKey = "course_view_" + id;
            if (session.getAttribute(viewKey) == null) {
                courseService.incrementViewCount(id);
                session.setAttribute(viewKey, true);
            }
            
            // 데이터 조회
            Course course = courseService.getCourseByIdWithoutIncrement(id);
            
            if (course == null) {
                // 에러 페이지로 리다이렉트 또는 에러 처리
                return "redirect:/course";
            }
        
        List<CourseStep> courseSteps = courseService.getCourseSteps(id);
        
        // 사용자 식별 (JWT 토큰 또는 IP)
        String userKey = determineUserId(request);
        
        // 좋아요/싫어요 개수 조회
        Map<String, Integer> reactionCounts = courseReactionService.getReactionCounts(id);
        
        // 현재 사용자의 리액션 상태 조회
        String currentReaction = courseReactionService.getCurrentReaction(id, userKey);
        
        model.addAttribute("course", course);
        model.addAttribute("courseSteps", courseSteps);
        model.addAttribute("likeCount", reactionCounts.get("likeCount"));
        model.addAttribute("dislikeCount", reactionCounts.get("dislikeCount"));
        model.addAttribute("currentReaction", currentReaction);
        model.addAttribute("userKey", userKey);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "pullcourse/courseDetail.jsp");
        return "index";
        
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/course";
        }
    }
    
    // 댓글 리액션 API (좋아요/싫어요)
    @PostMapping("/{courseId}/comment/{commentId}/reaction")
    @ResponseBody
    public Map<String, Object> toggleCommentReaction(
            @PathVariable int courseId,
            @PathVariable int commentId,
            @RequestParam String reactionType,
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 식별 (로그인 시 userid, 비로그인 시 IP)
            String userKey = determineUserId(request);
            
            // 리액션 토글 처리
            CourseCommentReactionService.ReactionResult result = 
                courseCommentReactionService.toggleReaction(commentId, userKey, reactionType);
            
            if (result.isSuccess()) {
                response.put("success", true);
                response.put("action", result.getAction());
                response.put("currentReaction", result.getCurrentReaction());
                response.put("likeCount", result.getLikeCount());
                response.put("dislikeCount", result.getDislikeCount());
                response.put("message", result.getMessage());
            } else {
                response.put("success", false);
                response.put("message", result.getMessage());
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "리액션 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // 코스 등록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/create")
    public String courseCreateForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "pullcourse/courseCreate.jsp");
        return "index";
    }
    
    // 코스 등록 처리 (파일 업로드 포함)
    @PostMapping("/create")
    @ResponseBody
    public String createCourse(MultipartHttpServletRequest request) {
        try {
            // 코스 기본 정보 추출
            Course course = new Course();
            String title = request.getParameter("title");
            String summary = request.getParameter("summary");
            String nickname = request.getParameter("nickname");
            String password = request.getParameter("password");
            String userId = request.getParameter("userId");
            
            course.setTitle(title);
            course.setSummary(summary);
            course.setNickname(nickname);
            
            // 비밀번호 해시화
            if (password != null && !password.trim().isEmpty()) {
                String hashedPassword = hashPassword(password);
                course.setPasswdHash(hashedPassword);
            }
            
            // userId 처리: 클라이언트에서 전송한 값이 있으면 사용, 없으면 IP 주소 사용
            if (userId != null && !userId.trim().isEmpty() && !"anonymous".equals(userId.trim())) {
                course.setUserId(userId);
                course.setAuthorUserid("user");
            } else {
                // 클라이언트에서 userId가 없거나 "anonymous"인 경우 IP 주소 사용
                String ipUserId = determineUserId(request);
                course.setUserId(ipUserId);
                course.setAuthorUserid("anonymous");
            }
            
            // 스텝 데이터와 파일 추출
            List<CourseStep> courseSteps = new ArrayList<>();
            
            // 스텝 개수 확인 (파라미터로부터)
            int stepCount = 0;
            while (request.getParameter("steps[" + stepCount + "].stepNo") != null) {
                stepCount++;
            }
            
            // 만약 위 방법으로 찾지 못하면, 다른 방법으로 시도
            if (stepCount == 0) {
                // steps[].stepNo 형태로 전송된 경우 처리
                String stepNoParam = request.getParameter("steps[].stepNo");
                if (stepNoParam != null) {
                    String[] stepNos = stepNoParam.split(",");
                    stepCount = stepNos.length;
                }
            }
            

            
                                     // steps[].stepNo 형태로 전송된 경우 처리
            String[] stepNoParams = request.getParameterValues("steps[].stepNo");
            String[] placeIdParams = request.getParameterValues("steps[].placeId");
            String[] placeNameParams = request.getParameterValues("steps[].placeName");
            String[] descriptionParams = request.getParameterValues("steps[].description");
            
            if (stepNoParams != null && placeIdParams != null && stepNoParams.length > 0) {
                 // 배열 길이 확인 및 조정
                 int maxLength = Math.max(stepNoParams.length, placeIdParams.length);
                 
                 for (int i = 0; i < maxLength; i++) {
                     CourseStep step = new CourseStep();
                     
                     // stepNo 설정
                     if (i < stepNoParams.length) {
                         step.setStepNo(Integer.parseInt(stepNoParams[i].trim()));
                     } else {
                         step.setStepNo(i + 1); // 기본값
                     }
                     
                     // placeId 설정
                     if (i < placeIdParams.length) {
                         String placeIdStr = placeIdParams[i].trim();
                         if (placeIdStr != null && !placeIdStr.isEmpty()) {
                             step.setPlaceId(Integer.parseInt(placeIdStr));
                         } else {
                             continue;
                         }
                     } else {
                         continue;
                     }
                     
                     // placeName 설정
                     if (i < placeNameParams.length) {
                         step.setPlaceName(placeNameParams[i].trim());
                     }
                     
                     // description 설정
                     if (i < descriptionParams.length) {
                         step.setDescription(descriptionParams[i].trim());
                     }
                     
                     // 파일 처리 - MultipartFile 방식으로 복원
                     MultipartFile photoFile = null;
                     
                     // 모든 파일 맵 가져오기
                     Map<String, MultipartFile> fileMap = request.getFileMap();
                     System.out.println("전체 파일 맵: " + fileMap.keySet());
                     
                     // 파일 맵에서 현재 스텝에 해당하는 파일 찾기
                     photoFile = null;
                     
                     // 1. stepPhoto_숫자 형태의 키를 찾기
                     String photoKey = "stepPhoto_" + i;
                     photoFile = fileMap.get(photoKey);
                     if (photoFile != null && !photoFile.isEmpty()) {
                         System.out.println("스텝 " + i + "에 해당하는 파일 찾음: " + photoKey);
                     }
                     
                     // 2. stepPhoto_ 형태의 키가 있는 경우 (브라우저 호환성 문제로 숫자가 빠진 경우)
                     if (photoFile == null) {
                         photoFile = fileMap.get("stepPhoto_");
                         if (photoFile != null && !photoFile.isEmpty()) {
                             System.out.println("stepPhoto_ 형태의 파일을 스텝 " + i + "에 할당");
                         }
                     }
                     
                     // 2. 기존 steps[숫자].photo 형태의 키도 지원 (하위 호환성)
                     if (photoFile == null) {
                         for (Map.Entry<String, MultipartFile> entry : fileMap.entrySet()) {
                             String key = entry.getKey();
                             MultipartFile file = entry.getValue();
                             
                             if (key.matches("steps\\[\\d+\\]\\.photo")) {
                                 // 키에서 숫자 추출
                                 String numberStr = key.replaceAll("steps\\[(\\d+)\\]\\.photo", "$1");
                                 int stepIndex = Integer.parseInt(numberStr);
                                 
                                 // 현재 스텝 인덱스와 일치하는지 확인
                                 if (stepIndex == i) {
                                     photoFile = file;
                                     System.out.println("스텝 " + i + "에 해당하는 파일 찾음 (기존 방식): " + key);
                                     break;
                                 }
                             }
                         }
                     }
                     
                     // 3. steps[].photo 형태의 키가 있는 경우, 모든 파일을 리스트로 가져와서 순서대로 할당
                     if (photoFile == null) {
                         List<MultipartFile> allPhotos = request.getFiles("steps[].photo");
                         System.out.println("steps[].photo 파일 개수: " + allPhotos.size());
                         
                         if (i < allPhotos.size()) {
                             MultipartFile stepPhoto = allPhotos.get(i);
                             if (stepPhoto != null && !stepPhoto.isEmpty()) {
                                 photoFile = stepPhoto;
                                 System.out.println("steps[].photo에서 스텝 " + i + "에 파일 할당: " + stepPhoto.getOriginalFilename());
                             }
                         }
                     }
                     
                     System.out.println("파일 존재 여부: " + (photoFile != null));
                     if (photoFile != null) {
                         System.out.println("파일 크기: " + photoFile.getSize());
                         System.out.println("파일명: " + photoFile.getOriginalFilename());
                         System.out.println("파일이 비어있지 않음: " + !photoFile.isEmpty());
                     }
                     
                     if (photoFile != null && !photoFile.isEmpty()) {
                         // ServletContext를 사용하여 배포 경로 설정
                         try {
                             String uploadDir = servletContext.getRealPath("/uploads/course");
                             File dir = new File(uploadDir);
                             
                             if (!dir.exists()) {
                                 boolean created = dir.mkdirs();
                                 if (!created) {
                                     throw new RuntimeException("업로드 디렉토리를 생성할 수 없습니다: " + uploadDir);
                                 }
                                 // 디렉토리 권한 설정 (755)
                                 dir.setReadable(true, false);
                                 dir.setWritable(true, true);
                                 dir.setExecutable(true, false);
                             }
                         
                         // 파일명 생성 (타임스탬프 + 스텝번호 + 랜덤값 + 원본파일명)
                         String originalFilename = photoFile.getOriginalFilename();
                         String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
                         String newFilename = System.currentTimeMillis() + "_" + step.getStepNo() + "_" + (int)(Math.random() * 1000) + fileExtension;
                         
                         // 파일 저장
                         File dest = new File(uploadDir + File.separator + newFilename);
                         
                         try {
                             // 파일 스트림을 사용하여 안전하게 파일 저장
                             try (java.io.InputStream inputStream = photoFile.getInputStream();
                                  java.io.FileOutputStream outputStream = new java.io.FileOutputStream(dest)) {
                                 
                                 byte[] buffer = new byte[1024];
                                 int bytesRead;
                                 while ((bytesRead = inputStream.read(buffer)) != -1) {
                                     outputStream.write(buffer, 0, bytesRead);
                                 }
                             }
                             
                             // 파일 권한 설정 (644)
                             dest.setReadable(true, false);
                             dest.setWritable(true, true);
                             
                             // 데이터베이스에 저장할 경로 설정
                             step.setPhotoUrl("/uploads/course/" + newFilename);
                         } catch (IOException e) {
                             e.printStackTrace();
                             // 파일 저장 실패해도 스텝은 계속 진행
                         }
                     } catch (Exception e) {
                         e.printStackTrace();
                     }
                 }
                 
                 courseSteps.add(step);
                 }
             }
            
            // 코스 등록
            int courseId = courseService.createCourse(course, courseSteps);
            
            if (courseId > 0) {
                return "success";
            } else {
                return "error";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "error";
        }
    }
    
    // 좋아요/싫어요 토글 API
    @PostMapping("/{id}/reaction")
    @ResponseBody
    public Map<String, Object> toggleReaction(@PathVariable int id, 
                                            @RequestParam String reactionType,
                                            HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 로그인 상태 확인
            String userKey = determineUserId(request);
            boolean isLoggedIn = isUserLoggedIn(request);
            
            if (!isLoggedIn) {
                response.put("success", false);
                response.put("message", "좋아요/싫어요는 로그인 후 가능합니다.");
                response.put("requireLogin", true);
                return response;
            }
            
            // 리액션 토글 처리
            Map<String, Object> result = courseReactionService.toggleReaction(id, userKey, reactionType);
            
            response.put("success", true);
            response.put("currentReaction", result.get("currentReaction"));
            response.put("likeCount", result.get("likeCount"));
            response.put("dislikeCount", result.get("dislikeCount"));
            response.put("action", result.get("action"));
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "리액션 처리 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 지역 데이터 로드
    private void loadRegionData(Model model) {
        try {
            // 모든 지역 데이터 조회
            List<Region> allRegions = regionService.findAllRegions();
            
            if (allRegions.isEmpty()) {
                model.addAttribute("regionsBySido", new HashMap<>());
                model.addAttribute("regionsBySigungu", new HashMap<>());
                return;
            }
            
            // 시도별로 그룹화
            Map<String, List<Region>> regionsBySido = allRegions.stream()
                .collect(Collectors.groupingBy(Region::getSido));
            
            // 시도별 시군구 그룹화
            Map<String, Map<String, List<Region>>> regionsBySigungu = new HashMap<>();
            for (Map.Entry<String, List<Region>> entry : regionsBySido.entrySet()) {
                String sido = entry.getKey();
                List<Region> regions = entry.getValue();
                
                Map<String, List<Region>> sigunguMap = regions.stream()
                    .collect(Collectors.groupingBy(Region::getSigungu));
                regionsBySigungu.put(sido, sigunguMap);
            }
            
            model.addAttribute("regionsBySido", regionsBySido);
            model.addAttribute("regionsBySigungu", regionsBySigungu);
            
        } catch (Exception e) {
            // 에러 발생 시 빈 데이터로 설정
            System.err.println("지역 데이터 로드 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("regionsBySido", new HashMap<>());
            model.addAttribute("regionsBySigungu", new HashMap<>());
        }
    }
    
    // 댓글 작성 API
    @PostMapping("/{courseId}/comment")
    @ResponseBody
    public Map<String, Object> createComment(@PathVariable int courseId,
                                           @RequestParam String nickname,
                                           @RequestParam(required = false) String password,
                                           @RequestParam String content,
                                           @RequestParam(required = false) Integer parentId,
                                           HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 로그인 상태 확인
            boolean isLoggedIn = isUserLoggedIn(request);
            String authorUserid;
            
            // 댓글 객체 생성
            CourseComment comment = new CourseComment();
            comment.setCourseId(courseId);
            comment.setContent(content);
            comment.setParentId(parentId);
            
            if (isLoggedIn) {
                // 로그인한 사용자
                authorUserid = determineUserId(request);
                comment.setAuthorUserid(authorUserid);
                comment.setNickname(nickname);
                comment.setPasswdHash(null); // 비밀번호 불필요
            } else {
                // 비로그인 사용자
                comment.setAuthorUserid("anonymous");
                comment.setNickname(nickname);
                
                // 비밀번호 검증
                if (password == null || password.length() != 4 || !password.matches("\\d{4}")) {
                    response.put("success", false);
                    response.put("message", "비밀번호는 숫자 4자리로 입력해주세요.");
                    return response;
                }
                // 비밀번호 해시화
                String hashedPassword = hashPassword(password);
                comment.setPasswdHash(hashedPassword);
            }
            
            // 댓글 등록
            int result = courseCommentService.createComment(comment);
            
            if (result > 0) {
                // 새로 생성된 댓글 정보 조회
                CourseComment savedComment = courseCommentService.getCommentById(comment.getId());
                
                response.put("success", true);
                response.put("message", "댓글이 등록되었습니다.");
                response.put("commentId", comment.getId());
                response.put("comment", savedComment);
            } else {
                response.put("success", false);
                response.put("message", "댓글 등록에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "댓글 등록 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 댓글 목록 조회 API
    @GetMapping("/{courseId}/comments")
    @ResponseBody
    public Map<String, Object> getComments(@PathVariable(name = "courseId") int courseId,
                                          @RequestParam(name = "sort", defaultValue = "latest") String sort,
                                          HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 식별 (로그인 시 userid, 비로그인 시 IP)
            String userKey = determineUserId(request);
            
            List<CourseComment> comments = courseCommentService.getParentCommentsByCourseIdWithUserReaction(courseId, userKey);
            
            // 각 부모 댓글에 대댓글 갯수 추가
            for (CourseComment comment : comments) {
                int replyCount = courseCommentService.getReplyCountByParentId(comment.getId());
                comment.setReplyCount(replyCount);
            }
            
            // 정렬 처리
            if ("popular".equals(sort)) {
                // 인기순: 좋아요 수 기준으로 정렬
                comments.sort((a, b) -> {
                    int aScore = a.getLikeCount() - a.getDislikeCount();
                    int bScore = b.getLikeCount() - b.getDislikeCount();
                    return Integer.compare(bScore, aScore); // 내림차순
                });
            } else {
                // 최신순: 생성일시 기준으로 정렬 (이미 매퍼에서 정렬됨)
            }
            
            response.put("success", true);
            response.put("comments", comments);
            response.put("totalCount", comments.size()); // 부모 댓글 개수만
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "댓글 조회 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 대댓글 목록 조회 API
    @GetMapping("/{courseId}/replies")
    @ResponseBody
    public Map<String, Object> getReplies(@PathVariable(name = "courseId") int courseId,
                                         @RequestParam(name = "parentId") int parentId,
                                         HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 식별 (로그인 시 userid, 비로그인 시 IP)
            String userKey = determineUserId(request);
            
            List<CourseComment> replies = courseCommentService.getRepliesByParentIdWithUserReaction(parentId, userKey);
            
            // 대댓글에 replyCount 설정
            for (CourseComment reply : replies) {
                reply.setReplyCount(0); // 대댓글은 대댓글을 가질 수 없음
            }
            
            response.put("success", true);
            response.put("comments", replies);
            response.put("totalCount", replies.size());
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "대댓글 조회 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 핫플레이스 검색 API (자동완성용)
    @GetMapping("/hotplace/search")
    @ResponseBody
    public List<Map<String, Object>> searchHotplaces(@RequestParam(name = "keyword") String keyword) {
        try {
            List<Hotplace> hotplaces = hotplaceService.searchHotplaces(keyword, 1, 10);
            List<Map<String, Object>> result = new ArrayList<>();
            
            for (Hotplace hotplace : hotplaces) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", hotplace.getId());
                item.put("name", hotplace.getName());
                item.put("address", hotplace.getAddress());
                result.add(item);
            }
            
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    // 코스 삭제 API
    @PostMapping("/delete")
    @ResponseBody
    public Map<String, Object> deleteCourse(@RequestBody Map<String, Object> requestData, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String courseIdStr = (String) requestData.get("courseId");
            String password = (String) requestData.get("password");
            String authorUserid = (String) requestData.get("authorUserid");
            String userId = (String) requestData.get("userId");
            
            int courseId;
            try {
                courseId = Integer.parseInt(courseIdStr);
            } catch (NumberFormatException e) {
                response.put("success", false);
                response.put("message", "유효하지 않은 코스 ID입니다.");
                return response;
            }
            
            if (courseIdStr == null) {
                response.put("success", false);
                response.put("message", "필수 정보가 누락되었습니다.");
                return response;
            }
            
            // 관리자 권한 확인 (JWT 토큰에서)
            boolean isAdmin = false;
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                if (jwtUtils.validateToken(token)) {
                    String provider = jwtUtils.getProviderFromToken(token);
                    isAdmin = "admin".equals(provider);
                }
            }
            
            // 관리자가 아닌 경우 비밀번호 필수
            if (!isAdmin && password == null) {
                response.put("success", false);
                response.put("message", "비밀번호를 입력해주세요.");
                return response;
            }
            
            // 코스 정보 조회
            Course course = courseService.getCourseByIdWithoutIncrement(courseId);
            if (course == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 코스입니다.");
                return response;
            }
            
            // 비밀번호 확인 (관리자가 아닌 경우에만)
            if (!isAdmin) {
                String hashedPassword = hashPassword(password);
                if (!hashedPassword.equals(course.getPasswdHash())) {
                    response.put("success", false);
                    response.put("message", "비밀번호가 일치하지 않습니다.");
                    return response;
                }
            }
            
            // 권한 확인 (관리자가 아닌 경우에만)
            if (!isAdmin && "user".equals(authorUserid)) {
                // 로그인된 사용자가 쓴 글인 경우, 현재 로그인한 사용자와 일치하는지 확인
                String currentUserId = determineUserId(request);
                
                // JWT 토큰에서 사용자 ID를 가져올 수 없는 경우, 요청에서 전달받은 userId 사용
                if (currentUserId == null || currentUserId.isEmpty() || currentUserId.equals(getClientIpAddress(request))) {
                    // IP 주소인 경우 (로그인되지 않은 경우) 삭제 불가
                    response.put("success", false);
                    response.put("message", "로그인된 사용자만 삭제할 수 있습니다.");
                    return response;
                }
                
                if (!userId.equals(currentUserId)) {
                    response.put("success", false);
                    response.put("message", "글쓴이와 ID가 일치해야 삭제 가능합니다.");
                    return response;
                }
            }
            
            // 삭제 실행
            courseService.deleteCourse(courseId);
            
            response.put("success", true);
            response.put("message", "코스가 삭제되었습니다.");
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // 댓글 삭제 API
    @PostMapping("/comment/delete")
    @ResponseBody
    public Map<String, Object> deleteComment(@RequestBody Map<String, Object> requestData, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String commentIdStr = (String) requestData.get("commentId");
            String nickname = (String) requestData.get("nickname");
            String password = (String) requestData.get("password");
            String authorUserid = (String) requestData.get("authorUserid");
            
            int commentId;
            try {
                commentId = Integer.parseInt(commentIdStr);
            } catch (NumberFormatException e) {
                response.put("success", false);
                response.put("message", "유효하지 않은 댓글 ID입니다.");
                return response;
            }
            
            if (commentIdStr == null || nickname == null) {
                response.put("success", false);
                response.put("message", "필수 정보가 누락되었습니다.");
                return response;
            }
            
            // 댓글 정보 조회
            CourseComment comment = courseCommentService.getCommentById(commentId);
            if (comment == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 댓글입니다.");
                return response;
            }
            
                         // 닉네임 확인
             if (!nickname.equals(comment.getNickname())) {
                 response.put("success", false);
                 response.put("message", "댓글 작성자와 일치하지 않습니다.");
                 return response;
             }
             
             // 로그인 상태 확인
             boolean isLoggedIn = isUserLoggedIn(request);
             String currentUserId = determineUserId(request);
             
             
             
             // 권한 확인
             boolean hasPermission = false;
             
             // DB에서 조회한 authorUserid로 판단
             if ("anonymous".equals(comment.getAuthorUserid())) {
                 // anonymous 댓글인 경우: 비밀번호만 확인하면 삭제 가능
                 if (password == null) {
                     response.put("success", false);
                     response.put("message", "비밀번호를 입력해주세요.");
                     return response;
                 }
                 
                                                     // 비밀번호 확인 (서버 해시화 방식만 사용)
                   String hashedPassword = hashPassword(password);
                   boolean passwordMatch = comment.getPasswdHash() != null && hashedPassword.equals(comment.getPasswdHash());
                   
                   if (passwordMatch) {
                       hasPermission = true;
                   }
             } else {
                 // 로그인한 사용자가 작성한 댓글인 경우: 작성자 본인인지 확인
                 if (isLoggedIn && currentUserId.equals(comment.getAuthorUserid())) {
                     hasPermission = true;
                 }
             }
            
            if (!hasPermission) {
                response.put("success", false);
                response.put("message", "댓글을 삭제할 권한이 없습니다.");
                return response;
            }
            
            // 댓글 삭제 (댓글과 관련된 모든 데이터 삭제)
            boolean deleteResult = courseCommentService.deleteCommentWithAllData(commentId);
            
            if (deleteResult) {
                response.put("success", true);
                response.put("message", "댓글이 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "댓글 삭제에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "댓글 삭제 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 특정 가게가 포함된 코스 개수 조회 API
    @PostMapping("/api/course-count")
    @ResponseBody
    public Map<String, Object> getCourseCountByPlace(@RequestParam int placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            int courseCount = courseService.getCourseCountByPlaceId(placeId);
            
            response.put("success", true);
            response.put("placeId", placeId);
            response.put("courseCount", courseCount);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "코스 개수 조회 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
    
    // 특정 가게가 포함된 코스 목록 페이지
    @GetMapping("/place/{placeId}")
    public String courseListByPlace(@PathVariable(name = "placeId") int placeId,
                                   @RequestParam(name = "page", defaultValue = "1") int page,
                                   @RequestParam(name = "sort", defaultValue = "popular") String sort,
                                   Model model) {
        
        try {
            // 가게 정보 조회
            Optional<Hotplace> hotplaceOpt = hotplaceService.findHotplaceById(placeId);
            if (!hotplaceOpt.isPresent()) {
                return "redirect:/course";
            }
            Hotplace hotplace = hotplaceOpt.get();
            
            List<Course> courseList;
            int totalCount;
            
            if ("popular".equals(sort)) {
                courseList = courseService.getPopularCourseListByPlaceId(placeId, page);
            } else {
                courseList = courseService.getLatestCourseListByPlaceId(placeId, page);
            }
            totalCount = courseService.getCourseCountByPlaceId(placeId);
            
            model.addAttribute("courseList", courseList);
            model.addAttribute("currentPage", page);
            model.addAttribute("sort", sort);
            model.addAttribute("placeId", placeId);
            model.addAttribute("hotplace", hotplace);
            model.addAttribute("totalCount", totalCount);
            
            // 기존 JSP Include 방식 유지
            model.addAttribute("mainPage", "pullcourse/courseByPlace.jsp");
            return "index";
            
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/course";
        }
    }
    
    // 코스 신고 API
    @PostMapping("/report")
    @ResponseBody
    public Map<String, Object> reportCourse(@RequestBody Map<String, Object> requestData, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 로그인 상태 확인
            if (!isUserLoggedIn(request)) {
                response.put("success", false);
                response.put("message", "신고는 로그인 후 이용 가능합니다.");
                response.put("requireLogin", true);
                return response;
            }
            
            String courseIdStr = (String) requestData.get("courseId");
            String reason = (String) requestData.get("reason");
            String details = (String) requestData.get("details");
            
            if (courseIdStr == null || reason == null || reason.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "필수 정보가 누락되었습니다.");
                return response;
            }
            
            int courseId;
            try {
                courseId = Integer.parseInt(courseIdStr);
            } catch (NumberFormatException e) {
                response.put("success", false);
                response.put("message", "유효하지 않은 코스 ID입니다.");
                return response;
            }
            
            // 코스 존재 여부 확인
            Course course = courseService.getCourseById(courseId);
            if (course == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 코스입니다.");
                return response;
            }
            
            // 사용자 ID 가져오기
            String userId = determineUserId(request);
            if (userId == null) {
                response.put("success", false);
                response.put("message", "사용자 정보를 가져올 수 없습니다.");
                return response;
            }
            
            // 중복 신고 확인
            CourseReport existingReport = courseReportService.getReportByCourseIdAndUserKey(courseId, userId);
            if (existingReport != null) {
                response.put("success", false);
                response.put("message", "이미 신고한 코스입니다.");
                return response;
            }
            
            // 신고 생성
            CourseReport report = new CourseReport();
            report.setCourseId(courseId);
            report.setUserKey(userId);
            report.setReason(reason.trim());
            report.setDetails(details != null ? details.trim() : null);
            report.setStatus("RECEIVED");
            report.setResult("PENDING");
            
            boolean saveResult = courseReportService.saveReport(report);
            
            if (saveResult) {
                response.put("success", true);
                response.put("message", "신고가 접수되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "신고 접수에 실패했습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "신고 처리 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return response;
    }
}
