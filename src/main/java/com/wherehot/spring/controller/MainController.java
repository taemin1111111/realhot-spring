package com.wherehot.spring.controller;

import com.wherehot.spring.entity.ClubGenre;
import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.entity.Post;
import com.wherehot.spring.service.*;
import com.wherehot.spring.security.JwtUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.Optional;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.ResponseBody;
import com.wherehot.spring.service.WishListService;
import com.wherehot.spring.service.ContentImageService;
import com.wherehot.spring.service.VoteService;
import com.wherehot.spring.service.CourseService;
import com.wherehot.spring.service.ContentInfoService;
import com.wherehot.spring.service.AdBannerService;
import com.wherehot.spring.entity.Category;
import com.wherehot.spring.entity.Region;
import com.wherehot.spring.entity.WishList;
import com.wherehot.spring.entity.ContentImage;
import com.wherehot.spring.entity.ContentInfo;
import com.wherehot.spring.entity.AdBanner;
import org.springframework.web.multipart.MultipartFile;
import jakarta.servlet.http.HttpServletRequest;

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
    private WishListService wishListService;

    @Autowired
    private ContentImageService contentImageService;
    
    @Autowired
    private VoteService voteService;
    
    @Autowired
    private CourseService courseService;
    
    @Autowired
    private ContentInfoService contentInfoService;

    @Autowired
    private ClubGenreService clubGenreService;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private HpostService hpostService;
    
    @Autowired
    private AdBannerService adBannerService;

    /**
     * 메인 페이지 (기본 페이지)
     */
    @GetMapping("/")
    public String index(Model model) {
        try {
            // 메인 페이지 데이터 로딩
            logger.info("Main page requested - loading with database data");
            loadMainPageData(model);
            model.addAttribute("mainPage", "main/main.jsp");
            return "index";
        } catch (Exception e) {
            logger.error("Error loading main page data: ", e);
            model.addAttribute("error", "데이터 로딩 중 오류가 발생했습니다: " + e.getMessage());
            return "error";
        }
    }
    
    @GetMapping("/test")
    public String test(Model model) {
        model.addAttribute("message", "테스트 페이지입니다!");
        return "test";
    }
    
    /**
     * 기존 호환성을 위한 메서드 (/?main=page.jsp 방식)
     */
    @GetMapping("/index.jsp")
    public String indexJsp(@RequestParam(value = "main", required = false) String main, 
                          Model model, jakarta.servlet.http.HttpServletRequest request) {
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
     * 지도 전체 보기 페이지
     */
    @GetMapping("/map")
    public String mapPage(Model model) {
        loadMainPageData(model);
        model.addAttribute("mainPage", "main/map.jsp");
        return "index";
    }
    
    /**
     * 이용약관 페이지
     */
    @GetMapping("/terms")
    public String terms(Model model) {
        model.addAttribute("mainPage", "agreement.jsp");
        return "index";
    }
    
    /**
     * 개인정보처리방침 페이지
     */
    @GetMapping("/privacy")
    public String privacy(Model model) {
        model.addAttribute("mainPage", "service.jsp");
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
            
            // 10. 핫플썰 인기글 5위까지 조회
            List<com.wherehot.spring.entity.Hpost> popularHotplacePosts = hpostService.getPopularHpostList(0, 5);
            if (popularHotplacePosts.size() > 5) {
                popularHotplacePosts = popularHotplacePosts.subList(0, 5);
            }
            model.addAttribute("popularHotplacePosts", popularHotplacePosts);
            
            // 11. 코스 인기글 2위까지 조회
            List<com.wherehot.spring.entity.Course> popularCourses = courseService.getPopularCourseList(1);
            if (popularCourses.size() > 2) {
                popularCourses = popularCourses.subList(0, 2);
            }
            model.addAttribute("popularCourses", popularCourses);
            
            // 12. 활성화된 광고 배너 조회
            List<AdBanner> activeAdBanners = adBannerService.getActiveAdBanners();
            model.addAttribute("activeAdBanners", activeAdBanners);
            
            // 11. 인증 정보
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication != null && authentication.isAuthenticated() && 
                !authentication.getName().equals("anonymousUser")) {
                model.addAttribute("isAuthenticated", true);
                model.addAttribute("username", authentication.getName());
                
                // 관리자 권한 확인 (예: username이 "admin"인 경우)
                boolean isAdmin = "admin".equals(authentication.getName());
                model.addAttribute("isAdmin", isAdmin);
            } else {
                model.addAttribute("isAuthenticated", false);
                model.addAttribute("isAdmin", false);
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
        model.addAttribute("popularHotplacePosts", new ArrayList<>());
        model.addAttribute("popularCourses", new ArrayList<>());
        model.addAttribute("activeAdBanners", new ArrayList<>());
        model.addAttribute("isAuthenticated", false);
        model.addAttribute("isAdmin", false);
        model.addAttribute("cacheTimestamp", System.currentTimeMillis());
    }

    // 찜 목록 API (POST만 사용)
    @PostMapping("/api/main/wish")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getWishList(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestParam(value = "action", required = false) String action,
            @RequestParam(value = "placeId", required = false) Integer placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            String userid = null;
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                userid = jwtUtils.getUseridFromToken(token);
            }
            
            if ("check".equals(action) && placeId != null) {
                // 찜 여부 확인
                boolean isWished = wishListService.isWished(userid, placeId);
                response.put("result", isWished);
                return org.springframework.http.ResponseEntity.ok(response);
            } else if ("add".equals(action) && placeId != null) {
                // 찜 추가
                boolean success = wishListService.addWish(userid, placeId);
                response.put("result", success);
                return org.springframework.http.ResponseEntity.ok(response);
            } else if ("remove".equals(action) && placeId != null) {
                // 찜 제거
                boolean success = wishListService.removeWish(userid, placeId);
                response.put("result", success);
                return org.springframework.http.ResponseEntity.ok(response);
            } else {
                // 찜 목록 조회
                List<WishList> wishList = wishListService.findWishListByUser(userid, 1, 100);
                response.put("result", true);
                response.put("wishList", wishList);
                return org.springframework.http.ResponseEntity.ok(response);
            }
            
        } catch (Exception e) {
            logger.error("Wish list error: ", e);
            response.put("result", false);
            response.put("error", "찜 목록 조회 중 오류가 발생했습니다.");
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 장소 이미지 API
    @GetMapping("/api/main/place-images")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getPlaceImages(@RequestParam int placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("Getting images for placeId: {}", placeId);
            List<ContentImage> images = contentImageService.getImagesByContentId(placeId);
            logger.info("Found {} images for placeId: {}", images.size(), placeId);
            
            List<Map<String, Object>> imageData = new ArrayList<>();
            
            for (ContentImage image : images) {
                Map<String, Object> imageInfo = new HashMap<>();
                imageInfo.put("imagePath", image.getImagePath());
                imageInfo.put("id", image.getId());
                imageInfo.put("order", image.getImageOrder());
                imageData.add(imageInfo);
                logger.info("Image: id={}, path={}, order={}", image.getId(), image.getImagePath(), image.getImageOrder());
            }
            
            response.put("success", true);
            response.put("images", imageData);
            response.put("count", images.size());
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Place images error for placeId {}: ", placeId, e);
            response.put("success", false);
            response.put("error", "이미지 조회 중 오류가 발생했습니다: " + e.getMessage());
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 핫플레이스 이미지 업로드 API (관리자 전용)
    @PostMapping("/api/main/upload-images")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> uploadPlaceImages(
            @RequestParam("place_id") int placeId,
            @RequestParam("images") MultipartFile[] images,
            HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.getAuthorities().stream()
                    .anyMatch(authority -> authority.getAuthority().equals("ADMIN"))) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return org.springframework.http.ResponseEntity.status(403).body(response);
            }
            
            // 웹앱 경로 설정
            String webappPath = request.getSession().getServletContext().getRealPath("/");
            
            // 이미지 업로드 처리
            Map<String, Object> uploadResult = contentImageService.uploadImages(placeId, images, webappPath);
            
            if ((Boolean) uploadResult.get("success")) {
                response.put("success", true);
                response.put("message", uploadResult.get("message"));
                response.put("uploadedPaths", uploadResult.get("uploadedPaths"));
                return org.springframework.http.ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("error", uploadResult.get("message"));
                return org.springframework.http.ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            logger.error("Image upload error for placeId: {}, images: {}", placeId, images != null ? images.length : 0, e);
            response.put("success", false);
            response.put("error", "이미지 업로드 중 오류가 발생했습니다: " + e.getMessage());
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 찜 개수 API (POST만 사용)
    @PostMapping("/api/main/wish-count")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getWishCount(@RequestParam int placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            int count = wishListService.getWishCount(placeId);
            response.put("success", true);
            response.put("count", count);
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Wish count error: ", e);
            response.put("success", false);
            response.put("error", "찜 개수 조회 중 오류가 발생했습니다.");
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 가게별 코스 개수 API (인기 코스 정렬용)
    @PostMapping("/api/main/course-count")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getCourseCount(@RequestParam int placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            int count = courseService.getCourseCountByPlaceId(placeId);
            response.put("success", true);
            response.put("count", count);
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Course count error for placeId {}: ", placeId, e);
            response.put("success", false);
            response.put("error", "코스 개수 조회 중 오류가 발생했습니다.");
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 네이버 플레이스 링크 조회 API
    @PostMapping("/api/main/naver-place-link")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getNaverPlaceLink(@RequestParam int placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            ContentInfo contentInfo = contentInfoService.getContentInfoByHotplaceId(placeId);
            if (contentInfo != null && contentInfo.getContentText() != null && !contentInfo.getContentText().trim().isEmpty()) {
                response.put("success", true);
                response.put("link", contentInfo.getContentText().trim());
            } else {
                response.put("success", true);
                response.put("link", null);
            }
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Naver place link error for placeId {}: ", placeId, e);
            response.put("success", false);
            response.put("error", "네이버 플레이스 링크 조회 중 오류가 발생했습니다.");
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 네이버 플레이스 링크 저장/수정 API (관리자 전용)
    @PostMapping("/api/main/naver-place-link-save")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> saveNaverPlaceLink(
            @RequestParam("placeId") int placeId,
            @RequestParam(value = "link", required = false) String link,
            HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("Received request to save naver place link - placeId: {}, link: {}", placeId, link);
            
            // 관리자 권한 확인
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.getAuthorities().stream()
                    .anyMatch(authority -> authority.getAuthority().equals("ADMIN"))) {
                logger.warn("Admin permission required for saving naver place link");
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return org.springframework.http.ResponseEntity.status(403).body(response);
            }
            
            logger.info("Admin permission verified");
            
            // 링크 유효성 검증 (빈 문자열이나 null 허용)
            String processedLink = null;
            if (link != null && !link.trim().isEmpty()) {
                processedLink = link.trim();
                if (!processedLink.startsWith("http://") && !processedLink.startsWith("https://")) {
                    logger.warn("Invalid URL format: {}", processedLink);
                    response.put("success", false);
                    response.put("error", "올바른 URL 형식이 아닙니다.");
                    return org.springframework.http.ResponseEntity.badRequest().body(response);
                }
            }
            
            logger.info("Calling contentInfoService.saveOrUpdateContentInfo with placeId: {}, processedLink: {}", placeId, processedLink);
            boolean success = contentInfoService.saveOrUpdateContentInfo(placeId, processedLink);
            logger.info("Service call result: {}", success);
            
            if (success) {
                response.put("success", true);
                response.put("message", "네이버 플레이스 링크가 저장되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "네이버 플레이스 링크 저장에 실패했습니다.");
            }
            
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Save naver place link error for placeId {}: ", placeId, e);
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "네이버 플레이스 링크 저장 중 오류가 발생했습니다.");
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 투표 트렌드 API (POST만 사용) - 실제 데이터베이스에서 가져오기
    @PostMapping("/api/main/vote-trends")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getVoteTrends(@RequestParam(value = "placeId", required = false) Integer placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("=== /api/main/vote-trends called with placeId: {} ===", placeId);
            if (placeId != null) {
                // 실제 데이터베이스에서 투표 트렌드 가져오기
                Map<String, Object> trends = voteService.getVoteTrends(placeId);
                
                // 데이터가 없으면 기본값 설정
                if (trends == null || trends.isEmpty()) {
                    trends = new HashMap<>();
                    trends.put("congestion", "데이터없음");
                    trends.put("genderRatio", "데이터없음");
                    trends.put("waitTime", "데이터없음");
                }
                
                response.put("success", true);
                response.put("trends", trends);
                logger.info("=== /api/main/vote-trends response: placeId={}, trends={} ===", placeId, trends);
            } else {
                // 전체 투표 트렌드
                Map<String, Object> trends = new HashMap<>();
                trends.put("congestion", "데이터없음");
                trends.put("genderRatio", "데이터없음");
                trends.put("waitTime", "데이터없음");
                response.put("success", true);
                response.put("trends", trends);
            }
            
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Vote trends error: ", e);
            response.put("success", false);
            response.put("error", "투표 트렌드 조회 중 오류가 발생했습니다.");
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 투표 수 API (POST만 사용) - 특정 장소의 총 투표 수 조회
    @PostMapping("/api/main/vote-count")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getVoteCount(@RequestParam(value = "placeId", required = true) Integer placeId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("=== /api/main/vote-count called with placeId: {} ===", placeId);
            if (placeId != null) {
                // 실제 데이터베이스에서 투표 수 가져오기
                int voteCount = voteService.getVoteCount(placeId);
                
                response.put("success", true);
                response.put("voteCount", voteCount);
                logger.info("=== /api/main/vote-count response: placeId={}, voteCount={} ===", placeId, voteCount);
            } else {
                response.put("success", false);
                response.put("error", "placeId가 필요합니다.");
                return org.springframework.http.ResponseEntity.badRequest().body(response);
            }
            
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Vote count error: ", e);
            response.put("success", false);
            response.put("error", "투표 수 조회 중 오류가 발생했습니다.");
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 장르 목록 API (POST만 사용)
    @PostMapping("/api/main/genre")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getGenres(
            @RequestParam(value = "action", required = false) String action,
            @RequestParam(value = "placeId", required = false) Integer placeId,
            @RequestParam(value = "genreId", required = false) Integer genreId,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if ("getGenres".equals(action) && placeId != null) {
                // 특정 장소의 장르 정보 조회
                List<Map<String, Object>> genres = clubGenreService.getAllGenresWithSelection(placeId);
                
                response.put("success", true);
                response.put("genres", genres);
            } else if ("add".equals(action) && placeId != null && genreId != null) {
                // 장르 추가 (관리자 전용)
                // 관리자 권한 확인
                Authentication auth = SecurityContextHolder.getContext().getAuthentication();
                if (auth == null || !auth.getAuthorities().stream()
                        .anyMatch(authority -> authority.getAuthority().equals("ADMIN"))) {
                    response.put("success", false);
                    response.put("error", "관리자 권한이 필요합니다.");
                    return org.springframework.http.ResponseEntity.status(403).body(response);
                }
                
                boolean success = clubGenreService.addGenreToPlace(placeId, genreId);
                response.put("success", success);
                response.put("message", success ? "장르가 추가되었습니다." : "장르 추가에 실패했습니다.");
            } else if ("remove".equals(action) && placeId != null && genreId != null) {
                // 장르 제거 (관리자 전용)
                // 관리자 권한 확인
                Authentication auth = SecurityContextHolder.getContext().getAuthentication();
                if (auth == null || !auth.getAuthorities().stream()
                        .anyMatch(authority -> authority.getAuthority().equals("ADMIN"))) {
                    response.put("success", false);
                    response.put("error", "관리자 권한이 필요합니다.");
                    return org.springframework.http.ResponseEntity.status(403).body(response);
                }
                
                boolean success = clubGenreService.removeGenreFromPlace(placeId, genreId);
                response.put("success", success);
                response.put("message", success ? "장르가 제거되었습니다." : "장르 제거에 실패했습니다.");
            } else {
                // 전체 장르 목록 조회
                List<ClubGenre> genres = clubGenreService.getAllGenres();
                response.put("result", true);
                response.put("genres", genres);
            }
            
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Genre error: ", e);
            response.put("success", false);
            response.put("error", "장르 처리 중 오류가 발생했습니다: " + e.getMessage());
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 대표 사진 변경 API (관리자 전용)
    @PostMapping("/api/main/set-main-image")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> setMainImage(
            @RequestParam("imageId") int imageId,
            @RequestParam("placeId") int placeId,
            HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.getAuthorities().stream()
                    .anyMatch(authority -> authority.getAuthority().equals("ADMIN"))) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return org.springframework.http.ResponseEntity.status(403).body(response);
            }
            
            // 대표 사진 변경 처리
            Map<String, Object> result = contentImageService.setMainImage(imageId, placeId);
            
            if ((Boolean) result.get("success")) {
                response.put("success", true);
                response.put("message", result.get("message"));
                return org.springframework.http.ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("error", result.get("message"));
                return org.springframework.http.ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            logger.error("Set main image error for imageId: {}, placeId: {}", imageId, placeId, e);
            response.put("success", false);
            response.put("error", "대표 사진 변경 중 오류가 발생했습니다: " + e.getMessage());
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }
    
    // 이미지 삭제 API (관리자 전용)
    @PostMapping("/api/main/delete-image")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> deleteImage(
            @RequestParam("imageId") int imageId,
            HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || !auth.getAuthorities().stream()
                    .anyMatch(authority -> authority.getAuthority().equals("ADMIN"))) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return org.springframework.http.ResponseEntity.status(403).body(response);
            }
            
            // 웹앱 경로 설정
            String webappPath = request.getSession().getServletContext().getRealPath("/");
            
            // 이미지 삭제 처리
            Map<String, Object> result = contentImageService.deleteImage(imageId, webappPath);
            
            if ((Boolean) result.get("success")) {
                response.put("success", true);
                response.put("message", result.get("message"));
                return org.springframework.http.ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("error", result.get("message"));
                return org.springframework.http.ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            logger.error("Delete image error for imageId: {}", imageId, e);
            response.put("success", false);
            response.put("error", "이미지 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }

    // ========== 배치 API (성능 최적화) ==========
    
    /**
     * 장소 상세 정보 배치 조회 API (8개 API를 1개로 통합)
     * - 이미지, 위시리스트 개수, 투표 트렌드, 오늘핫 순위, 코스 개수, 투표 통계, 장르 정보, 네이버 플레이스 링크
     */
    @PostMapping("/api/main/place-details-batch")
    @ResponseBody
    public org.springframework.http.ResponseEntity<Map<String, Object>> getPlaceDetailsBatch(
            @RequestParam int placeId,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 인증 확인 (위시리스트용)
            String userid = null;
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                try {
                    String token = authHeader.substring(7);
                    userid = jwtUtils.getUseridFromToken(token);
                } catch (Exception e) {
                    // 토큰이 유효하지 않으면 익명 사용자로 처리
                }
            }
            
            // 1. 이미지 정보 조회
            List<ContentImage> images = contentImageService.getImagesByContentId(placeId);
            List<Map<String, Object>> imageList = new ArrayList<>();
            for (ContentImage img : images) {
                Map<String, Object> imgData = new HashMap<>();
                imgData.put("id", img.getId());
                imgData.put("imagePath", img.getImagePath());
                imgData.put("imageOrder", img.getImageOrder());
                imageList.add(imgData);
            }
            
            // 2. 위시리스트 개수 조회
            int wishCount = voteService.getWishCount(placeId);
            
            // 3. 투표 수 조회
            int voteCount = voteService.getVoteCount(placeId);
            
            // 4. 투표 트렌드 조회
            Map<String, Object> voteTrends = voteService.getVoteTrends(placeId);
            
            // 5. 코스 개수 조회 (임시로 0 반환)
            int courseCount = 0; // TODO: CourseService에 메서드 추가 필요
            
            // 6. 오늘핫 순위 조회 (임시로 0 반환)
            int todayHotRank = 0; // TODO: ContentInfoService에 메서드 추가 필요
            
            // 7. 장르 정보 조회 (클럽인 경우만)
            List<Map<String, Object>> genres = new ArrayList<>();
            Hotplace hotplace = hotplaceService.findHotplaceById(placeId).orElse(null);
            if (hotplace != null && hotplace.getCategoryId() == 1) { // 클럽인 경우
                // TODO: ClubGenreService에 getGenresByPlaceId 메서드 추가 필요
                // 임시로 빈 리스트 반환
            }
            
            // 8. 네이버 플레이스 링크 조회 (임시로 빈 문자열 반환)
            String naverPlaceLink = ""; // TODO: ContentInfoService에 메서드 추가 필요
            
            // 9. 사용자 위시리스트 여부 확인
            boolean isWished = false;
            if (userid != null) {
                isWished = voteService.isWished(placeId, userid);
            }
            
            // 응답 데이터 구성
            response.put("success", true);
            response.put("placeId", placeId);
            response.put("images", imageList);
            response.put("wishCount", wishCount);
            response.put("voteCount", voteCount);
            response.put("voteTrends", voteTrends);
            response.put("courseCount", courseCount);
            response.put("todayHotRank", todayHotRank);
            response.put("genres", genres);
            response.put("naverPlaceLink", naverPlaceLink);
            response.put("isWished", isWished);
            response.put("timestamp", System.currentTimeMillis());
            
            return org.springframework.http.ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Batch place details error for placeId: {}", placeId, e);
            response.put("success", false);
            response.put("error", "장소 정보 조회 중 오류가 발생했습니다: " + e.getMessage());
            return org.springframework.http.ResponseEntity.internalServerError().body(response);
        }
    }

    // ========== 광고 배너 관리 API ==========
    
    /**
     * 광고 배너 추가 (관리자용)
     */
    @PostMapping("/api/admin/ad-banner/add")
    @ResponseBody
    public Map<String, Object> addAdBanner(@RequestParam("title") String title,
                                          @RequestParam(value = "linkUrl", required = false) String linkUrl,
                                          @RequestParam("displayOrder") int displayOrder,
                                          @RequestParam("imageFile") MultipartFile imageFile,
                                          HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated() || 
                authentication.getName().equals("anonymousUser")) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return response;
            }
            
            AdBanner adBanner = new AdBanner();
            adBanner.setTitle(title);
            adBanner.setLinkUrl(linkUrl);
            adBanner.setDisplayOrder(displayOrder);
            
            int result = adBannerService.addAdBanner(adBanner, imageFile);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "광고 배너가 성공적으로 추가되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "광고 배너 추가에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("Add ad banner error", e);
            response.put("success", false);
            response.put("error", "광고 배너 추가 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * 광고 배너 수정 (관리자용)
     */
    @PostMapping("/api/admin/ad-banner/update")
    @ResponseBody
    public Map<String, Object> updateAdBanner(@RequestParam("adId") int adId,
                                             @RequestParam("title") String title,
                                             @RequestParam(value = "linkUrl", required = false) String linkUrl,
                                             @RequestParam("displayOrder") int displayOrder,
                                             @RequestParam(value = "imageFile", required = false) MultipartFile imageFile) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated() || 
                authentication.getName().equals("anonymousUser")) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return response;
            }
            
            AdBanner adBanner = new AdBanner();
            adBanner.setAdId(adId);
            adBanner.setTitle(title);
            adBanner.setLinkUrl(linkUrl);
            adBanner.setDisplayOrder(displayOrder);
            
            int result = adBannerService.updateAdBanner(adBanner, imageFile);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "광고 배너가 성공적으로 수정되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "광고 배너 수정에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("Update ad banner error", e);
            response.put("success", false);
            response.put("error", "광고 배너 수정 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * 광고 배너 삭제 (관리자용)
     */
    @PostMapping("/api/admin/ad-banner/delete")
    @ResponseBody
    public Map<String, Object> deleteAdBanner(@RequestParam("adId") int adId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated() || 
                authentication.getName().equals("anonymousUser")) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return response;
            }
            
            int result = adBannerService.deleteAdBanner(adId);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "광고 배너가 성공적으로 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "광고 배너 삭제에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("Delete ad banner error", e);
            response.put("success", false);
            response.put("error", "광고 배너 삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * 광고 배너 활성화/비활성화 토글 (관리자용)
     */
    @PostMapping("/api/admin/ad-banner/toggle")
    @ResponseBody
    public Map<String, Object> toggleAdBannerStatus(@RequestParam("adId") int adId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated() || 
                authentication.getName().equals("anonymousUser")) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return response;
            }
            
            int result = adBannerService.toggleAdBannerStatus(adId);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "광고 배너 상태가 변경되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "광고 배너 상태 변경에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("Toggle ad banner status error", e);
            response.put("success", false);
            response.put("error", "광고 배너 상태 변경 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * 광고 배너 순서 변경 (관리자용)
     */
    @PostMapping("/api/admin/ad-banner/order")
    @ResponseBody
    public Map<String, Object> updateAdBannerOrder(@RequestParam("adId") int adId,
                                                  @RequestParam("displayOrder") int displayOrder) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 확인
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated() || 
                authentication.getName().equals("anonymousUser")) {
                response.put("success", false);
                response.put("error", "관리자 권한이 필요합니다.");
                return response;
            }
            
            int result = adBannerService.updateDisplayOrder(adId, displayOrder);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "광고 배너 순서가 변경되었습니다.");
            } else {
                response.put("success", false);
                response.put("error", "광고 배너 순서 변경에 실패했습니다.");
            }
            
        } catch (Exception e) {
            logger.error("Update ad banner order error", e);
            response.put("success", false);
            response.put("error", "광고 배너 순서 변경 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * 활성화된 광고 배너 목록 조회 (API)
     */
    @GetMapping("/api/ad-banners/active")
    @ResponseBody
    public Map<String, Object> getActiveAdBannersApi() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<AdBanner> activeBanners = adBannerService.getActiveAdBanners();
            response.put("success", true);
            response.put("banners", activeBanners);
            
        } catch (Exception e) {
            logger.error("Get active ad banners API error", e);
            response.put("success", false);
            response.put("error", "광고 배너 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
}
