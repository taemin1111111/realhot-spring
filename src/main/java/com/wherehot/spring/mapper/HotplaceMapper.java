package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Hotplace;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 핫플레이스 MyBatis Mapper
 */
@Mapper
public interface HotplaceMapper {
    
    /**
     * 모든 핫플레이스 조회
     */
    List<Hotplace> findAll();
    
    /**
     * ID로 핫플레이스 조회
     */
    Optional<Hotplace> findById(@Param("id") int id);
    
    /**
     * 카테고리별 핫플레이스 조회
     */
    List<Hotplace> findByCategoryId(@Param("categoryId") int categoryId);
    
    /**
     * 지역별 핫플레이스 조회
     */
    List<Hotplace> findByRegion(@Param("region") String region);
    
    /**
     * 시군구별 핫플레이스 조회
     */
    List<Hotplace> findBySigungu(@Param("sigungu") String sigungu);
    
    /**
     * 인기 핫플레이스 조회 (평점 순)
     */
    List<Hotplace> findPopularHotplaces(@Param("limit") int limit);
    
    /**
     * 최신 핫플레이스 조회
     */
    List<Hotplace> findRecentHotplaces(@Param("limit") int limit);
    
    /**
     * 키워드로 핫플레이스 검색
     */
    List<Hotplace> searchByKeyword(@Param("keyword") String keyword, 
                                  @Param("offset") int offset, 
                                  @Param("limit") int limit);
    
    /**
     * 좌표 범위로 핫플레이스 검색
     */
    List<Hotplace> findByCoordinateRange(@Param("minLat") double minLat,
                                        @Param("maxLat") double maxLat,
                                        @Param("minLng") double minLng,
                                        @Param("maxLng") double maxLng);
    
    /**
     * 핫플레이스 등록
     */
    int insertHotplace(Hotplace hotplace);
    
    /**
     * 핫플레이스 수정
     */
    int updateHotplace(Hotplace hotplace);
    
    /**
     * 핫플레이스 삭제 (비활성화)
     */
    int deleteHotplace(@Param("id") int id);
    
    /**
     * 평점 정보 업데이트
     */
    int updateRatingInfo(@Param("id") int id, 
                        @Param("averageRating") double averageRating, 
                        @Param("reviewCount") int reviewCount);
    
    /**
     * 위시리스트 수 업데이트
     */
    int updateWishCount(@Param("id") int id, @Param("wishCount") int wishCount);
    
    /**
     * 지역별 통계
     */
    List<Map<String, Object>> getRegionStatistics();
    
    /**
     * 카테고리별 통계
     */
    List<Map<String, Object>> getCategoryStatistics();
    
    /**
     * 전체 핫플레이스 수
     */
    int countAll();
    
    /**
     * 검색 결과 수
     */
    int countSearchResults(@Param("keyword") String keyword);
    
    /**
     * 모든 핫플레이스 이름 목록 조회
     */
    List<String> findAllHotplaceNames();
}
