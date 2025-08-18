package com.wherehot.spring.service;

import com.wherehot.spring.entity.Region;

import java.util.List;
import java.util.Map;

/**
 * 지역 서비스 인터페이스
 */
public interface RegionService {
    
    /**
     * 모든 지역 조회
     */
    List<Region> findAllRegions();
    
    /**
     * 시군구 중심좌표 조회
     */
    List<Map<String, Object>> getAllSigunguCenters();
    
    /**
     * 시군구별 카테고리별 개수 조회
     */
    List<Map<String, Object>> getSigunguCategoryCounts();
    
    /**
     * 지역(동/구) 중심좌표 조회
     */
    List<Map<String, Object>> getAllRegionCenters();
    
    /**
     * 지역별 카테고리별 개수 조회
     */
    List<Map<String, Object>> getRegionCategoryCounts();
    
    /**
     * 모든 지역명 조회
     */
    List<String> getAllRegionNames();
    
    /**
     * 지역별 평균 평점 조회
     */
    Map<String, Double> getRegionAverageRatings();
    
    /**
     * 동/구별 ID 매핑 조회
     */
    Map<String, Integer> getDongToRegionIdMapping();
    
    /**
     * 특정 지역의 핫플레이스 통계
     */
    Map<String, Object> getRegionStatistics(String dong);
    
    /**
     * 지역 검색
     */
    List<Region> searchRegions(String keyword);
}
