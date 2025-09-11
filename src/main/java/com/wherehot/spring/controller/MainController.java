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
import com.wherehot.spring.entity.Category;
import com.wherehot.spring.entity.Region;
import com.wherehot.spring.entity.WishList;
import com.wherehot.spring.entity.ContentImage;
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
    private ClubGenreService clubGenreService;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private HpostService hpostService;

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
            List<com.wherehot.spring.entity.Hpost> popularHotplacePosts = hpostService.getPopularHpostList(0);
            if (popularHotplacePosts.size() > 5) {
                popularHotplacePosts = popularHotplacePosts.subList(0, 5);
            }
            model.addAttribute("popularHotplacePosts", popularHotplacePosts);
            
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
        model.addAttribute("popularHotplacePosts", new ArrayList<>());
        model.addAttribute("isAuthenticated", false);
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
                List<WishList> wishList = wishListService.findWishListByUser(userid, 0, 100);
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
    
    
}
