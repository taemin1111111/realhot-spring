package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Course;
import com.wherehot.spring.entity.CourseStep;
import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.entity.Region;
import com.wherehot.spring.service.CourseService;
import com.wherehot.spring.service.HotplaceService;
import com.wherehot.spring.service.RegionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/course")
public class CourseController {
    
    @Autowired
    private CourseService courseService;
    
    @Autowired
    private HotplaceService hotplaceService;
    
    @Autowired
    private RegionService regionService;
    
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
    public String courseDetail(@PathVariable int id, Model model) {
        Course course = courseService.getCourseById(id);
        List<CourseStep> courseSteps = courseService.getCourseSteps(id);
        
        model.addAttribute("course", course);
        model.addAttribute("courseSteps", courseSteps);
        
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
            

            
            // steps[].stepNo 형태로 전송된 경우 처리
            String stepNoParam = request.getParameter("steps[].stepNo");
            String placeIdParam = request.getParameter("steps[].placeId");
            String placeNameParam = request.getParameter("steps[].placeName");
            String descriptionParam = request.getParameter("steps[].description");
            
            if (stepNoParam != null && placeIdParam != null) {
                // 콤마로 구분된 값들을 배열로 분리
                String[] stepNos = stepNoParam.split(",");
                String[] placeIds = placeIdParam.split(",");
                String[] placeNames = placeNameParam != null ? placeNameParam.split(",") : new String[0];
                String[] descriptions = descriptionParam != null ? descriptionParam.split(",") : new String[0];
                
                for (int i = 0; i < stepNos.length; i++) {
                    CourseStep step = new CourseStep();
                    step.setStepNo(Integer.parseInt(stepNos[i].trim()));
                    
                    // placeId 설정
                    String placeIdStr = placeIds[i].trim();
                    if (placeIdStr != null && !placeIdStr.isEmpty()) {
                        step.setPlaceId(Integer.parseInt(placeIdStr));
                        System.out.println("스텝 " + (i+1) + "의 placeId: " + step.getPlaceId());
                    } else {
                        System.out.println("스텝 " + (i+1) + "의 placeId가 없습니다.");
                        continue;
                    }
                    
                    // description 설정
                    if (i < descriptions.length) {
                        step.setDescription(descriptions[i].trim());
                    }
                    
                    System.out.println("스텝 " + (i+1) + " 정보: stepNo=" + step.getStepNo() + ", placeId=" + step.getPlaceId() + ", description=" + step.getDescription());
                
                                         // 파일 처리
                     MultipartFile photoFile = request.getFile("steps[].photo");
                     if (photoFile != null && !photoFile.isEmpty()) {
                         // 파일 저장 경로 설정 (상대 경로 사용)
                         String uploadDir = "src/main/webapp/uploads/course/";
                         File dir = new File(uploadDir);
                         if (!dir.exists()) {
                             boolean created = dir.mkdirs();
                             if (!created) {
                                 System.out.println("업로드 디렉토리 생성 실패: " + uploadDir);
                                 // 대체 경로 시도
                                 uploadDir = "uploads/course/";
                                 dir = new File(uploadDir);
                                 if (!dir.exists()) {
                                     dir.mkdirs();
                                 }
                             }
                         }
                         
                         // 파일명 생성 (타임스탬프 + 원본파일명)
                         String originalFilename = photoFile.getOriginalFilename();
                         String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
                         String newFilename = System.currentTimeMillis() + "_" + i + fileExtension;
                         
                         // 파일 저장
                         File dest = new File(uploadDir + newFilename);
                         try {
                             photoFile.transferTo(dest);
                             System.out.println("파일 저장 성공: " + dest.getAbsolutePath());
                             
                             // 데이터베이스에 저장할 경로 설정
                             step.setPhotoUrl("/uploads/course/" + newFilename);
                         } catch (IOException e) {
                             System.out.println("파일 저장 실패: " + e.getMessage());
                             // 파일 저장 실패해도 스텝은 계속 진행
                         }
                     } else {
                         System.out.println("스텝 " + (i+1) + " 파일 없음");
                     }
                    
                    courseSteps.add(step);
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
    
    // 좋아요 처리
    @PostMapping("/{id}/like")
    @ResponseBody
    public String toggleLike(@PathVariable int id, @RequestParam boolean isLike) {
        try {
            courseService.toggleLike(id, isLike);
            return "success";
        } catch (Exception e) {
            return "error";
        }
    }
    
    // 싫어요 처리
    @PostMapping("/{id}/dislike")
    @ResponseBody
    public String toggleDislike(@PathVariable int id, @RequestParam boolean isDislike) {
        try {
            courseService.toggleDislike(id, isDislike);
            return "success";
        } catch (Exception e) {
            return "error";
        }
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
