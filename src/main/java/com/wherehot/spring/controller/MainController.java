package com.wherehot.spring.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.RequestParam;

import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.entity.Category;
import com.wherehot.spring.entity.Post;
import com.wherehot.spring.service.HotplaceService;
import com.wherehot.spring.service.CategoryService;
// import com.wherehot.spring.service.VoteService; // TODO: VoteService 구현 후 활성화
// import com.wherehot.spring.service.WishListService; // TODO: WishListService 구현 후 활성화
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
    
    // TODO: VoteService 구현 후 활성화
    // @Autowired
    // private VoteService voteService;
    
    // TODO: WishListService 구현 후 활성화
    // @Autowired
    // private WishListService wishListService;
    
    @Autowired
    private RegionService regionService;
    

    @Autowired
    private PostService postService;

    @GetMapping("/")
    public String index(@RequestParam(value = "main", required = false) String main, 
                       Model model) {
        // 기존 index.jsp의 로직을 그대로 유지 - 기본은 main.jsp
        String mainPage = "main.jsp";  // 기본값: WEB-INF/views/main/main.jsp를 가리킴
        if (main != null && !main.isEmpty()) {
            mainPage = main;  // 메뉴에서 온 경우: review/gpaform.jsp, community/cumain.jsp 등
        }
        
        // 디버깅 로그 추가
        logger.info("MainController - main parameter: {}, mainPage: {}", main, mainPage);
        
        model.addAttribute("mainPage", mainPage);
        
        // main.jsp가 선택된 경우 필요한 데이터를 전달
        if ("main.jsp".equals(mainPage)) {
            loadMainPageData(model);
        }
        
        return "index";
    }
    
    @GetMapping("/index.jsp")
    public String indexJsp(@RequestParam(value = "main", required = false) String main, 
                          Model model) {
        // 기존 JSP 호출 방식과의 호환성을 위해
        return index(main, model);
    }
    
    /**
     * 투표 페이지 (nowhot.jsp)
     */
    @GetMapping("/main/nowhot.jsp")
    public String nowhot(Model model) {
        try {
            // 카테고리 목록 로드
            List<Category> categoryList = categoryService.findAllCategories();
            model.addAttribute("categoryList", categoryList);
            
        } catch (Exception e) {
            logger.error("nowhot.jsp 데이터 로드 실패: {}", e.getMessage());
            model.addAttribute("categoryList", new ArrayList<>());
        }
        
        return "main/nowhot";
    }
    
    /**
     * main.jsp에 필요한 데이터 로드 - JWT 기반 인증으로 변경
     */
    private void loadMainPageData(Model model) {
        // 변수들을 메서드 시작 부분에서 선언 (범위 문제 해결)
        List<Hotplace> hotplaceList = new ArrayList<>();
        List<String> regionNameList = new ArrayList<>();
        
        try {
            // 1. 핫플레이스 목록 조회 (장르 정보 포함) - 오류 발생 시 빈 리스트
            try {
                hotplaceList = hotplaceService.findAllHotplaces();
                // 각 핫플레이스에 장르 정보는 별도로 조회하도록 변경
                // Model1 DTO 구조에 맞춰 Hotplace Entity는 기본 필드만 유지
                logger.info("핫플레이스 목록 로드 완료 - 총 {} 개", hotplaceList.size());
            } catch (Exception e) {
                logger.error("핫플레이스 목록 조회 실패: {}", e.getMessage());
                hotplaceList = new ArrayList<>(); // 빈 리스트로 대체
            }
            model.addAttribute("hotplaceList", hotplaceList);
            
            // 2. 시군구 중심좌표 조회 - 안전한 처리
            try {
                List<Map<String, Object>> sigunguCenterList = regionService.getAllSigunguCenters();
                model.addAttribute("sigunguCenterList", sigunguCenterList);
            } catch (Exception e) {
                logger.warn("시군구 중심좌표 조회 실패: {}", e.getMessage());
                model.addAttribute("sigunguCenterList", new ArrayList<>());
            }
            
            // 3. 시군구별 카테고리별 개수 조회 - 안전한 처리
            try {
                List<Map<String, Object>> sigunguCategoryCountList = regionService.getSigunguCategoryCounts();
                model.addAttribute("sigunguCategoryCountList", sigunguCategoryCountList);
            } catch (Exception e) {
                logger.warn("시군구별 카테고리 개수 조회 실패: {}", e.getMessage());
                model.addAttribute("sigunguCategoryCountList", new ArrayList<>());
            }
            
            // 4. 지역(동/구) 중심좌표 조회 - 안전한 처리
            try {
                List<Map<String, Object>> regionCenters = regionService.getAllRegionCenters();
                model.addAttribute("regionCenters", regionCenters);
            } catch (Exception e) {
                logger.warn("지역 중심좌표 조회 실패: {}", e.getMessage());
                model.addAttribute("regionCenters", new ArrayList<>());
            }
            
            // 5. 지역별 카테고리별 개수 조회 - 안전한 처리
            try {
                List<Map<String, Object>> regionCategoryCounts = regionService.getRegionCategoryCounts();
                model.addAttribute("regionCategoryCounts", regionCategoryCounts);
            } catch (Exception e) {
                logger.warn("지역별 카테고리 개수 조회 실패: {}", e.getMessage());
                model.addAttribute("regionCategoryCounts", new ArrayList<>());
            }
            
            // 6. 지역명 목록 조회 - 안전한 처리
            try {
                regionNameList = regionService.getAllRegionNames();
                model.addAttribute("regionNameList", regionNameList);
            } catch (Exception e) {
                logger.warn("지역명 목록 조회 실패: {}", e.getMessage());
                regionNameList = new ArrayList<>();
                model.addAttribute("regionNameList", regionNameList);
            }
            
            // 7. 핫플레이스명 목록 조회 - 안전한 처리
            try {
                List<String> hotplaceNameList = hotplaceService.findAllHotplaceNames();
                model.addAttribute("hotplaceNameList", hotplaceNameList);
            } catch (Exception e) {
                logger.warn("핫플레이스명 목록 조회 실패: {}", e.getMessage());
                model.addAttribute("hotplaceNameList", new ArrayList<>());
            }
            
            // 8. 지역별 평균 평점 조회 - 안전한 처리
            try {
                Map<String, Double> regionRatings = regionService.getRegionAverageRatings();
                model.addAttribute("regionRatings", regionRatings);
            } catch (Exception e) {
                logger.warn("지역별 평균 평점 조회 실패: {}", e.getMessage());
                model.addAttribute("regionRatings", new HashMap<>());
            }
            
            // 9. 동/구별 ID 매핑 조회 - 안전한 처리
            try {
                Map<String, Integer> dongToRegionIdMapping = regionService.getDongToRegionIdMapping();
                model.addAttribute("dongToRegionIdMapping", dongToRegionIdMapping);
            } catch (Exception e) {
                logger.warn("동/구별 ID 매핑 조회 실패: {}", e.getMessage());
                model.addAttribute("dongToRegionIdMapping", new HashMap<>());
            }
            
            // 10. 카테고리 목록 조회 (nowhot.jsp용) - 안전한 처리
            try {
                List<Category> categoryList = categoryService.findAllCategories();
                model.addAttribute("categoryList", categoryList);
            } catch (Exception e) {
                logger.warn("카테고리 목록 조회 실패: {}", e.getMessage());
                model.addAttribute("categoryList", new ArrayList<>());
            }
            
            // 11. 헌팅썰 인기글 조회 (hunting_popular.jsp용) - 안전한 처리
            try {
                List<Post> popularPosts = postService.findPopularPosts(5);
                model.addAttribute("popularPosts", popularPosts);
            } catch (Exception e) {
                logger.warn("인기글 조회 실패: {}", e.getMessage());
                model.addAttribute("popularPosts", new ArrayList<>());
            }
            
            // 12. JWT 인증 정보 (클라이언트에서 처리)
            // JWT 토큰 기반 인증은 클라이언트 JavaScript에서 처리
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated() && 
                !authentication.getName().equals("anonymousUser")) {
                // 서버 사이드에서는 인증 여부만 확인
                model.addAttribute("isAuthenticated", true);
            } else {
                model.addAttribute("isAuthenticated", false);
            }
            
            // 13. 성능 최적화를 위한 캐싱 헤더 추가
            model.addAttribute("cacheTimestamp", System.currentTimeMillis());
            
            logger.info("Main page data loaded successfully. Hotplaces: {}", 
                       hotplaceList.size());
            
        } catch (Exception e) {
            logger.error("Error loading main page data", e);
            // 에러 발생 시 빈 데이터로 초기화 (서비스 안정성 보장)
            initializeEmptyData(model);
        }
    }
    
    /**
     * 에러 발생 시 빈 데이터로 초기화 (서비스 연속성 보장)
     */
    private void initializeEmptyData(Model model) {
        model.addAttribute("hotplaceList", new ArrayList<>());
        model.addAttribute("sigunguCenterList", new ArrayList<>());
        model.addAttribute("sigunguCategoryCountList", new ArrayList<>());
        model.addAttribute("regionCenters", new ArrayList<>());
        model.addAttribute("regionCategoryCounts", new ArrayList<>());
        model.addAttribute("regionNameList", new ArrayList<>());
        model.addAttribute("hotplaceNameList", new ArrayList<>());
        model.addAttribute("regionRatings", new HashMap<>());
        model.addAttribute("dongToRegionIdMapping", new HashMap<>());
        model.addAttribute("cacheTimestamp", System.currentTimeMillis());
    }

    // 메인 페이지 액션들은 별도 REST API로 전환 예정
}
