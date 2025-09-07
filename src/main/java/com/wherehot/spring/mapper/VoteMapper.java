package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.VoteNowHot;
import com.wherehot.spring.entity.VoteToday;
import com.wherehot.spring.entity.VoteTodayLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 투표 MyBatis Mapper
 */
@Mapper
public interface VoteMapper {
    
    // ========== VoteNowHot 관련 ==========
    
    /**
     * 현재 핫플레이스 투표 등록
     */
    int insertVoteNowHot(VoteNowHot vote);
    
    /**
     * 투표 로그 등록 (Model1 호환)
     */
    int insertVoteNowHotLog(VoteNowHot vote);
    
    /**
     * 사용자별 핫플레이스 투표 조회
     */
    Optional<VoteNowHot> findVoteNowHotByUserAndHotplace(@Param("userId") String userId, 
                                                        @Param("hotplaceId") int hotplaceId);
    
    /**
     * 핫플레이스별 투표 목록 조회
     */
    List<VoteNowHot> findVoteNowHotByHotplace(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 현재 핫플레이스 투표 수정
     */
    int updateVoteNowHot(VoteNowHot vote);
    
    /**
     * 현재 핫플레이스 투표 삭제
     */
    int deleteVoteNowHot(@Param("id") int id);
    
    /**
     * 핫플레이스별 평균 점수 조회
     */
    Double getAverageScoreByHotplace(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 핫플레이스별 투표 수 조회
     */
    int countVoteNowHotByHotplace(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 지역별 인기 핫플레이스 조회
     */
    List<Map<String, Object>> findPopularHotplacesByRegion(@Param("region") String region, 
                                                          @Param("limit") int limit);
    
    // ========== VoteToday 관련 ==========
    
    /**
     * 오늘의 핫플레이스 투표 등록
     */
    int insertVoteToday(VoteToday vote);
    
    /**
     * 사용자별 오늘의 투표 조회
     */
    Optional<VoteToday> findVoteTodayByUserAndDate(@Param("userId") String userId, 
                                                   @Param("voteDate") LocalDate voteDate);
    
    /**
     * 날짜별 투표 목록 조회
     */
    List<VoteToday> findVoteTodayByDate(@Param("voteDate") LocalDate voteDate);
    
    /**
     * 핫플레이스별 오늘의 투표 조회
     */
    List<VoteToday> findVoteTodayByHotplaceAndDate(@Param("hotplaceId") int hotplaceId, 
                                                   @Param("voteDate") LocalDate voteDate);
    
    /**
     * 오늘의 핫플레이스 투표 수정
     */
    int updateVoteToday(VoteToday vote);
    
    /**
     * 오늘의 핫플레이스 투표 삭제
     */
    int deleteVoteToday(@Param("id") int id);
    
    /**
     * 날짜별 핫플레이스 투표 수 조회
     */
    int countVoteTodayByHotplaceAndDate(@Param("hotplaceId") int hotplaceId, 
                                       @Param("voteDate") LocalDate voteDate);
    
    /**
     * 날짜별 총 투표 수 조회
     */
    int countVoteTodayByDate(@Param("voteDate") LocalDate voteDate);
    
    /**
     * 오늘의 인기 핫플레이스 조회
     */
    List<Map<String, Object>> findTodayPopularHotplaces(@Param("voteDate") LocalDate voteDate, 
                                                        @Param("limit") int limit);
    
    // ========== VoteTodayLog 관련 ==========
    
    /**
     * 오늘의 핫플레이스 로그 등록
     */
    int insertVoteTodayLog(VoteTodayLog log);
    
    /**
     * 날짜별 로그 조회
     */
    List<VoteTodayLog> findVoteTodayLogByDate(@Param("logDate") LocalDate logDate);
    
    /**
     * 핫플레이스별 로그 조회
     */
    List<VoteTodayLog> findVoteTodayLogByHotplace(@Param("hotplaceId") int hotplaceId,
                                                 @Param("offset") int offset,
                                                 @Param("size") int size);
    
    /**
     * 기간별 로그 조회
     */
    List<VoteTodayLog> findVoteTodayLogByDateRange(@Param("startDate") LocalDate startDate,
                                                  @Param("endDate") LocalDate endDate);
    
    /**
     * 로그 수정
     */
    int updateVoteTodayLog(VoteTodayLog log);
    
    /**
     * 로그 삭제
     */
    int deleteVoteTodayLog(@Param("id") int id);
    
    /**
     * 날짜별 랭킹 조회
     */
    List<VoteTodayLog> findTodayRanking(@Param("logDate") LocalDate logDate, 
                                       @Param("limit") int limit);
    
    /**
     * 월간 인기 핫플레이스 조회
     */
    List<Map<String, Object>> findMonthlyPopularHotplaces(@Param("year") int year, 
                                                          @Param("month") int month, 
                                                          @Param("limit") int limit);
    
    /**
     * 지역별 투표 통계
     */
    List<Map<String, Object>> findVoteStatisticsByRegion(@Param("startDate") LocalDate startDate,
                                                         @Param("endDate") LocalDate endDate);
    
    /**
     * 카테고리별 투표 통계
     */
    List<Map<String, Object>> findVoteStatisticsByCategory(@Param("startDate") LocalDate startDate,
                                                           @Param("endDate") LocalDate endDate);
    
    // ========== 투표 제출 및 현황 조회 ==========
    
    /**
     * 사용자가 오늘 해당 장소에 이미 투표했는지 확인 (사용자ID 또는 IP로 체크)
     */
    boolean isAlreadyVotedToday(@Param("identifier") String identifier, @Param("placeId") int placeId);
    
    /**
     * 사용자가 오늘 투표한 장소 개수 조회 (사용자ID 또는 IP로 체크)
     */
    int getTodayVotePlaceCount(@Param("identifier") String identifier);
    
    /**
     * 투표 데이터 삽입 (기존 버전 - 하위 호환성)
     */
    int insertVote(@Param("userId") String userId, @Param("placeId") int placeId, 
                  @Param("congestion") String congestion, @Param("genderRatio") String genderRatio, 
                  @Param("waitTime") String waitTime);
    
    /**
     * 투표 데이터 삽입 (JWT 토큰 + IP 주소 지원)
     */
    int insertVoteWithIp(@Param("identifier") String identifier, @Param("placeId") int placeId, 
                        @Param("congestion") String congestion, @Param("genderRatio") String genderRatio, 
                        @Param("waitTime") String waitTime, @Param("ipAddress") String ipAddress, 
                        @Param("isLoggedIn") boolean isLoggedIn);
    
    /**
     * 특정 장소의 투표 트렌드 조회 (가장 많이 투표된 옵션들)
     */
    Map<String, Object> getVoteTrends(@Param("placeId") int placeId);
    
    /**
     * 특정 장소의 총 투표 수 조회
     */
    int getVoteCount(@Param("placeId") int placeId);
    
    // ========== 찜하기 관련 ==========
    
    /**
     * 찜하기 여부 확인
     */
    boolean isWished(@Param("userid") String userid, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 찜하기 추가
     */
    int insertWishlist(@Param("userid") String userid, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 찜하기 삭제
     */
    int deleteWishlist(@Param("userid") String userid, @Param("hotplaceId") int hotplaceId);
    
    /**
     * 핫플레이스 찜 개수 조회
     */
    int getWishCount(@Param("hotplaceId") int hotplaceId);

}
