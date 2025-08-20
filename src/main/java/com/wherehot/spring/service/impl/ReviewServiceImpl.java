package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Review;
import com.wherehot.spring.mapper.ReviewMapper;
import com.wherehot.spring.service.ReviewService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 리뷰 서비스 구현체
 */
@Service
@Transactional
public class ReviewServiceImpl implements ReviewService {
    
    private static final Logger logger = LoggerFactory.getLogger(ReviewServiceImpl.class);
    
    @Autowired
    private ReviewMapper reviewMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findAllReviews(int page, int size) {
        try {
            int offset = (page - 1) * size;
            return reviewMapper.findAll(offset, size);
        } catch (Exception e) {
            logger.error("Error finding all reviews: page={}, size={}", page, size, e);
            throw new RuntimeException("리뷰 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Review> findReviewById(int id) {
        try {
            return reviewMapper.findById(id);
        } catch (Exception e) {
            logger.error("Error finding review by id: {}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findReviewsByHotplace(int hotplaceId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return reviewMapper.findByHotplaceId(hotplaceId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding reviews by hotplace: hotplaceId={}, page={}, size={}", hotplaceId, page, size, e);
            throw new RuntimeException("핫플레이스별 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findReviewsByAuthor(String authorId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return reviewMapper.findByAuthorId(authorId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding reviews by author: authorId={}, page={}, size={}", authorId, page, size, e);
            throw new RuntimeException("작성자별 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findReviewsByRegion(String region, boolean isSigungu, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return reviewMapper.findByRegion(region, isSigungu, offset, size);
        } catch (Exception e) {
            logger.error("Error finding reviews by region: region={}, isSigungu={}, page={}, size={}", region, isSigungu, page, size, e);
            throw new RuntimeException("지역별 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findReviewsByCategory(int categoryId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return reviewMapper.findByCategoryId(categoryId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding reviews by category: categoryId={}, page={}, size={}", categoryId, page, size, e);
            throw new RuntimeException("카테고리별 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findReviewsByRating(int rating, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return reviewMapper.findByRating(rating, offset, size);
        } catch (Exception e) {
            logger.error("Error finding reviews by rating: rating={}, page={}, size={}", rating, page, size, e);
            throw new RuntimeException("평점별 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findRecommendedReviews(int limit) {
        try {
            return reviewMapper.findRecommendedReviews(limit);
        } catch (Exception e) {
            logger.error("Error finding recommended reviews: limit={}", limit, e);
            throw new RuntimeException("추천 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findRecentReviews(int limit) {
        try {
            return reviewMapper.findRecentReviews(limit);
        } catch (Exception e) {
            logger.error("Error finding recent reviews: limit={}", limit, e);
            throw new RuntimeException("최신 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Review> findPopularReviews(int limit) {
        try {
            return reviewMapper.findPopularReviews(limit);
        } catch (Exception e) {
            logger.error("Error finding popular reviews: limit={}", limit, e);
            throw new RuntimeException("인기 리뷰 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Review saveReview(Review review) {
        try {
            review.setWriteday(LocalDateTime.now());
            
            int result = reviewMapper.insertReview(review);
            if (result > 0) {
                logger.info("Review saved successfully: ID={}", review.getNum());
                return review;
            } else {
                throw new RuntimeException("리뷰 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving review: ID={}", review.getNum(), e);
            throw new RuntimeException("리뷰 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Review updateReview(Review review) {
        try {
            Optional<Review> existingReview = reviewMapper.findById(review.getNum());
            if (existingReview.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 리뷰입니다: " + review.getNum());
            }
            
            // Review Entity에는 updatedAt 필드가 없음 (writeday만 있음)
            
            int result = reviewMapper.updateReview(review);
            if (result > 0) {
                logger.info("Review updated successfully: {}", review.getNum());
                return review;
            } else {
                throw new RuntimeException("리뷰 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating review: {}", review.getNum(), e);
            throw new RuntimeException("리뷰 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteReview(int id) {
        try {
            Optional<Review> review = reviewMapper.findById(id);
            if (review.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 리뷰입니다: " + id);
            }
            
            int result = reviewMapper.deleteReview(id);
            if (result > 0) {
                logger.info("Review deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting review: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean updateLikeCount(int id, int likeCount) {
        try {
            int result = reviewMapper.updateLikeCount(id, likeCount);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating review like count: id={}, likeCount={}", id, likeCount, e);
            return false;
        }
    }
    
    @Override
    public boolean hasAlreadyRecommended(int reviewId, String userid) {
        try {
            int count = reviewMapper.checkRecommendationExists(reviewId, userid);
            return count > 0;
        } catch (Exception e) {
            logger.error("Error checking recommendation exists: reviewId={}, userid={}", reviewId, userid, e);
            return false;
        }
    }
    
    @Override
    public boolean addRecommendation(int reviewId, String userid) {
        try {
            // 1. 추천 이력 추가
            int recommendResult = reviewMapper.insertRecommendation(reviewId, userid);
            
            if (recommendResult > 0) {
                // 2. 리뷰의 추천 수 증가
                int incrementResult = reviewMapper.incrementRecommendCount(reviewId);
                return incrementResult > 0;
            }
            
            return false;
        } catch (Exception e) {
            logger.error("Error adding recommendation: reviewId={}, userid={}", reviewId, userid, e);
            return false;
        }
    }
    
    @Override
    public List<String> getAllRegionNames() {
        try {
            return reviewMapper.findAllRegionNames();
        } catch (Exception e) {
            logger.error("Error getting all region names", e);
            return new ArrayList<>();
        }
    }
    
    @Override
    public List<Review> findReviewsByRegion(String region, int category) {
        try {
            if (category > 0) {
                return reviewMapper.findByRegionAndCategory(region, category);
            } else {
                return reviewMapper.findByRegion(region);
            }
        } catch (Exception e) {
            logger.error("Error finding reviews by region: region={}, category={}", region, category, e);
            return new ArrayList<>();
        }
    }
    
    @Override
    public boolean updateReviewStatus(int id, String status) {
        try {
            int result = reviewMapper.updateStatus(id, status);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating review status: id={}, status={}", id, status, e);
            return false;
        }
    }
    
    @Override
    public boolean updateRecommendedStatus(int id, boolean isRecommended) {
        try {
            int result = reviewMapper.updateRecommendedStatus(id, isRecommended);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating review recommended status: id={}, isRecommended={}", id, isRecommended, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Double getAverageRatingByHotplace(int hotplaceId) {
        try {
            return reviewMapper.getAverageRatingByHotplaceId(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting average rating by hotplace: {}", hotplaceId, e);
            return 0.0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Double getAverageRatingByRegion(String region, boolean isSigungu) {
        try {
            return reviewMapper.getAverageRatingByRegion(region, isSigungu);
        } catch (Exception e) {
            logger.error("Error getting average rating by region: region={}, isSigungu={}", region, isSigungu, e);
            return 0.0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getReviewCountByHotplace(int hotplaceId) {
        try {
            return reviewMapper.countByHotplaceId(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting review count by hotplace: {}", hotplaceId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getReviewCountByRegion(String region, boolean isSigungu) {
        try {
            return reviewMapper.countByRegion(region, isSigungu);
        } catch (Exception e) {
            logger.error("Error getting review count by region: region={}, isSigungu={}", region, isSigungu, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getReviewCountByAuthor(String authorId) {
        try {
            return reviewMapper.countByAuthorId(authorId);
        } catch (Exception e) {
            logger.error("Error getting review count by author: {}", authorId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getReviewCountByRating(int rating) {
        try {
            return reviewMapper.countByRating(rating);
        } catch (Exception e) {
            logger.error("Error getting review count by rating: {}", rating, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getTotalReviewCount() {
        try {
            return reviewMapper.countAll();
        } catch (Exception e) {
            logger.error("Error getting total review count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getRatingStatistics() {
        try {
            return reviewMapper.getRatingStatistics();
        } catch (Exception e) {
            logger.error("Error getting rating statistics", e);
            throw new RuntimeException("평점 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getRegionStatistics() {
        try {
            return reviewMapper.getRegionStatistics();
        } catch (Exception e) {
            logger.error("Error getting region statistics", e);
            throw new RuntimeException("지역별 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getCategoryStatistics() {
        try {
            return reviewMapper.getCategoryStatistics();
        } catch (Exception e) {
            logger.error("Error getting category statistics", e);
            throw new RuntimeException("카테고리별 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMonthlyStatistics() {
        try {
            return reviewMapper.getMonthlyStatistics();
        } catch (Exception e) {
            logger.error("Error getting monthly statistics", e);
            throw new RuntimeException("월별 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    

}
