package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Course;
import com.wherehot.spring.entity.CourseStep;
import com.wherehot.spring.entity.CourseComment;
import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.entity.Region;
import com.wherehot.spring.service.CourseService;
import com.wherehot.spring.service.CourseReactionService;
import com.wherehot.spring.service.CourseCommentService;
import com.wherehot.spring.service.HotplaceService;
import com.wherehot.spring.service.RegionService;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/course")
public class CourseController {
    
    @Value("${file.upload.course-path:src/main/webapp/uploads/course}")
    private String courseUploadPath;
    
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
        try {
            // Authorization 헤더에서 JWT 토큰 추출
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                
                // JWT 토큰 유효성 검증
                if (jwtUtils.validateToken(token)) {
                    // 토큰에서 사용자 ID 추출
                    String userId = jwtUtils.getUseridFromToken(token);
                    if (userId != null && !userId.isEmpty()) {
                        System.out.println("JWT 토큰에서 사용자 ID 추출: " + userId);
                        return userId;
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("JWT 토큰 처리 중 오류: " + e.getMessage());
        }
        
        // 로그인되지 않은 경우 IP 주소 반환
        String ipAddress = getClientIpAddress(request);
        System.out.println("IP 주소 사용: " + ipAddress);
        return ipAddress;
    }
    
    // 사용자 로그인 상태 확인
    private boolean isUserLoggedIn(HttpServletRequest request) {
        try {
            // Authorization 헤더에서 JWT 토큰 추출
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                
                // JWT 토큰 유효성 검증
                if (jwtUtils.validateToken(token)) {
                    // 토큰에서 사용자 ID 추출
                    String userId = jwtUtils.getUseridFromToken(token);
                    if (userId != null && !userId.isEmpty()) {
                        return true;
                    }
                }
            }
            
            // 쿠키에서 토큰 확인
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("jwt_token".equals(cookie.getName())) {
                        String token = cookie.getValue();
                        if (jwtUtils.validateToken(token)) {
                            String userId = jwtUtils.getUseridFromToken(token);
                            if (userId != null && !userId.isEmpty()) {
                                return true;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("로그인 상태 확인 중 오류: " + e.getMessage());
        }
        
        return false;
    }
    
    // 코스 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("")
    public String courseList(@RequestParam(defaultValue = "1") int page,
                           @RequestParam(defaultValue = "latest") String sort,
                           @RequestParam(required = false) String sido,
                           @RequestParam(required = false) String sigungu,
                           @RequestParam(required = false) String dong,
                           Model model) {
        

        
        List<Course> courseList;
        int totalCount;
        
        if (sido != null || sigungu != null || dong != null) {
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
        model.addAttribute("totalCount", totalCount);
        
        // 지역 데이터 추가
        loadRegionData(model);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "pullcourse/course.jsp");
        return "index";
    }
    
    // 코스 상세 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/{id}")
    public String courseDetail(@PathVariable int id, Model model, HttpSession session, HttpServletRequest request) {
        // 조회수 증가 (세션 기반 중복 방지)
        String viewKey = "course_view_" + id;
        if (session.getAttribute(viewKey) == null) {
            courseService.incrementViewCount(id);
            session.setAttribute(viewKey, true);
            System.out.println("조회수 증가: 코스 ID " + id + " (세션: " + session.getId() + ")");
        } else {
            System.out.println("조회수 증가 안함: 코스 ID " + id + " (이미 조회됨)");
        }
        
        // 데이터 조회
        Course course = courseService.getCourseByIdWithoutIncrement(id);
        System.out.println("조회된 코스: " + (course != null ? "ID=" + course.getId() + ", 제목=" + course.getTitle() : "null"));
        
        if (course == null) {
            System.out.println("코스 ID " + id + "에 해당하는 코스를 찾을 수 없습니다.");
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
        
        System.out.println("Model에 추가되는 course 객체: " + (course != null ? "ID=" + course.getId() + ", 제목=" + course.getTitle() : "null"));
        model.addAttribute("course", course);
        model.addAttribute("courseSteps", courseSteps);
        model.addAttribute("likeCount", reactionCounts.get("likeCount"));
        model.addAttribute("dislikeCount", reactionCounts.get("dislikeCount"));
        model.addAttribute("currentReaction", currentReaction);
        model.addAttribute("userKey", userKey);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "pullcourse/courseDetail.jsp");
        return "index";
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
            System.out.println("=== 코스 등록 시작 ===");
            
            // 코스 기본 정보 추출
            Course course = new Course();
            String title = request.getParameter("title");
            String summary = request.getParameter("summary");
            String nickname = request.getParameter("nickname");
            
            System.out.println("제목: " + title);
            System.out.println("요약: " + summary);
            System.out.println("닉네임: " + nickname);
            
            course.setTitle(title);
            course.setSummary(summary);
            course.setNickname(nickname);
            course.setAuthorUserid("anonymous"); // 임시 사용자 ID
            
            // 사용자 ID 결정 (로그인된 사용자면 userid, 아니면 IP)
            String userId = determineUserId(request);
            course.setUserId(userId);
            System.out.println("설정된 사용자 ID: " + userId);
            
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
                    System.out.println("steps[].stepNo로 찾은 스텝 개수: " + stepCount);
                }
            }
            
            System.out.println("스텝 개수: " + stepCount);
            
            // 모든 파라미터 로깅
            System.out.println("=== 모든 파라미터 ===");
            request.getParameterMap().forEach((key, values) -> {
                System.out.println(key + ": " + String.join(", ", values));
            });
            System.out.println("=== 파라미터 로깅 완료 ===");
            
            // 모든 파일 파라미터 로깅
            System.out.println("=== 모든 파일 파라미터 ===");
            request.getFileMap().forEach((key, file) -> {
                System.out.println("파일 파라미터: " + key + " -> " + (file != null ? file.getOriginalFilename() : "null"));
            });
            System.out.println("=== 파일 파라미터 로깅 완료 ===");
            

            
                                     // steps[].stepNo 형태로 전송된 경우 처리
            String[] stepNoParams = request.getParameterValues("steps[].stepNo");
            String[] placeIdParams = request.getParameterValues("steps[].placeId");
            String[] placeNameParams = request.getParameterValues("steps[].placeName");
            String[] descriptionParams = request.getParameterValues("steps[].description");
            
            if (stepNoParams != null && placeIdParams != null && stepNoParams.length > 0) {
                System.out.println("steps[].stepNo로 찾은 스텝 개수: " + stepNoParams.length);
                 
                 System.out.println("분리된 스텝 데이터:");
                 System.out.println("stepNoParams: " + String.join(", ", stepNoParams));
                 System.out.println("placeIdParams: " + String.join(", ", placeIdParams));
                 System.out.println("placeNameParams: " + String.join(", ", placeNameParams));
                 System.out.println("descriptionParams: " + String.join(", ", descriptionParams));
                 
                 // 배열 길이 확인 및 조정
                 int maxLength = Math.max(stepNoParams.length, placeIdParams.length);
                 System.out.println("처리할 스텝 개수: " + maxLength);
                 
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
                             System.out.println("스텝 " + (i+1) + "의 placeId: " + step.getPlaceId());
                         } else {
                             System.out.println("스텝 " + (i+1) + "의 placeId가 비어있습니다.");
                             continue;
                         }
                     } else {
                         System.out.println("스텝 " + (i+1) + "의 placeId가 없습니다.");
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
                     
                     System.out.println("스텝 " + (i+1) + " 정보: stepNo=" + step.getStepNo() + ", placeId=" + step.getPlaceId() + ", placeName=" + step.getPlaceName() + ", description=" + step.getDescription());
                 
                     // 파일 처리 - MultipartFile 방식으로 복원
                     MultipartFile photoFile = null;
                     
                     System.out.println("스텝 " + (i+1) + " 파일 처리 시작");
                     
                     // 모든 파일 파라미터 로깅
                     System.out.println("=== 스텝 " + (i+1) + " 파일 파라미터 확인 ===");
                     request.getFileMap().forEach((key, file) -> {
                         System.out.println("파일 키: " + key + " -> " + (file != null ? file.getOriginalFilename() : "null"));
                     });
                     
                     // getFiles()를 사용하여 모든 파일을 가져와서 순서대로 처리
                     List<MultipartFile> allFiles = request.getFiles("steps[].photo");
                     System.out.println("getFiles('steps[].photo') 결과: " + allFiles.size() + "개 파일");
                     
                     if (i < allFiles.size()) {
                         photoFile = allFiles.get(i);
                         System.out.println("스텝 " + (i+1) + " 파일 찾음: " + photoFile.getOriginalFilename());
                     } else {
                         System.out.println("스텝 " + (i+1) + " 파일 없음");
                     }
                     
                     System.out.println("파일 존재 여부: " + (photoFile != null));
                     if (photoFile != null) {
                         System.out.println("파일 크기: " + photoFile.getSize());
                         System.out.println("파일명: " + photoFile.getOriginalFilename());
                         System.out.println("파일이 비어있지 않음: " + !photoFile.isEmpty());
                     }
                     
                     if (photoFile != null && !photoFile.isEmpty()) {
                         // Spring Boot의 ResourceLoader를 사용하여 안전한 경로 설정
                         try {
                             String uploadDir;
                             // 프로젝트 루트 디렉토리 찾기
                             File projectRoot = new File(System.getProperty("user.dir"));
                             
                             // target/classes에서 실행되는 경우 프로젝트 루트로 이동
                             if (projectRoot.getAbsolutePath().contains("target")) {
                                 projectRoot = projectRoot.getParentFile().getParentFile();
                             }
                             
                             uploadDir = projectRoot.getAbsolutePath() + File.separator + "src" + File.separator + "main" + File.separator + "webapp" + File.separator + "uploads" + File.separator + "course" + File.separator;
                             
                             System.out.println("프로젝트 루트: " + projectRoot.getAbsolutePath());
                             System.out.println("업로드 디렉토리: " + uploadDir);
                         
                             File dir = new File(uploadDir);
                             System.out.println("디렉토리 존재 여부: " + dir.exists());
                             System.out.println("디렉토리 절대 경로: " + dir.getAbsolutePath());
                             
                             if (!dir.exists()) {
                                 boolean created = dir.mkdirs();
                                 System.out.println("디렉토리 생성 시도 결과: " + created);
                                 if (!created) {
                                     System.out.println("업로드 디렉토리 생성 실패: " + uploadDir);
                                     // 대체 경로 시도
                                     uploadDir = projectRoot.getAbsolutePath() + File.separator + "uploads" + File.separator + "course" + File.separator;
                                     dir = new File(uploadDir);
                                     if (!dir.exists()) {
                                         dir.mkdirs();
                                     }
                                 }
                             }
                         
                         // 파일명 생성 (타임스탬프 + 스텝번호 + 랜덤값 + 원본파일명)
                         String originalFilename = photoFile.getOriginalFilename();
                         String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
                         String newFilename = System.currentTimeMillis() + "_" + step.getStepNo() + "_" + (int)(Math.random() * 1000) + fileExtension;
                         
                         // 파일 저장
                         File dest = new File(uploadDir + newFilename);
                         System.out.println("저장할 파일 경로: " + dest.getAbsolutePath());
                         
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
                             
                             System.out.println("파일 저장 성공: " + dest.getAbsolutePath());
                             
                             // 데이터베이스에 저장할 경로 설정
                             step.setPhotoUrl("/uploads/course/" + newFilename);
                             System.out.println("DB에 저장할 URL: " + step.getPhotoUrl());
                         } catch (IOException e) {
                             System.out.println("파일 저장 실패: " + e.getMessage());
                             e.printStackTrace();
                             System.out.println("파일 크기: " + photoFile.getSize());
                             System.out.println("파일명: " + photoFile.getOriginalFilename());
                             System.out.println("업로드 디렉토리 쓰기 권한 확인 필요");
                             // 파일 저장 실패해도 스텝은 계속 진행
                         }
                     } catch (Exception e) {
                         System.out.println("경로 설정 실패: " + e.getMessage());
                         e.printStackTrace();
                     }
                 } else {
                     System.out.println("스텝 " + (i+1) + " 파일 없음");
                 }
                 
                 courseSteps.add(step);
                 System.out.println("스텝 " + (i+1) + " 추가 완료, 현재 courseSteps 크기: " + courseSteps.size());
                 }
             }
            
            System.out.println("최종 courseSteps 크기: " + courseSteps.size());
            
            // 코스 등록
            System.out.println("코스 등록 서비스 호출 시작");
            int courseId = courseService.createCourse(course, courseSteps);
            System.out.println("코스 등록 결과 - courseId: " + courseId);
            
            if (courseId > 0) {
                System.out.println("=== 코스 등록 성공 ===");
                return "success";
            } else {
                System.out.println("=== 코스 등록 실패 (courseId <= 0) ===");
                return "error";
            }
        } catch (Exception e) {
            System.out.println("=== 코스 등록 예외 발생 ===");
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
                comment.setPasswdHash(password);
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
    public Map<String, Object> getComments(@PathVariable int courseId,
                                          @RequestParam(defaultValue = "latest") String sort) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<CourseComment> comments = courseCommentService.getParentCommentsByCourseId(courseId);
            
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
    public Map<String, Object> getReplies(@PathVariable int courseId,
                                         @RequestParam int parentId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<CourseComment> replies = courseCommentService.getRepliesByParentId(parentId);
            
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
    public List<Map<String, Object>> searchHotplaces(@RequestParam String keyword) {
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
}
