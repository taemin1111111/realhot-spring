package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Course;
import com.wherehot.spring.entity.CourseStep;
import com.wherehot.spring.entity.Region;
import com.wherehot.spring.service.CourseService;
import com.wherehot.spring.service.RegionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
public class CourseController {
    
    @Autowired
    private CourseService courseService;
    
    @Autowired
    private RegionService regionService;
    
    // 코스 목록 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/course")
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
    @GetMapping("/course/{id}")
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
    @GetMapping("/course/create")
    public String courseCreateForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "pullcourse/courseCreate.jsp");
        return "index";
    }
    
    // 코스 등록 처리
    @PostMapping("/course/create")
    @ResponseBody
    public String createCourse(@RequestBody Course course) {
        try {
            // 임시로 성공 응답 (실제 구현 시 courseSteps도 함께 처리)
            return "success";
        } catch (Exception e) {
            return "error";
        }
    }
    
    // 좋아요 처리
    @PostMapping("/course/{id}/like")
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
    @PostMapping("/course/{id}/dislike")
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
}
