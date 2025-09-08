package com.wherehot.spring.mapper;

import java.util.List;
import java.util.Map;

/**
 * 오늘 핫 랭킹 전용 매퍼 인터페이스
 */
public interface TodayHotMapper {
    
    /**
     * 오늘 핫 랭킹 조회 (투표 수 기준 상위 10개)
     * @return 랭킹 데이터 리스트
     */
    List<Map<String, Object>> getTodayHotRanking();
    
    /**
     * 특정 가게의 오늘 투표 통계 조회
     * @param placeId 가게 ID
     * @return 투표 통계 데이터
     */
    Map<String, Object> getTodayVoteStats(int placeId);
    
    /**
     * 오늘 핫 랭킹 캐시용 데이터 조회 (Redis 구현 시 사용)
     * @return 캐시용 랭킹 데이터
     */
    List<Map<String, Object>> getTodayHotRankingForCache();
}
