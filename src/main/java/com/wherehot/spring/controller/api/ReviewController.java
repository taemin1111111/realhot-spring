package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Review;
import com.wherehot.spring.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;

/**
 * 리뷰 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/reviews")
public class ReviewController {
    
    private static final Logger logger = LoggerFactory.getLogger(ReviewController.class);
    
    @Autowired
    private ReviewService reviewService;
    
    /**
     * 모든 리뷰 조회 (페이징)
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllReviews(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Review> reviews = reviewService.findAllReviews(page, size);
        int totalCount = reviewService.getTotalReviewCount();
        
        Map<String, Object> result = new HashMap<>();
        result.put("reviews", reviews);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * ID로 리뷰 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<Review> getReviewById(@PathVariable int id) {
        Optional<Review> review = reviewService.findReviewById(id);
        return review.map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
    }
    
    /**
     * 핫플레이스별 리뷰 조회
     */
    @GetMapping("/hotplace/{hotplaceId}")
    public ResponseEntity<Map<String, Object>> getReviewsByHotplace(
            @PathVariable int hotplaceId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Review> reviews = reviewService.findReviewsByHotplace(hotplaceId, page, size);
        int totalCount = reviewService.getReviewCountByHotplace(hotplaceId);
        Double avgRating = reviewService.getAverageRatingByHotplace(hotplaceId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("reviews", reviews);
        result.put("totalCount", totalCount);
        result.put("averageRating", avgRating != null ? avgRating : 0.0);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("hotplaceId", hotplaceId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 지역별 리뷰 조회
     */
    @GetMapping("/region/{region}")
    public ResponseEntity<Map<String, Object>> getReviewsByRegion(
            @PathVariable String region,
            @RequestParam(defaultValue = "false") boolean isSigungu,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Review> reviews = reviewService.findReviewsByRegion(region, isSigungu, page, size);
        int totalCount = reviewService.getReviewCountByRegion(region, isSigungu);
        Double avgRating = reviewService.getAverageRatingByRegion(region, isSigungu);
        
        Map<String, Object> result = new HashMap<>();
        result.put("reviews", reviews);
        result.put("totalCount", totalCount);
        result.put("averageRating", avgRating != null ? avgRating : 0.0);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("region", region);
        result.put("isSigungu", isSigungu);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 추천 리뷰 조회
     */
    @GetMapping("/recommended")
    public ResponseEntity<List<Review>> getRecommendedReviews(@RequestParam(defaultValue = "10") int limit) {
        List<Review> reviews = reviewService.findRecommendedReviews(limit);
        return ResponseEntity.ok(reviews);
    }
    
    /**
     * 최신 리뷰 조회
     */
    @GetMapping("/recent")
    public ResponseEntity<List<Review>> getRecentReviews(@RequestParam(defaultValue = "10") int limit) {
        List<Review> reviews = reviewService.findRecentReviews(limit);
        return ResponseEntity.ok(reviews);
    }
    
    /**
     * 인기 리뷰 조회
     */
    @GetMapping("/popular")
    public ResponseEntity<List<Review>> getPopularReviews(@RequestParam(defaultValue = "10") int limit) {
        List<Review> reviews = reviewService.findPopularReviews(limit);
        return ResponseEntity.ok(reviews);
    }
    
    /**
     * 평점별 리뷰 조회
     */
    @GetMapping("/rating/{rating}")
    public ResponseEntity<Map<String, Object>> getReviewsByRating(
            @PathVariable int rating,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Review> reviews = reviewService.findReviewsByRating(rating, page, size);
        int totalCount = reviewService.getReviewCountByRating(rating);
        
        Map<String, Object> result = new HashMap<>();
        result.put("reviews", reviews);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("rating", rating);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 작성자별 리뷰 조회
     */
    @GetMapping("/author/{authorId}")
    public ResponseEntity<Map<String, Object>> getReviewsByAuthor(
            @PathVariable String authorId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        List<Review> reviews = reviewService.findReviewsByAuthor(authorId, page, size);
        int totalCount = reviewService.getReviewCountByAuthor(authorId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("reviews", reviews);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / size));
        result.put("authorId", authorId);
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * 리뷰 등록 (현대적인 REST API 방식)
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createReview(
            @RequestParam int regionid,
            @RequestParam int categoryid,
            @RequestParam double stars,
            @RequestParam String content,
            @RequestParam(required = false) String nickname,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 평점 유효성 검사
            if (stars < 1.0 || stars > 5.0) {
                response.put("success", false);
                response.put("message", "평점은 1-5 사이여야 합니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 시군구 체크는 나중에 구현
            // TODO: 시군구 체크 로직 추가
            
            // 중복 리뷰 체크는 나중에 구현
            // TODO: 중복 리뷰 체크 로직 추가
            
            // 리뷰 생성
            Review review = new Review();
            review.setHg_id(String.valueOf(regionid)); // hg_id에 지역 ID 저장
            review.setCategory_id(categoryid);
            review.setStars(stars);
            review.setContent(content);
            
            String authorId = userDetails != null ? userDetails.getUsername() : null;
            review.setUserid(authorId);
            
            if (nickname != null && !nickname.trim().isEmpty()) {
                review.setNickname(nickname.trim());
            } else if (userDetails != null) {
                review.setNickname(userDetails.getUsername());
            }
            
            Review savedReview = reviewService.saveReview(review);
            
            if (savedReview != null) {
                response.put("success", true);
                response.put("message", "리뷰가 성공적으로 등록되었습니다.");
                response.put("review", savedReview);
            } else {
                response.put("success", false);
                response.put("message", "리뷰 등록에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "리뷰 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 리뷰 추천 처리 (/review/recommendAction.jsp 대체)
     * Model1과 동일한 기능: 중복 추천 체크, 로그인/IP 기반 제한
     */
    @PostMapping("/{id}/recommend")
    public ResponseEntity<Map<String, Object>> recommendReview(@PathVariable int id, HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<Review> reviewOpt = reviewService.findReviewById(id);
            if (reviewOpt.isEmpty()) {
                response.put("success", false);
                response.put("message", "리뷰를 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 사용자 식별: 로그인한 사용자 ID 또는 IP 주소 (Model1과 동일한 로직)
            String userid = (String) request.getSession().getAttribute("loginid");
            if (userid == null || userid.trim().isEmpty()) {
                userid = request.getRemoteAddr(); // 비로그인 시 IP를 userid로 사용
            }
            
            // 중복 추천 체크
            boolean alreadyRecommended = reviewService.hasAlreadyRecommended(id, userid);
            if (alreadyRecommended) {
                response.put("success", false);
                response.put("message", "이미 추천하셨습니다.");
                return ResponseEntity.ok(response);
            }
            
            // 추천 처리
            boolean recommendSuccess = reviewService.addRecommendation(id, userid);
            if (recommendSuccess) {
                // 업데이트된 리뷰 정보 조회
                Optional<Review> updatedReviewOpt = reviewService.findReviewById(id);
                if (updatedReviewOpt.isPresent()) {
                    Review updatedReview = updatedReviewOpt.get();
                    response.put("success", true);
                    response.put("good", updatedReview.getGood());
                } else {
                    response.put("success", false);
                    response.put("message", "추천 후 정보 조회에 실패했습니다.");
                }
            } else {
                response.put("success", false);
                response.put("message", "추천 실패");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (NumberFormatException e) {
            response.put("success", false);
            response.put("message", "잘못된 리뷰 ID입니다.");
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            logger.error("Error processing review recommendation: reviewId={}, error={}", id, e.getMessage(), e);
            response.put("success", false);
            response.put("message", "추천 처리 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 지역명 목록 조회 (/review/getRegionNames.jsp 대체)
     */
    @GetMapping("/regions/names")
    public ResponseEntity<List<String>> getRegionNames() {
        try {
            List<String> regionNames = reviewService.getAllRegionNames();
            return ResponseEntity.ok(regionNames);
        } catch (Exception e) {
            logger.error("Error getting region names", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 리뷰가 등록된 지역 목록 조회 API
     */
    @GetMapping("/regions/with-reviews")
    public ResponseEntity<List<String>> getRegionsWithReviews() {
        try {
            List<String> regions = reviewService.findRegionsWithReviews();
            return ResponseEntity.ok(regions);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new ArrayList<>());
        }
    }

    /**
     * 인기 지역 목록 조회 API
     */
    @GetMapping("/regions/popular")
    public ResponseEntity<List<String>> getPopularRegions() {
        try {
            List<String> popularRegions = reviewService.findPopularRegions();
            return ResponseEntity.ok(popularRegions);
        } catch (Exception e) {
            // 예외 발생 시 로깅
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new ArrayList<>());
        }
    }
    
    /**
     * 지역별 데이터 조회 API (리뷰 목록, 평균 평점, 리뷰 수)
     */
    @GetMapping("/regions/data")
    public ResponseEntity<Map<String, Object>> getRegionData(
            @RequestParam String region,
            @RequestParam(defaultValue = "false") boolean isSigungu,
            @RequestParam(defaultValue = "0") int category) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 지역별 리뷰 조회
            List<Review> reviews = reviewService.findReviewsByRegion(region, category);
            
            // 평균 평점 계산
            double avgRating = reviews.stream()
                    .mapToDouble(review -> review.getStars() > 0 ? review.getStars() : 0.0)
                    .average()
                    .orElse(0.0);
            
            response.put("reviews", reviews);
            response.put("avgRating", avgRating);
            response.put("totalCount", reviews.size());
            response.put("region", region);
            response.put("isSigungu", isSigungu);
            response.put("category", category);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Error getting region data: region={}, isSigungu={}, category={}", region, isSigungu, category, e);
            response.put("reviews", new ArrayList<>());
            response.put("avgRating", 0.0);
            response.put("totalCount", 0);
            response.put("error", "지역 데이터를 불러올 수 없습니다.");
            return ResponseEntity.ok(response);
        }
    }
    
    /**
     * 리뷰 수정
     */
    @PutMapping("/{id}")
    public ResponseEntity<Review> updateReview(@PathVariable int id,
                                             @RequestBody Review review,
                                             @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 리뷰 조회
            Optional<Review> existingReview = reviewService.findReviewById(id);
            if (existingReview.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인
            if (userDetails == null || !existingReview.get().getUserid().equals(userDetails.getUsername())) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            review.setNum(id);
            Review updatedReview = reviewService.updateReview(review);
            return ResponseEntity.ok(updatedReview);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 리뷰 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReview(@PathVariable int id,
                                           @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 기존 리뷰 조회
            Optional<Review> existingReview = reviewService.findReviewById(id);
            if (existingReview.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            // 작성자 권한 확인 (또는 관리자)
            if (userDetails == null || (!existingReview.get().getUserid().equals(userDetails.getUsername()) 
                && !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN")))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean deleted = reviewService.deleteReview(id);
            return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 좋아요 처리
     */
    @PostMapping("/{id}/like")
    public ResponseEntity<Map<String, Object>> likeReview(@PathVariable int id) {
        try {
            Optional<Review> review = reviewService.findReviewById(id);
            if (review.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            
            int newLikeCount = review.get().getGood() + 1;
            boolean updated = reviewService.updateLikeCount(id, newLikeCount);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", updated);
            result.put("likeCount", newLikeCount);
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 추천 리뷰 설정/해제
     */
    @PatchMapping("/{id}/recommend")
    public ResponseEntity<Void> toggleRecommend(@PathVariable int id,
                                              @RequestParam boolean isRecommended,
                                              @AuthenticationPrincipal UserDetails userDetails) {
        try {
            // 관리자 권한 확인
            if (userDetails == null || !userDetails.getAuthorities().stream().anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            boolean updated = reviewService.updateRecommendedStatus(id, isRecommended);
            return updated ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    /**
     * 평점별 통계
     */
    @GetMapping("/statistics/rating")
    public ResponseEntity<List<Map<String, Object>>> getRatingStatistics() {
        List<Map<String, Object>> statistics = reviewService.getRatingStatistics();
        return ResponseEntity.ok(statistics);
    }
    
    /**
     * 지역별 통계
     */
    @GetMapping("/statistics/region")
    public ResponseEntity<List<Map<String, Object>>> getRegionStatistics() {
        List<Map<String, Object>> statistics = reviewService.getRegionStatistics();
        return ResponseEntity.ok(statistics);
    }
    
    /**
     * 카테고리별 통계
     */
    @GetMapping("/statistics/category")
    public ResponseEntity<List<Map<String, Object>>> getCategoryStatistics() {
        List<Map<String, Object>> statistics = reviewService.getCategoryStatistics();
        return ResponseEntity.ok(statistics);
    }
    
    /**
     * 월별 통계
     */
    @GetMapping("/statistics/monthly")
    public ResponseEntity<List<Map<String, Object>>> getMonthlyStatistics() {
        List<Map<String, Object>> statistics = reviewService.getMonthlyStatistics();
        return ResponseEntity.ok(statistics);
    }
}
