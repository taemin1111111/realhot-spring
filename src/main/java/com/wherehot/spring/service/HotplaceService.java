package com.wherehot.spring.service;

import com.wherehot.spring.entity.Hotplace;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 핫플레이스 서비스 인터페이스
 */
public interface HotplaceService {
    
    /**
     * 모든 핫플레이스 조회
     */
    List<Hotplace> findAllHotplaces();
    
    /**
     * ID로 핫플레이스 조회
     */
    Optional<Hotplace> findHotplaceById(int id);
    
    /**
     * 카테고리별 핫플레이스 조회
     */
    List<Hotplace> findHotplacesByCategory(int categoryId);
    
    /**
     * 지역별 핫플레이스 조회
     */
    List<Hotplace> findHotplacesByRegion(String region);
    
    /**
     * 시군구별 핫플레이스 조회
     */
    List<Hotplace> findHotplacesBySigungu(String sigungu);
    
    /**
     * 인기 핫플레이스 조회 (평점 순)
     */
    List<Hotplace> findPopularHotplaces(int limit);
    
    /**
     * 최신 핫플레이스 조회
     */
    List<Hotplace> findRecentHotplaces(int limit);
    
    /**
     * 키워드로 핫플레이스 검색
     */
    List<Hotplace> searchHotplaces(String keyword, int page, int size);
    
    /**
     * 좌표 범위로 핫플레이스 검색
     */
    List<Hotplace> findHotplacesByCoordinateRange(double minLat, double maxLat, double minLng, double maxLng);
    
    /**
     * 핫플레이스 등록
     */
    Hotplace saveHotplace(Hotplace hotplace);
    
    /**
     * 핫플레이스 수정
     */
    Hotplace updateHotplace(Hotplace hotplace);
    
    /**
     * 핫플레이스 삭제 (비활성화)
     */
    boolean deleteHotplace(int id);
    
    /**
     * 평점 정보 업데이트
     */
    boolean updateRatingInfo(int id, double averageRating, int reviewCount);
    
    /**
     * 위시리스트 수 업데이트
     */
    boolean updateWishCount(int id, int wishCount);
    
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
    int getTotalCount();
    
    /**
     * 검색 결과 수
     */
    int getSearchResultCount(String keyword);
    
    /**
     * 모든 핫플레이스 이름 목록 조회
     */
    List<String> findAllHotplaceNames();
}
