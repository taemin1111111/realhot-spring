package com.wherehot.spring.controller.api;

import com.wherehot.spring.service.WishListService;
import com.wherehot.spring.service.VoteService;
import com.wherehot.spring.service.ClubGenreService;
import com.wherehot.spring.service.ReviewService;
import com.wherehot.spring.service.ContentImageService;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.entity.ContentImages;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 메인 페이지 관련 REST API 컨트롤러
 * 기존 JSP Action 파일들을 REST API로 대체
 */
@RestController
@RequestMapping("/api/main")
@CrossOrigin(origins = "*", maxAge = 3600)
public class MainApiController {
    
    private static final Logger logger = LoggerFactory.getLogger(MainApiController.class);
    
    @Autowired
    private WishListService wishListService;
    
    @Autowired
    private VoteService voteService;
    
    @Autowired
    private ClubGenreService clubGenreService;
    
    @Autowired
    private ReviewService reviewService;
    
    @Autowired
    private ContentImageService contentImageService;
    
    @Autowired
    private AuthService authService;
    
    /**
     * 위시리스트 관련 액션 (/main/wishAction.jsp 대체)
     */
    @PostMapping("/wish")
    public ResponseEntity<Map<String, Object>> wishAction(
            @RequestParam String action,
            @RequestParam int placeId,
            HttpServletRequest request) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            String loginId = getUserIdFromToken(request);
            if (loginId == null) {
                result.put("result", false);
                result.put("message", "로그인이 필요합니다.");
                return ResponseEntity.ok(result);
            }
            
