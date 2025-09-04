package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.WishList;
import com.wherehot.spring.mapper.WishListMapper;
import com.wherehot.spring.service.WishListService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class WishListServiceImpl implements WishListService {
    
    private static final Logger logger = LoggerFactory.getLogger(WishListServiceImpl.class);
    
    @Autowired
    private WishListMapper wishListMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<WishList> findWishListByUser(String userId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return wishListMapper.findByUserId(userId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding wish list by user: {}", userId, e);
            throw new RuntimeException("사용자 위시리스트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<WishList> findWishListByHotplace(int hotplaceId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return wishListMapper.findByHotplaceId(hotplaceId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding wish list by hotplace: {}", hotplaceId, e);
            throw new RuntimeException("핫플레이스 위시리스트 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<WishList> findWishListByUserAndHotplace(String userId, int hotplaceId) {
        try {
            return wishListMapper.findByUserIdAndHotplaceId(userId, hotplaceId);
        } catch (Exception e) {
            logger.error("Error finding wish list by user and hotplace: userId={}, hotplaceId={}", userId, hotplaceId, e);
            return Optional.empty();
        }
    }
    
    @Override
    public WishList saveWishList(WishList wishList) {
        try {
            wishList.setWishDate(LocalDateTime.now());
            
            int result = wishListMapper.insertWishList(wishList);
            if (result > 0) {
                logger.info("WishList saved successfully: userId={}, placeId={}", 
                    wishList.getUserid(), wishList.getPlace_id());
                return wishList;
            } else {
                throw new RuntimeException("위시리스트 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving wish list: userId={}, placeId={}", 
                wishList.getUserid(), wishList.getPlace_id(), e);
            throw new RuntimeException("위시리스트 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteWishList(int id) {
        try {
            int result = wishListMapper.deleteWishList(id);
            if (result > 0) {
                logger.info("WishList deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting wish list: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean deleteWishListByUserAndHotplace(String userId, int hotplaceId) {
        try {
            int result = wishListMapper.deleteByUserIdAndHotplaceId(userId, hotplaceId);
            if (result > 0) {
                logger.info("WishList deleted successfully: userId={}, hotplaceId={}", userId, hotplaceId);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting wish list by user and hotplace: userId={}, hotplaceId={}", userId, hotplaceId, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getWishListCountByUser(String userId) {
        try {
            return wishListMapper.countByUserId(userId);
        } catch (Exception e) {
            logger.error("Error getting wish list count by user: {}", userId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getWishListCountByHotplace(int hotplaceId) {
        try {
            return wishListMapper.countByHotplaceId(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting wish list count by hotplace: {}", hotplaceId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean existsWishListByUserAndHotplace(String userId, int hotplaceId) {
        try {
            return wishListMapper.existsByUserIdAndHotplaceId(userId, hotplaceId);
        } catch (Exception e) {
            logger.error("Error checking wish list existence: userId={}, hotplaceId={}", userId, hotplaceId, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Integer> findPopularHotplaceIds(int limit) {
        try {
            return wishListMapper.findPopularHotplaceIds(limit);
        } catch (Exception e) {
            logger.error("Error finding popular hotplace ids", e);
            throw new RuntimeException("인기 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    // ========== 간편 메서드들 ==========
    
    @Override
    public boolean addWish(String loginId, int placeId) {
        try {
            // 이미 위시리스트에 있는지 확인
            if (existsWishListByUserAndHotplace(loginId, placeId)) {
                logger.info("Wish already exists: userId={}, placeId={}", loginId, placeId);
                return false; // 이미 존재하면 false 반환
            }
            
            WishList wishList = new WishList();
            wishList.setUserid(loginId);
            wishList.setPlace_id(placeId);
            wishList.setPersonal_note(null); // 명시적으로 null 설정
            
            WishList saved = saveWishList(wishList);
            if (saved != null) {
                logger.info("Wish added successfully: userId={}, placeId={}", loginId, placeId);
                return true;
            } else {
                logger.error("Failed to save wish: userId={}, placeId={}", loginId, placeId);
                return false;
            }
            
        } catch (Exception e) {
            logger.error("Error adding wish: userId={}, placeId={}", loginId, placeId, e);
            return false;
        }
    }
    
    @Override
    public boolean removeWish(String loginId, int placeId) {
        try {
            return deleteWishListByUserAndHotplace(loginId, placeId);
        } catch (Exception e) {
            logger.error("Error removing wish: userId={}, placeId={}", loginId, placeId, e);
            return false;
        }
    }
    
    @Override
    public boolean isWished(String loginId, int placeId) {
        try {
            return existsWishListByUserAndHotplace(loginId, placeId);
        } catch (Exception e) {
            logger.error("Error checking wish status: userId={}, placeId={}", loginId, placeId, e);
            return false;
        }
    }
    
    @Override
    public int getWishCount(int placeId) {
        try {
            return getWishListCountByHotplace(placeId);
        } catch (Exception e) {
            logger.error("Error getting wish count for place: {}", placeId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional
    public boolean updatePersonalNote(int wishId, String personalNote) {
        try {
            int result = wishListMapper.updatePersonalNote(wishId, personalNote);
            if (result > 0) {
                logger.info("Personal note updated successfully: wishId={}, note={}", wishId, personalNote);
                return true;
            } else {
                logger.warn("No wish list found to update: wishId={}", wishId);
                return false;
            }
        } catch (Exception e) {
            logger.error("Error updating personal note: wishId={}, note={}", wishId, personalNote, e);
            return false;
        }
    }
}
