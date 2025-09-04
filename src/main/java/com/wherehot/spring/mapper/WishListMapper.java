package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.WishList;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

/**
 * 위시리스트 MyBatis Mapper
 */
@Mapper
public interface WishListMapper {
    
    /**
     * 사용자별 위시리스트 조회
     */
    List<WishList> findByUserId(@Param("userId") String userId,
                               @Param("offset") int offset,
                               @Param("limit") int limit);
    
    /**
     * 핫플레이스별 위시리스트 조회
     */
    List<WishList> findByHotplaceId(@Param("hotplaceId") int hotplaceId,
                                   @Param("offset") int offset,
                                   @Param("limit") int limit);
    
    /**
     * 특정 사용자의 특정 핫플레이스 위시리스트 조회
     */
    Optional<WishList> findByUserAndHotplace(@Param("userId") String userId, 
                                            @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자와 핫플레이스로 위시리스트 조회 (메서드명 variant)
     */
    Optional<WishList> findWishListByUserAndHotplace(@Param("userId") String userId, 
                                                    @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자와 핫플레이스ID로 위시리스트 조회
     */
    Optional<WishList> findByUserAndHotplaceId(@Param("userId") String userId, 
                                              @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자와 핫플레이스ID로 위시리스트 조회 (다른 형태)
     */
    Optional<WishList> findByUserIdAndHotplaceId(@Param("userId") String userId, 
                                                @Param("hotplaceId") int hotplaceId);
    
    /**
     * 위시리스트 등록
     */
    int insertWishList(WishList wishList);
    
    /**
     * 위시리스트 삭제
     */
    int deleteWishList(@Param("id") int id);
    
    /**
     * 사용자와 핫플레이스로 위시리스트 삭제
     */
    int deleteByUserAndHotplace(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자와 핫플레이스로 위시리스트 삭제 (메서드명 variant)
     */
    int deleteWishListByUserAndHotplace(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자와 핫플레이스로 위시리스트 존재 여부 확인
     */
    boolean existsByUserAndHotplaceId(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자와 핫플레이스ID로 위시리스트 삭제
     */
    int deleteByUserAndHotplaceId(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자ID와 핫플레이스ID로 위시리스트 삭제
     */
    int deleteByUserIdAndHotplaceId(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자별 위시리스트 수
     */
    int countByUserId(@Param("userId") String userId);
    
    /**
     * 핫플레이스별 위시리스트 수
     */
    int countByHotplaceId(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 위시리스트 존재 여부 확인
     */
    boolean existsByUserAndHotplace(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 위시리스트 존재 여부 확인 (메서드명 variant)
     */
    boolean existsWishListByUserAndHotplace(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 사용자ID와 핫플레이스ID로 위시리스트 존재 여부 확인
     */
    boolean existsByUserIdAndHotplaceId(@Param("userId") String userId, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 인기 핫플레이스 조회 (위시리스트 많은 순)
     */
    List<Integer> findPopularHotplaceIds(@Param("limit") int limit);
    
    /**
     * 위시리스트 저장 (메서드명 variant)
     */
    WishList saveWishList(WishList wishList);
    
    /**
     * 위시리스트의 개인 메모 업데이트
     */
    int updatePersonalNote(@Param("id") int id, @Param("personalNote") String personalNote);
}
