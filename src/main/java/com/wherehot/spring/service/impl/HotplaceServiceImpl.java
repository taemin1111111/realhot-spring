package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Hotplace;
import com.wherehot.spring.mapper.HotplaceMapper;
import com.wherehot.spring.service.HotplaceService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 핫플레이스 서비스 구현체
 */
@Service
@Transactional
public class HotplaceServiceImpl implements HotplaceService {
    
    private static final Logger logger = LoggerFactory.getLogger(HotplaceServiceImpl.class);
    
    @Autowired
    private HotplaceMapper hotplaceMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> findAllHotplaces() {
        try {
            return hotplaceMapper.findAll();
        } catch (Exception e) {
            logger.error("Error finding all hotplaces", e);
            throw new RuntimeException("핫플레이스 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Hotplace> findHotplaceById(int id) {
        try {
            return hotplaceMapper.findById(id);
        } catch (Exception e) {
            logger.error("Error finding hotplace by id: {}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> findHotplacesByCategory(int categoryId) {
        try {
            return hotplaceMapper.findByCategoryId(categoryId);
        } catch (Exception e) {
            logger.error("Error finding hotplaces by category: {}", categoryId, e);
            throw new RuntimeException("카테고리별 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> findHotplacesByRegion(String region) {
        try {
            return hotplaceMapper.findByRegion(region);
        } catch (Exception e) {
            logger.error("Error finding hotplaces by region: {}", region, e);
            throw new RuntimeException("지역별 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> findHotplacesBySigungu(String sigungu) {
        try {
            return hotplaceMapper.findBySigungu(sigungu);
        } catch (Exception e) {
            logger.error("Error finding hotplaces by sigungu: {}", sigungu, e);
            throw new RuntimeException("시군구별 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> findPopularHotplaces(int limit) {
        try {
            return hotplaceMapper.findPopularHotplaces(limit);
        } catch (Exception e) {
            logger.error("Error finding popular hotplaces: limit={}", limit, e);
            throw new RuntimeException("인기 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> findRecentHotplaces(int limit) {
        try {
            return hotplaceMapper.findRecentHotplaces(limit);
        } catch (Exception e) {
            logger.error("Error finding recent hotplaces: limit={}", limit, e);
            throw new RuntimeException("최신 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> searchHotplaces(String keyword, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return hotplaceMapper.searchByKeyword(keyword, offset, size);
        } catch (Exception e) {
            logger.error("Error searching hotplaces: keyword={}, page={}, size={}", keyword, page, size, e);
            throw new RuntimeException("핫플레이스 검색 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Hotplace> findHotplacesByCoordinateRange(double minLat, double maxLat, double minLng, double maxLng) {
        try {
            return hotplaceMapper.findByCoordinateRange(minLat, maxLat, minLng, maxLng);
        } catch (Exception e) {
            logger.error("Error finding hotplaces by coordinate range: minLat={}, maxLat={}, minLng={}, maxLng={}", 
                        minLat, maxLat, minLng, maxLng, e);
            throw new RuntimeException("좌표 범위 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Hotplace saveHotplace(Hotplace hotplace) {
        try {
            // Hotplace Entity에서 createdAt, updatedAt 필드가 제거됨
            
            int result = hotplaceMapper.insertHotplace(hotplace);
            if (result > 0) {
                logger.info("Hotplace saved successfully: {}", hotplace.getName());
                return hotplace;
            } else {
                throw new RuntimeException("핫플레이스 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving hotplace: {}", hotplace.getName(), e);
            throw new RuntimeException("핫플레이스 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Hotplace updateHotplace(Hotplace hotplace) {
        try {
            // 기존 핫플레이스 존재 확인
            Optional<Hotplace> existingHotplace = hotplaceMapper.findById(hotplace.getId());
            if (existingHotplace.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 핫플레이스입니다: " + hotplace.getId());
            }
            
            // Hotplace Entity에서 updatedAt 필드가 제거됨
            
            int result = hotplaceMapper.updateHotplace(hotplace);
            if (result > 0) {
                logger.info("Hotplace updated successfully: {}", hotplace.getId());
                return hotplace;
            } else {
                throw new RuntimeException("핫플레이스 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating hotplace: {}", hotplace.getId(), e);
            throw new RuntimeException("핫플레이스 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteHotplace(int id) {
        try {
            // 핫플레이스 존재 확인
            Optional<Hotplace> hotplace = hotplaceMapper.findById(id);
            if (hotplace.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 핫플레이스입니다: " + id);
            }
            
            int result = hotplaceMapper.deleteHotplace(id);
            if (result > 0) {
                logger.info("Hotplace deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting hotplace: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean updateRatingInfo(int id, double averageRating, int reviewCount) {
        try {
            int result = hotplaceMapper.updateRatingInfo(id, averageRating, reviewCount);
            if (result > 0) {
                logger.info("Hotplace rating info updated: id={}, avgRating={}, reviewCount={}", 
                           id, averageRating, reviewCount);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error updating hotplace rating info: id={}, avgRating={}, reviewCount={}", 
                        id, averageRating, reviewCount, e);
            return false;
        }
    }
    
    @Override
    public boolean updateWishCount(int id, int wishCount) {
        try {
            int result = hotplaceMapper.updateWishCount(id, wishCount);
            if (result > 0) {
                logger.info("Hotplace wish count updated: id={}, wishCount={}", id, wishCount);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error updating hotplace wish count: id={}, wishCount={}", id, wishCount, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getRegionStatistics() {
        try {
            return hotplaceMapper.getRegionStatistics();
        } catch (Exception e) {
            logger.error("Error getting region statistics", e);
            throw new RuntimeException("지역별 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getCategoryStatistics() {
        try {
            return hotplaceMapper.getCategoryStatistics();
        } catch (Exception e) {
            logger.error("Error getting category statistics", e);
            throw new RuntimeException("카테고리별 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getTotalCount() {
        try {
            return hotplaceMapper.countAll();
        } catch (Exception e) {
            logger.error("Error getting total hotplace count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getSearchResultCount(String keyword) {
        try {
            return hotplaceMapper.countSearchResults(keyword);
        } catch (Exception e) {
            logger.error("Error getting search result count: keyword={}", keyword, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<String> findAllHotplaceNames() {
        try {
            return hotplaceMapper.findAllHotplaceNames();
        } catch (Exception e) {
            logger.error("Error finding all hotplace names", e);
            return new java.util.ArrayList<>();
        }
    }
}
