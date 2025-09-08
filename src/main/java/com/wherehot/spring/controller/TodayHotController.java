package com.wherehot.spring.controller;

import com.wherehot.spring.service.TodayHotService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * 오늘 핫 랭킹 전용 컨트롤러
 */
@RestController
@RequestMapping("/api/today-hot")
public class TodayHotController {
    
    private static final Logger logger = LoggerFactory.getLogger(TodayHotController.class);
    
    @Autowired
    private TodayHotService todayHotService;
    
    /**
     * 오늘 핫 랭킹 API (실제 DB 데이터)
     */
    @PostMapping("/ranking")
    public ResponseEntity<Map<String, Object>> getTodayHotRanking() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("=== /api/today-hot/ranking called ===");
            
            // 실제 DB에서 랭킹 데이터 조회
            List<Map<String, Object>> rankings = getTodayHotRankingFromDB();
            
            response.put("success", true);
            response.put("rankings", rankings);
            response.put("timestamp", System.currentTimeMillis());
            response.put("cacheStatus", "DB_DIRECT"); // 실제 DB 데이터
            
            logger.info("=== /api/today-hot/ranking response: {} rankings ===", rankings.size());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Today hot ranking error: ", e);
            response.put("success", false);
            response.put("error", "오늘 핫 랭킹 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * DB에서 오늘 핫 랭킹 데이터 조회 (실제 DB 쿼리)
     */
    private List<Map<String, Object>> getTodayHotRankingFromDB() {
        try {
            // TodayHotService를 통해 실제 DB에서 랭킹 데이터 조회
            List<Map<String, Object>> rankings = todayHotService.getTodayHotRanking();
            
            // 데이터가 없으면 빈 리스트 반환
            if (rankings == null || rankings.isEmpty()) {
                logger.warn("No ranking data found in database");
                return new ArrayList<>();
            }
            
            // 순위 정보 추가 (DB에서 가져온 데이터에 순위 번호 추가)
            for (int i = 0; i < rankings.size(); i++) {
                Map<String, Object> ranking = rankings.get(i);
                ranking.put("rank", i + 1);
                
                // 데이터 타입 변환 및 기본값 설정
                Object percentage = ranking.get("percentage");
                if (percentage == null) {
                    ranking.put("percentage", 0);
                } else if (percentage instanceof Double) {
                    ranking.put("percentage", ((Double) percentage).intValue());
                }
                
                // null 값들을 기본값으로 설정
                if (ranking.get("congestion") == null) {
                    ranking.put("congestion", "정보 없음");
                }
                if (ranking.get("waitTime") == null) {
                    ranking.put("waitTime", "정보 없음");
                }
                if (ranking.get("genderRatio") == null) {
                    ranking.put("genderRatio", "정보 없음");
                }
            }
            
            logger.info("Successfully retrieved {} rankings from database", rankings.size());
            return rankings;
            
        } catch (Exception e) {
            logger.error("Error getting today hot ranking from DB: ", e);
            return new ArrayList<>();
        }
    }
}
