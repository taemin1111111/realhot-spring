package com.wherehot.spring.controller.api;

import com.wherehot.spring.entity.Review;
import com.wherehot.spring.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 리뷰 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/reviews")
public class ReviewController {
    
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
     * 리뷰 등록
     */
    @PostMapping
    public ResponseEntity<Review> createReview(@RequestBody Review review,
                                             @AuthenticationPrincipal UserDetails userDetails) {
        try {
            if (userDetails != null) {
                review.setAuthorId(userDetails.getUsername());
            }
            
            Review savedReview = reviewService.saveReview(review);
            return ResponseEntity.ok(savedReview);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
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
            if (userDetails == null || !existingReview.get().getAuthorId().equals(userDetails.getUsername())) {
                return ResponseEntity.status(403).build(); // Forbidden
            }
            
            review.setId(id);
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
            if (userDetails == null || (!existingReview.get().getAuthorId().equals(userDetails.getUsername()) 
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
            
            int newLikeCount = review.get().getLikeCount() + 1;
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
