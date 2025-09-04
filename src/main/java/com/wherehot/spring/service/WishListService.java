package com.wherehot.spring.service;

import com.wherehot.spring.entity.WishList;

import java.util.List;
import java.util.Optional;

/**
 * 위시리스트 서비스 인터페이스
 */
public interface WishListService {
    
    List<WishList> findWishListByUser(String userId, int page, int size);
    List<WishList> findWishListByHotplace(int hotplaceId, int page, int size);
    Optional<WishList> findWishListByUserAndHotplace(String userId, int hotplaceId);
    
    WishList saveWishList(WishList wishList);
    boolean deleteWishList(int id);
    boolean deleteWishListByUserAndHotplace(String userId, int hotplaceId);
    
    int getWishListCountByUser(String userId);
    int getWishListCountByHotplace(int hotplaceId);
    boolean existsWishListByUserAndHotplace(String userId, int hotplaceId);
    List<Integer> findPopularHotplaceIds(int limit);
    
    /**
     * 위시리스트 추가 (간편 메서드)
     */
    boolean addWish(String loginId, int placeId);
    
    /**
     * 위시리스트 제거 (간편 메서드)
     */
    boolean removeWish(String loginId, int placeId);
    
    /**
     * 위시리스트 존재 여부 확인 (간편 메서드)
     */
    boolean isWished(String loginId, int placeId);
    
    /**
     * 특정 장소의 위시리스트 개수 조회 (간편 메서드)
     */
    int getWishCount(int placeId);
    
    /**
     * 위시리스트의 개인 메모 업데이트
     */
    boolean updatePersonalNote(int wishId, String personalNote);
}