            switch (action) {
                case "add":
                    boolean added = wishListService.addWish(loginId, placeId);
                    result.put("result", added);
                    result.put("message", added ? "위시리스트에 추가되었습니다." : "추가에 실패했습니다.");
                    break;
                    
                case "remove":
                    boolean removed = wishListService.removeWish(loginId, placeId);
                    result.put("result", removed);
                    result.put("message", removed ? "위시리스트에서 제거되었습니다." : "제거에 실패했습니다.");
                    break;
                    
                case "check":
                    boolean exists = wishListService.isWished(loginId, placeId);
                    result.put("result", exists);
                    break;
                    
                default:
                    result.put("result", false);
                    result.put("message", "잘못된 액션입니다.");
            }
            
        } catch (Exception e) {
            result.put("result", false);
            result.put("message", "처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 위시리스트 개수 조회 (/main/getWishCount.jsp 대체)
     */
    @PostMapping("/wish-count")
    public ResponseEntity<Map<String, Object>> getWishCount(@RequestParam int placeId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            int count = wishListService.getWishCount(placeId);
            result.put("success", true);
            result.put("count", count);
        } catch (Exception e) {
            result.put("success", false);
            result.put("count", 0);
            result.put("message", e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 투표 관련 액션 (/main/voteAction.jsp 대체) - JWT 토큰 기반
     */
    @PostMapping("/vote")
    public ResponseEntity<Map<String, Object>> voteAction(
            @RequestParam int placeId,
            @RequestParam String congestion,
            @RequestParam String genderRatio,
            @RequestParam String waitTime,
            HttpServletRequest request) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            String loginId = getUserIdFromToken(request);
            String ipAddress = getClientIpAddress(request);
            
            // 로그인한 사용자 또는 IP 기반으로 투표 처리
            boolean voted = voteService.submitVote(loginId, placeId, congestion, genderRatio, waitTime, ipAddress);
            result.put("result", voted);
            result.put("message", voted ? "투표가 완료되었습니다." : "투표에 실패했습니다.");
            
        } catch (Exception e) {
            result.put("result", false);
            result.put("message", "투표 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 투표 현황 조회 (/main/getVoteTrends.jsp 대체)
     */
    @PostMapping("/vote-trends")
    public ResponseEntity<Map<String, Object>> getVoteTrends(@RequestParam int placeId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            Map<String, Object> trends = voteService.getVoteTrends(placeId);
            result.put("success", true);
            result.put("trends", trends);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 장르 편집 관련 액션 (/main/genreEditAction.jsp 대체) - JWT 토큰 기반
     */
    @PostMapping("/genre")
    public ResponseEntity<Map<String, Object>> genreEditAction(
            @RequestParam String action,
            @RequestParam int placeId,
            @RequestParam(required = false) Integer genreId,
            HttpServletRequest request) {
        
        return handleGenreAction(action, placeId, genreId, request);
    }
    
    /**
     * 장르 조회 (GET 방식 지원)
     */
    @GetMapping("/genre")
    public ResponseEntity<Map<String, Object>> genreGetAction(
            @RequestParam String action,
            @RequestParam int placeId,
            @RequestParam(required = false) Integer genreId,
            HttpServletRequest request) {
        
        return handleGenreAction(action, placeId, genreId, request);
    }
    
    /**
     * 장르 액션 처리 (공통 메서드)
     */
    private ResponseEntity<Map<String, Object>> handleGenreAction(
            String action, int placeId, Integer genreId, HttpServletRequest request) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            switch (action) {
                case "getGenres":
                    // 장르 목록 조회는 누구나 가능 (관리자 권한 불필요)
                    List<Map<String, Object>> genres = clubGenreService.getAllGenresWithSelection(placeId);
                    result.put("success", true);
                    result.put("genres", genres);
                    break;
                    
                case "add":
                case "remove":
                    // 장르 추가/제거는 관리자만 가능
                    String loginId = getUserIdFromToken(request);
                    if (loginId == null || !isAdminUser(request)) {
                        result.put("success", false);
                        result.put("message", "관리자 권한이 필요합니다.");
                        return ResponseEntity.ok(result);
                    }
                    
                    if ("add".equals(action)) {
                        if (genreId == null) {
                            result.put("success", false);
                            result.put("message", "장르 ID가 필요합니다.");
                            break;
                        }
                        boolean added = clubGenreService.addGenreToPlace(placeId, genreId);
                        result.put("success", added);
                        result.put("message", added ? "장르가 추가되었습니다." : "장르 추가에 실패했습니다.");
                    } else if ("remove".equals(action)) {
                        if (genreId == null) {
                            result.put("success", false);
                            result.put("message", "장르 ID가 필요합니다.");
                            break;
                        }
                        boolean removed = clubGenreService.removeGenreFromPlace(placeId, genreId);
                        result.put("success", removed);
                        result.put("message", removed ? "장르가 제거되었습니다." : "장르 제거에 실패했습니다.");
                    }
                    break;
                    
                default:
                    result.put("success", false);
                    result.put("message", "잘못된 액션입니다.");
            }
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "장르 편집 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 월별 통계 조회
     */
    @GetMapping("/monthly-statistics")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyStatistics() {
        try {
            List<Map<String, Object>> statistics = reviewService.getMonthlyStatistics();
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 모든 지역명 조회
     */
    @GetMapping("/regions")
    public ResponseEntity<List<String>> getAllRegionNames() {
        try {
            List<String> regions = reviewService.getAllRegionNames();
            return ResponseEntity.ok(regions);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 장소 이미지 조회 (/main/getPlaceImages.jsp 대체)
     */
    @GetMapping("/place-images")
    public ResponseEntity<Map<String, Object>> getPlaceImages(@RequestParam int placeId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            List<ContentImages> images = contentImageService.getImagesByHotplaceId(placeId);
            result.put("success", true);
            result.put("images", images);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "이미지 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 이미지 업로드 (/main/uploadImages.jsp 대체)
     */
    @PostMapping("/upload-images")
    public ResponseEntity<Map<String, Object>> uploadImages(
            @RequestParam("place_id") int placeId,
            @RequestParam("images") MultipartFile[] images,
            HttpServletRequest request) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 관리자 권한 확인 (JWT 토큰 기반)
            if (!isAdminUser(request)) {
                result.put("success", false);
                result.put("message", "관리자만 접근할 수 있습니다.");
                return ResponseEntity.ok(result);
            }
            
            // 웹앱 경로 가져오기
            String webappPath = request.getServletContext().getRealPath("/");
            
            result = contentImageService.uploadImages(placeId, images, webappPath);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "이미지 업로드 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 이미지 삭제 (/main/deleteImage.jsp 대체)
     */
    @PostMapping("/delete-image")
    public ResponseEntity<Map<String, Object>> deleteImage(
            @RequestParam int imageId,
            HttpServletRequest request) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 관리자 권한 확인 (JWT 토큰 기반)
            if (!isAdminUser(request)) {
                result.put("success", false);
                result.put("message", "관리자만 접근할 수 있습니다.");
                return ResponseEntity.ok(result);
            }
            
            // 웹앱 경로 가져오기
            String webappPath = request.getServletContext().getRealPath("/");
            
            result = contentImageService.deleteImage(imageId, webappPath);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "이미지 삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 대표 이미지 설정 (/main/setMainImage.jsp 대체)
     */
    @PostMapping("/set-main-image")
    public ResponseEntity<Map<String, Object>> setMainImage(
            @RequestParam int imageId,
            @RequestParam int placeId,
            HttpServletRequest request) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 관리자 권한 확인 (JWT 토큰 기반)
            if (!isAdminUser(request)) {
                result.put("success", false);
                result.put("message", "관리자만 접근할 수 있습니다.");
                return ResponseEntity.ok(result);
            }
            
            result = contentImageService.setMainImage(imageId, placeId);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "대표 이미지 설정 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
    
    // JWT 토큰 기반 유틸리티 메서드들
    
    /**
     * JWT 토큰에서 사용자 ID 추출 (없으면 null 반환)
     */
    private String getUserIdFromToken(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token != null) {
                // AuthService를 통해 토큰에서 사용자 정보 가져오기
                var member = authService.getUserFromToken(token);
                return member != null ? member.getUserid() : null;
            }
        } catch (Exception e) {
            logger.warn("Failed to extract user ID from token: {}", e.getMessage());
        }
        return null;
    }
    
    /**
     * 요청에서 JWT 토큰 추출
     */
    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
    
    /**
     * 클라이언트 IP 주소 가져오기
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    /**
     * JWT 토큰에서 관리자 권한 확인
     */
    private boolean isAdminUser(HttpServletRequest request) {
        try {
            String token = extractTokenFromRequest(request);
            if (token != null) {
                var member = authService.getUserFromToken(token);
                return member != null && "admin".equals(member.getProvider());
            }
        } catch (Exception e) {
            logger.warn("Failed to check admin status: {}", e.getMessage());
        }
        return false;
    }
}
