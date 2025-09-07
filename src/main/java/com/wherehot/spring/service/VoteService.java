package com.wherehot.spring.service;

import com.wherehot.spring.entity.VoteNowHot;
import com.wherehot.spring.entity.VoteToday;
import com.wherehot.spring.entity.VoteTodayLog;

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
    
    // VoteToday 관련
    VoteToday saveVoteToday(VoteToday vote);
    Optional<VoteToday> findVoteTodayByUserAndDate(String userId, LocalDate voteDate);
    List<VoteToday> findVoteTodayByDate(LocalDate voteDate);
    List<VoteToday> findVoteTodayByHotplaceAndDate(int hotplaceId, LocalDate voteDate);
    VoteToday updateVoteToday(VoteToday vote);
    boolean deleteVoteToday(int id);
    int getVoteTodayCountByHotplaceAndDate(int hotplaceId, LocalDate voteDate);
    int getVoteTodayCountByDate(LocalDate voteDate);
    List<Map<String, Object>> getTodayPopularHotplaces(LocalDate voteDate, int limit);
    
    // VoteTodayLog 관련
    VoteTodayLog saveVoteTodayLog(VoteTodayLog log);
    List<VoteTodayLog> findVoteTodayLogByDate(LocalDate logDate);
    List<VoteTodayLog> findVoteTodayLogByHotplace(int hotplaceId, int page, int size);
    List<VoteTodayLog> findVoteTodayLogByDateRange(LocalDate startDate, LocalDate endDate);
    VoteTodayLog updateVoteTodayLog(VoteTodayLog log);
    boolean deleteVoteTodayLog(int id);
    List<VoteTodayLog> getTodayRanking(LocalDate logDate, int limit);
    List<Map<String, Object>> getMonthlyPopularHotplaces(int year, int month, int limit);
    List<Map<String, Object>> getVoteStatisticsByRegion(LocalDate startDate, LocalDate endDate);
    List<Map<String, Object>> getVoteStatisticsByCategory(LocalDate startDate, LocalDate endDate);
    
    // 투표 제출 및 현황 조회
    
    // VoteController에서 필요한 메서드들
    boolean addNowHotVote(int hotplaceId, String voterId, String congestion, String genderRatio, String waitTime);
    Map<String, Object> getNowHotVoteStats(int hotplaceId);
    Map<String, Object> getVoteTrends(int placeId);
    int getVoteCount(int placeId);
    boolean isWished(int hotplaceId, String userid);
    boolean toggleWish(int hotplaceId, String userid);
    int getWishCount(int hotplaceId);
}
