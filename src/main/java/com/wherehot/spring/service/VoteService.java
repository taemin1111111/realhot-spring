package com.wherehot.spring.service;

import com.wherehot.spring.entity.VoteNowHot;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 투표 서비스 인터페이스
 */
public interface VoteService {
    
    // VoteNowHot 관련
    VoteNowHot saveVoteNowHot(VoteNowHot vote);
    Optional<VoteNowHot> findVoteNowHotByUserAndHotplace(String userId, int hotplaceId);
    List<VoteNowHot> findVoteNowHotByHotplace(int hotplaceId);
    VoteNowHot updateVoteNowHot(VoteNowHot vote);
    boolean deleteVoteNowHot(int id);
    Double getAverageScoreByHotplace(int hotplaceId);
    int getVoteNowHotCountByHotplace(int hotplaceId);
    List<Map<String, Object>> getPopularHotplacesByRegion(String region, int limit);
    
    
    // 투표 제출 및 현황 조회
    
    // VoteController에서 필요한 메서드들
    boolean addNowHotVote(int hotplaceId, String voterId, String congestion, String genderRatio, String waitTime);
    Map<String, Object> getNowHotVoteStats(int hotplaceId);
    Map<String, Object> getVoteTrends(int placeId);
    int getVoteCount(int placeId);
    boolean isWished(int hotplaceId, String userid);
    boolean toggleWish(int hotplaceId, String userid);
    int getWishCount(int hotplaceId);
    
    // 오늘 핫 랭킹
    List<Map<String, Object>> getTodayHotRanking();
}
