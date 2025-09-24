package com.wherehot.spring.service.impl;

import com.wherehot.spring.mapper.TodayHotMapper;
import com.wherehot.spring.service.TodayHotService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 오늘 핫 랭킹 전용 서비스 구현체
 */
@Service
public class TodayHotServiceImpl implements TodayHotService {
    
    private static final Logger logger = LoggerFactory.getLogger(TodayHotServiceImpl.class);
    
    @Autowired
    private TodayHotMapper todayHotMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTodayHotRanking() {
        try {
            logger.info("=== TodayHotService.getTodayHotRanking called ===");
            List<Map<String, Object>> rankings = todayHotMapper.getTodayHotRanking();
            logger.info("=== Today hot ranking retrieved: {} places ===", rankings.size());
            return rankings;
        } catch (Exception e) {
            logger.error("Error getting today hot ranking: ", e);
            throw new RuntimeException("오늘 핫 랭킹 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getPlaceTodayHotRank(int placeId) {
        try {
            logger.info("=== TodayHotService.getPlaceTodayHotRank called for placeId: {} ===", placeId);
            List<Map<String, Object>> rankData = todayHotMapper.getPlaceTodayHotRank(placeId);
            logger.info("=== Place today hot rank retrieved for placeId: {} = {} ===", placeId, 
                       rankData.isEmpty() ? "NO VOTES" : rankData.get(0).get("ranking"));
            return rankData;
        } catch (Exception e) {
            logger.error("Error getting place today hot rank for placeId {}: ", placeId, e);
            throw new RuntimeException("가게 오늘핫 순위 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public void refreshTodayHotRankingCache() {
        try {
            logger.info("=== TodayHotService.refreshTodayHotRankingCache called ===");
            
            // Redis 캐시 새로고침 로직 (향후 구현)
            // 1. DB에서 최신 랭킹 데이터 조회
            // 2. Redis에 캐시 업데이트
            // 3. 캐시 만료 시간 설정
            
            logger.info("=== Today hot ranking cache refreshed ===");
        } catch (Exception e) {
            logger.error("Error refreshing today hot ranking cache: ", e);
            throw new RuntimeException("오늘 핫 랭킹 캐시 새로고침 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Map<String, Object> getTodayVoteStats(int placeId) {
        try {
            logger.info("Getting today vote stats for placeId: {}", placeId);
            
            Map<String, Object> stats = todayHotMapper.getTodayVoteStats(placeId);
            
            if (stats != null) {
                logger.info("Successfully retrieved today vote stats for placeId: {}", placeId);
            } else {
                logger.info("No today vote stats found for placeId: {}", placeId);
            }
            
            return stats;
            
        } catch (Exception e) {
            logger.error("Error getting today vote stats for placeId: {}", placeId, e);
            return null;
        }
    }
}
