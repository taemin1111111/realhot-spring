package com.wherehot.spring.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import jakarta.servlet.http.HttpServletRequest;

import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.entity.Category;
import com.wherehot.spring.entity.Post;
import com.wherehot.spring.service.HotplaceService;
import com.wherehot.spring.service.CategoryService;
import com.wherehot.spring.service.RegionService;
import com.wherehot.spring.service.PostService;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
public class MainController {

    private static final Logger logger = LoggerFactory.getLogger(MainController.class);

    @Autowired
    private HotplaceService hotplaceService;
    
    @Autowired
    private CategoryService categoryService;
    
    @Autowired
    private RegionService regionService;
    
    @Autowired
    private PostService postService;

    /**
     * 메인 페이지 (기본 페이지)
     */
    @GetMapping("/")
    public String index(Model model) {
        loadMainPageData(model);
        model.addAttribute("mainPage", "main/main.jsp");
        return "index";
    }
    
    /**
     * 기존 호환성을 위한 메서드 (/?main=page.jsp 방식)
     */
    @GetMapping("/index.jsp")
    public String indexJsp(@RequestParam(value = "main", required = false) String main, 
                          Model model, HttpServletRequest request) {
        // 기존 JSP 호출 방식과의 호환성을 위해
        if (main != null && !main.isEmpty()) {
            model.addAttribute("mainPage", main);
        } else {
            model.addAttribute("mainPage", "main/main.jsp");
            loadMainPageData(model);
        }
        return "index";
    }
    
    /**
     * main.jsp에 필요한 데이터 로드
     */
    private void loadMainPageData(Model model) {
        try {
            // 1. 핫플레이스 목록 조회
            List<Hotplace> hotplaceList = hotplaceService.findAllHotplaces();
            model.addAttribute("hotplaceList", hotplaceList);
            
            // 2. 시군구 중심좌표 조회
            List<Map<String, Object>> sigunguCenterList = regionService.getAllSigunguCenters();
            model.addAttribute("sigunguCenterList", sigunguCenterList);
            
            // 3. 시군구별 카테고리별 개수 조회
            List<Map<String, Object>> sigunguCategoryCountList = regionService.getSigunguCategoryCounts();
            model.addAttribute("sigunguCategoryCountList", sigunguCategoryCountList);
            
            // 4. 지역(동/구) 중심좌표 조회
            List<Map<String, Object>> regionCenters = regionService.getAllRegionCenters();
            model.addAttribute("regionCenters", regionCenters);
            
            // 5. 지역별 카테고리별 개수 조회
            List<Map<String, Object>> regionCategoryCounts = regionService.getRegionCategoryCounts();
            model.addAttribute("regionCategoryCounts", regionCategoryCounts);
            
            // 6. 지역명 목록 조회
            List<String> regionNameList = regionService.getAllRegionNames();
            model.addAttribute("regionNameList", regionNameList);
            
            // 7. 핫플레이스명 목록 조회
            List<String> hotplaceNameList = hotplaceService.findAllHotplaceNames();
            model.addAttribute("hotplaceNameList", hotplaceNameList);
            
            // 8. 동/구별 ID 매핑 조회
            Map<String, Integer> dongToRegionIdMapping = regionService.getDongToRegionIdMapping();
            model.addAttribute("dongToRegionIdMapping", dongToRegionIdMapping);
            
            // 9. 카테고리 목록 조회
            List<Category> categoryList = categoryService.findAllCategories();
            model.addAttribute("categoryList", categoryList);
            
            // 10. 헌팅썰 인기글 조회
            List<Post> popularPosts = postService.findPopularPosts(5);
            model.addAttribute("popularPosts", popularPosts);
            
            // 11. 인증 정보
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated() && 
                !authentication.getName().equals("anonymousUser")) {
                model.addAttribute("isAuthenticated", true);
            } else {
                model.addAttribute("isAuthenticated", false);
            }
            
            // 12. 캐싱 헤더
            model.addAttribute("cacheTimestamp", System.currentTimeMillis());
            
            logger.info("Main page data loaded successfully. Hotplaces: {}", hotplaceList.size());
            
        } catch (Exception e) {
            logger.error("Error loading main page data", e);
            initializeEmptyData(model);
        }
    }
    
    /**
     * 에러 발생 시 빈 데이터로 초기화
     */
    private void initializeEmptyData(Model model) {
        model.addAttribute("hotplaceList", new ArrayList<>());
        model.addAttribute("sigunguCenterList", new ArrayList<>());
        model.addAttribute("sigunguCategoryCountList", new ArrayList<>());
        model.addAttribute("regionCenters", new ArrayList<>());
        model.addAttribute("regionCategoryCounts", new ArrayList<>());
        model.addAttribute("regionNameList", new ArrayList<>());
        model.addAttribute("hotplaceNameList", new ArrayList<>());
        model.addAttribute("dongToRegionIdMapping", new HashMap<>());
        model.addAttribute("categoryList", new ArrayList<>());
        model.addAttribute("popularPosts", new ArrayList<>());
        model.addAttribute("isAuthenticated", false);
        model.addAttribute("cacheTimestamp", System.currentTimeMillis());
    }
}
