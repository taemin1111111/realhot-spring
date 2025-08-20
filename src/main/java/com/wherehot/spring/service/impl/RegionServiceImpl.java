package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Region;
import com.wherehot.spring.mapper.RegionMapper;
import com.wherehot.spring.service.RegionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * 지역 서비스 구현체
 */
@Service
@Transactional
public class RegionServiceImpl implements RegionService {
    
    private static final Logger logger = LoggerFactory.getLogger(RegionServiceImpl.class);
    
    @Autowired
    private RegionMapper regionMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Region> findAllRegions() {
        try {
            return regionMapper.findAll();
        } catch (Exception e) {
            logger.error("Error finding all regions", e);
            throw new RuntimeException("지역 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllSigunguCenters() {
        try {
            return regionMapper.getAllSigunguCenters();
        } catch (Exception e) {
            logger.error("Error getting sigungu centers", e);
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getSigunguCategoryCounts() {
        try {
            return regionMapper.getSigunguCategoryCounts();
        } catch (Exception e) {
            logger.error("Error getting sigungu category counts", e);
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllRegionCenters() {
        try {
            return regionMapper.getAllRegionCenters();
        } catch (Exception e) {
            logger.error("Error getting region centers", e);
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getRegionCategoryCounts() {
        try {
            return regionMapper.getRegionCategoryCounts();
        } catch (Exception e) {
            logger.error("Error getting region category counts", e);
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<String> getAllRegionNames() {
        try {
            return regionMapper.getAllRegionNames();
        } catch (Exception e) {
            logger.error("Error getting region names", e);
            return new java.util.ArrayList<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Double> getRegionAverageRatings() {
        try {
            List<Map<String, Object>> ratings = regionMapper.getRegionAverageRatings();
            Map<String, Double> result = new HashMap<>();
            for (Map<String, Object> rating : ratings) {
                String dong = (String) rating.get("dong");
                Object avgRatingObj = rating.get("averageRating");
                Double avgRating = 0.0;
                
                if (avgRatingObj instanceof Number) {
                    avgRating = ((Number) avgRatingObj).doubleValue();
                }
                
                result.put(dong, avgRating);
            }
            return result;
        } catch (Exception e) {
            logger.error("Error getting region average ratings", e);
            return new HashMap<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Integer> getDongToRegionIdMapping() {
        try {
            List<Map<String, Object>> mappings = regionMapper.getDongToRegionIdMapping();
            Map<String, Integer> result = new HashMap<>();
            for (Map<String, Object> mapping : mappings) {
                String dong = (String) mapping.get("dong");
                Integer id = (Integer) mapping.get("id");
                result.put(dong, id);
            }
            return result;
        } catch (Exception e) {
            logger.error("Error getting dong to region id mapping", e);
            return new HashMap<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getRegionStatistics(String dong) {
        try {
            return regionMapper.getRegionStatistics(dong);
        } catch (Exception e) {
            logger.error("Error getting region statistics for dong: {}", dong, e);
            return new HashMap<>();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Region> searchRegions(String keyword) {
        try {
            return regionMapper.searchRegions(keyword);
        } catch (Exception e) {
            logger.error("Error searching regions with keyword: {}", keyword, e);
            return new java.util.ArrayList<>();
        }
    }
}
