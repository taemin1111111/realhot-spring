package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Review;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 리뷰 MyBatis Mapper
 */
@Mapper
public interface ReviewMapper {
    
    /**
     * 모든 리뷰 조회 (페이징)
     */
    List<Review> findAll(@Param("offset") int offset, @Param("limit") int limit);
    
    /**
     * ID로 리뷰 조회
     */
    Optional<Review> findById(@Param("id") int id);
    
    /**
     * 핫플레이스별 리뷰 조회
     */
    List<Review> findByHotplaceId(@Param("hotplaceId") int hotplaceId,
                                 @Param("offset") int offset,
                                 @Param("limit") int limit);
    
    /**
     * 작성자별 리뷰 조회
     */
    List<Review> findByAuthorId(@Param("authorId") String authorId,
                               @Param("offset") int offset,
                               @Param("limit") int limit);
    
    /**
     * 지역별 리뷰 조회
     */
    List<Review> findByRegion(@Param("region") String region,
                             @Param("isSigungu") boolean isSigungu,
                             @Param("offset") int offset,
                             @Param("limit") int limit);
    
    /**
     * 카테고리별 리뷰 조회
     */
    List<Review> findByCategoryId(@Param("categoryId") int categoryId,
                                 @Param("offset") int offset,
                                 @Param("limit") int limit);
    
    /**
     * 평점별 리뷰 조회
     */
    List<Review> findByRating(@Param("rating") int rating,
                             @Param("offset") int offset,
                             @Param("limit") int limit);
    
    /**
     * 추천 리뷰 조회
     */
    List<Review> findRecommendedReviews(@Param("limit") int limit);
    
    /**
     * 최신 리뷰 조회
     */
    List<Review> findRecentReviews(@Param("limit") int limit);
    
    /**
     * 인기 리뷰 조회 (좋아요 많은 순)
     */
    List<Review> findPopularReviews(@Param("limit") int limit);
    
    /**
     * 리뷰 등록
     */
    int insertReview(Review review);
    
    /**
     * 리뷰 수정
     */
    int updateReview(Review review);
    
    /**
     * 리뷰 삭제
     */
    int deleteReview(@Param("id") int id);
    
    /**
     * 좋아요 수 업데이트
     */
    int updateLikeCount(@Param("id") int id, @Param("likeCount") int likeCount);
    
    /**
     * 추천 이력 존재 체크 (Model1 호환)
     */
    int checkRecommendationExists(@Param("reviewId") int reviewId, @Param("userid") String userid);
    
    /**
     * 추천 이력 추가 (Model1 호환)
     */
    int insertRecommendation(@Param("reviewId") int reviewId, @Param("userid") String userid);
    
    /**
     * 리뷰 추천 수 증가 (Model1 호환)
     */
    int incrementRecommendCount(@Param("reviewId") int reviewId);
    
    /**
     * 모든 지역명 조회 (Model1 호환)
     */
    List<String> findAllRegionNames();

    /**
     * 인기 지역 조회
     */
    List<String> findPopularRegions();

    /**
     * 리뷰가 등록된 지역 목록 조회
     */
    List<String> findRegionsWithReviews();
    
    /**
     * 지역별 리뷰 조회 (Model1 호환)
     */
    List<Review> findByRegionSimple(@Param("region") String region);
    
    /**
     * 지역 및 카테고리별 리뷰 조회 (Model1 호환)
     */
    List<Review> findByRegionAndCategory(@Param("region") String region, @Param("category") int category);
    
    /**
     * 리뷰 상태 변경
     */
    int updateStatus(@Param("id") int id, @Param("status") String status);
    
    /**
     * 추천 리뷰 설정/해제
     */
    int updateRecommendedStatus(@Param("id") int id, @Param("isRecommended") boolean isRecommended);
    
    /**
     * 핫플레이스별 평균 평점 조회
     */
    Double getAverageRatingByHotplaceId(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 지역별 평균 평점 조회
     */
    Double getAverageRatingByRegion(@Param("region") String region, @Param("isSigungu") boolean isSigungu);
    
    /**
     * 핫플레이스별 리뷰 수
     */
    int countByHotplaceId(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 지역별 리뷰 수
     */
    int countByRegion(@Param("region") String region, @Param("isSigungu") boolean isSigungu);
    
    /**
     * 작성자별 리뷰 수
     */
    int countByAuthorId(@Param("authorId") String authorId);
    
    /**
     * 평점별 리뷰 수
     */
    int countByRating(@Param("rating") int rating);
    
    /**
     * 전체 리뷰 수
     */
    int countAll();
    
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
}
