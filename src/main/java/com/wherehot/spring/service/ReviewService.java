package com.wherehot.spring.service;

import com.wherehot.spring.entity.Review;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 리뷰 서비스 인터페이스
 */
public interface ReviewService {
    
    /**
     * 모든 리뷰 조회 (페이징)
     */
    List<Review> findAllReviews(int page, int size);
    
    /**
     * ID로 리뷰 조회
     */
    Optional<Review> findReviewById(int id);
    
    /**
     * 핫플레이스별 리뷰 조회
     */
    List<Review> findReviewsByHotplace(int hotplaceId, int page, int size);
    
    /**
     * 작성자별 리뷰 조회
     */
    List<Review> findReviewsByAuthor(String authorId, int page, int size);
    
    /**
     * 지역별 리뷰 조회
     */
    List<Review> findReviewsByRegion(String region, boolean isSigungu, int page, int size);
    
    /**
     * 카테고리별 리뷰 조회
     */
    List<Review> findReviewsByCategory(int categoryId, int page, int size);
    
    /**
     * 평점별 리뷰 조회
     */
    List<Review> findReviewsByRating(int rating, int page, int size);
    
    /**
     * 추천 리뷰 조회
     */
    List<Review> findRecommendedReviews(int limit);
    
    /**
     * 최신 리뷰 조회
     */
    List<Review> findRecentReviews(int limit);
    
    /**
     * 인기 리뷰 조회
     */
    List<Review> findPopularReviews(int limit);
    
    /**
     * 리뷰 등록
     */
    Review saveReview(Review review);
    
    /**
     * 리뷰 수정
     */
    Review updateReview(Review review);
    
    /**
     * 리뷰 삭제
     */
    boolean deleteReview(int id);
    
    /**
     * 좋아요 수 업데이트
     */
    boolean updateLikeCount(int id, int likeCount);
    
    /**
     * 리뷰 상태 변경
     */
    boolean updateReviewStatus(int id, String status);
    
    /**
     * 추천 리뷰 설정/해제
     */
    boolean updateRecommendedStatus(int id, boolean isRecommended);
    
    /**
     * 핫플레이스별 평균 평점 조회
     */
    Double getAverageRatingByHotplace(int hotplaceId);
    
    /**
     * 지역별 평균 평점 조회
     */
    Double getAverageRatingByRegion(String region, boolean isSigungu);
    
    /**
     * 핫플레이스별 리뷰 수
     */
    int getReviewCountByHotplace(int hotplaceId);
    
    /**
     * 지역별 리뷰 수
     */
    int getReviewCountByRegion(String region, boolean isSigungu);
    
    /**
     * 작성자별 리뷰 수
     */
    int getReviewCountByAuthor(String authorId);
    
    /**
     * 평점별 리뷰 수
     */
    int getReviewCountByRating(int rating);
    
    /**
     * 전체 리뷰 수
     */
    int getTotalReviewCount();
    
    /**
     * 평점별 통계
     */
    List<Map<String, Object>> getRatingStatistics();
    
    /**
     * 지역별 통계
     */
    List<Map<String, Object>> getRegionStatistics();
    
    /**
     * 카테고리별 통계
     */
    List<Map<String, Object>> getCategoryStatistics();
    
    /**
     * 월별 리뷰 통계
     */
    List<Map<String, Object>> getMonthlyStatistics();
    
    /**
     * 모든 지역명 조회
     */
    List<String> getAllRegionNames();
}
