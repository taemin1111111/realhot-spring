package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.VoteNowHot;
import com.wherehot.spring.entity.VoteToday;
import com.wherehot.spring.entity.VoteTodayLog;
import com.wherehot.spring.mapper.VoteMapper;
import com.wherehot.spring.service.VoteService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@Transactional
public class VoteServiceImpl implements VoteService {
    
    private static final Logger logger = LoggerFactory.getLogger(VoteServiceImpl.class);
    
    @Autowired
    private VoteMapper voteMapper;
    
    // VoteNowHot 관련
    @Override
    public VoteNowHot saveVoteNowHot(VoteNowHot vote) {
        try {
            vote.setVotedAt(LocalDateTime.now());
            
            int result = voteMapper.insertVoteNowHot(vote);
            if (result > 0) {
                logger.info("VoteNowHot saved successfully: userId={}, hotplaceId={}", 
                    vote.getUserId(), vote.getHotplaceId());
                return vote;
            } else {
                throw new RuntimeException("현재 핫 투표 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving VoteNowHot: userId={}, hotplaceId={}", 
                vote.getUserId(), vote.getHotplaceId(), e);
            throw new RuntimeException("현재 핫 투표 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<VoteNowHot> findVoteNowHotByUserAndHotplace(String userId, int hotplaceId) {
        try {
            return voteMapper.findVoteNowHotByUserAndHotplace(userId, hotplaceId);
        } catch (Exception e) {
            logger.error("Error finding VoteNowHot by user and hotplace: userId={}, hotplaceId={}", userId, hotplaceId, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteNowHot> findVoteNowHotByHotplace(int hotplaceId) {
        try {
            return voteMapper.findVoteNowHotByHotplace(hotplaceId);
        } catch (Exception e) {
            logger.error("Error finding VoteNowHot by hotplace: {}", hotplaceId, e);
            throw new RuntimeException("핫플레이스별 현재 핫 투표 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public VoteNowHot updateVoteNowHot(VoteNowHot vote) {
        try {
            vote.setVotedAt(LocalDateTime.now());
            
            int result = voteMapper.updateVoteNowHot(vote);
            if (result > 0) {
                logger.info("VoteNowHot updated successfully: {}", vote.getId());
                return vote;
            } else {
                throw new RuntimeException("현재 핫 투표 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating VoteNowHot: {}", vote.getId(), e);
            throw new RuntimeException("현재 핫 투표 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteVoteNowHot(int id) {
        try {
            int result = voteMapper.deleteVoteNowHot(id);
            if (result > 0) {
                logger.info("VoteNowHot deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting VoteNowHot: {}", id, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Double getAverageScoreByHotplace(int hotplaceId) {
        try {
            return voteMapper.getAverageScoreByHotplace(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting average score by hotplace: {}", hotplaceId, e);
            return null;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getVoteNowHotCountByHotplace(int hotplaceId) {
        try {
            return voteMapper.countVoteNowHotByHotplace(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting VoteNowHot count by hotplace: {}", hotplaceId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getPopularHotplacesByRegion(String region, int limit) {
        try {
            return voteMapper.findPopularHotplacesByRegion(region, limit);
        } catch (Exception e) {
            logger.error("Error getting popular hotplaces by region: {}", region, e);
            throw new RuntimeException("지역별 인기 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    // VoteToday 관련
    @Override
    public VoteToday saveVoteToday(VoteToday vote) {
        try {
            vote.setCreatedAt(LocalDateTime.now());
            
            int result = voteMapper.insertVoteToday(vote);
            if (result > 0) {
                logger.info("VoteToday saved successfully: userId={}, voteDate={}", 
                    vote.getUserId(), vote.getVoteDate());
                return vote;
            } else {
                throw new RuntimeException("오늘의 투표 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving VoteToday: userId={}, voteDate={}", 
                vote.getUserId(), vote.getVoteDate(), e);
            throw new RuntimeException("오늘의 투표 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<VoteToday> findVoteTodayByUserAndDate(String userId, LocalDate voteDate) {
        try {
            return voteMapper.findVoteTodayByUserAndDate(userId, voteDate);
        } catch (Exception e) {
            logger.error("Error finding VoteToday by user and date: userId={}, voteDate={}", userId, voteDate, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteToday> findVoteTodayByDate(LocalDate voteDate) {
        try {
            return voteMapper.findVoteTodayByDate(voteDate);
        } catch (Exception e) {
            logger.error("Error finding VoteToday by date: {}", voteDate, e);
            throw new RuntimeException("날짜별 오늘의 투표 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteToday> findVoteTodayByHotplaceAndDate(int hotplaceId, LocalDate voteDate) {
        try {
            return voteMapper.findVoteTodayByHotplaceAndDate(hotplaceId, voteDate);
        } catch (Exception e) {
            logger.error("Error finding VoteToday by hotplace and date: hotplaceId={}, voteDate={}", hotplaceId, voteDate, e);
            throw new RuntimeException("핫플레이스별 오늘의 투표 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public VoteToday updateVoteToday(VoteToday vote) {
        try {
            vote.setUpdatedAt(LocalDateTime.now());
            
            int result = voteMapper.updateVoteToday(vote);
            if (result > 0) {
                logger.info("VoteToday updated successfully: {}", vote.getId());
                return vote;
            } else {
                throw new RuntimeException("오늘의 투표 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating VoteToday: {}", vote.getId(), e);
            throw new RuntimeException("오늘의 투표 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteVoteToday(int id) {
        try {
            int result = voteMapper.deleteVoteToday(id);
            if (result > 0) {
                logger.info("VoteToday deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting VoteToday: {}", id, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getVoteTodayCountByHotplaceAndDate(int hotplaceId, LocalDate voteDate) {
        try {
            return voteMapper.countVoteTodayByHotplaceAndDate(hotplaceId, voteDate);
        } catch (Exception e) {
            logger.error("Error getting VoteToday count by hotplace and date: hotplaceId={}, voteDate={}", hotplaceId, voteDate, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getVoteTodayCountByDate(LocalDate voteDate) {
        try {
            return voteMapper.countVoteTodayByDate(voteDate);
        } catch (Exception e) {
            logger.error("Error getting VoteToday count by date: {}", voteDate, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTodayPopularHotplaces(LocalDate voteDate, int limit) {
        try {
            return voteMapper.findTodayPopularHotplaces(voteDate, limit);
        } catch (Exception e) {
            logger.error("Error getting today popular hotplaces: voteDate={}", voteDate, e);
            throw new RuntimeException("오늘의 인기 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    // VoteTodayLog 관련
    @Override
    public VoteTodayLog saveVoteTodayLog(VoteTodayLog log) {
        try {
            log.setCreatedAt(LocalDateTime.now());
            
            int result = voteMapper.insertVoteTodayLog(log);
            if (result > 0) {
                logger.info("VoteTodayLog saved successfully: hotplaceId={}, logDate={}", 
                    log.getHotplaceId(), log.getLogDate());
                return log;
            } else {
                throw new RuntimeException("오늘의 투표 로그 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving VoteTodayLog: hotplaceId={}, logDate={}", 
                log.getHotplaceId(), log.getLogDate(), e);
            throw new RuntimeException("오늘의 투표 로그 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteTodayLog> findVoteTodayLogByDate(LocalDate logDate) {
        try {
            return voteMapper.findVoteTodayLogByDate(logDate);
        } catch (Exception e) {
            logger.error("Error finding VoteTodayLog by date: {}", logDate, e);
            throw new RuntimeException("날짜별 투표 로그 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteTodayLog> findVoteTodayLogByHotplace(int hotplaceId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return voteMapper.findVoteTodayLogByHotplace(hotplaceId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding VoteTodayLog by hotplace: {}", hotplaceId, e);
            throw new RuntimeException("핫플레이스별 투표 로그 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteTodayLog> findVoteTodayLogByDateRange(LocalDate startDate, LocalDate endDate) {
        try {
            return voteMapper.findVoteTodayLogByDateRange(startDate, endDate);
        } catch (Exception e) {
            logger.error("Error finding VoteTodayLog by date range: startDate={}, endDate={}", startDate, endDate, e);
            throw new RuntimeException("기간별 투표 로그 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public VoteTodayLog updateVoteTodayLog(VoteTodayLog log) {
        try {
            log.setUpdatedAt(LocalDateTime.now());
            
            int result = voteMapper.updateVoteTodayLog(log);
            if (result > 0) {
                logger.info("VoteTodayLog updated successfully: {}", log.getId());
                return log;
            } else {
                throw new RuntimeException("투표 로그 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating VoteTodayLog: {}", log.getId(), e);
            throw new RuntimeException("투표 로그 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteVoteTodayLog(int id) {
        try {
            int result = voteMapper.deleteVoteTodayLog(id);
            if (result > 0) {
                logger.info("VoteTodayLog deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting VoteTodayLog: {}", id, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteTodayLog> getTodayRanking(LocalDate logDate, int limit) {
        try {
            return voteMapper.findTodayRanking(logDate, limit);
        } catch (Exception e) {
            logger.error("Error getting today ranking: logDate={}", logDate, e);
            throw new RuntimeException("오늘의 랭킹 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getMonthlyPopularHotplaces(int year, int month, int limit) {
        try {
            return voteMapper.findMonthlyPopularHotplaces(year, month, limit);
        } catch (Exception e) {
            logger.error("Error getting monthly popular hotplaces: year={}, month={}", year, month, e);
            throw new RuntimeException("월별 인기 핫플레이스 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getVoteStatisticsByRegion(LocalDate startDate, LocalDate endDate) {
        try {
            return voteMapper.findVoteStatisticsByRegion(startDate, endDate);
        } catch (Exception e) {
            logger.error("Error getting vote statistics by region: startDate={}, endDate={}", startDate, endDate, e);
            throw new RuntimeException("지역별 투표 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getVoteStatisticsByCategory(LocalDate startDate, LocalDate endDate) {
        try {
            return voteMapper.findVoteStatisticsByCategory(startDate, endDate);
        } catch (Exception e) {
            logger.error("Error getting vote statistics by category: startDate={}, endDate={}", startDate, endDate, e);
            throw new RuntimeException("카테고리별 투표 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    // ========== 투표 제출 및 현황 조회 ==========
    
    @Override
    public boolean submitVote(String userId, int placeId, String congestion, String genderRatio, String waitTime) {
        return submitVote(userId, placeId, congestion, genderRatio, waitTime, null);
    }
    
    @Override
    public boolean submitVote(String userId, int placeId, String congestion, String genderRatio, String waitTime, String ipAddress) {
        try {
            // 사용자 식별: 로그인 사용자 우선, 없으면 IP 주소 사용
            String identifier = userId != null ? userId : ipAddress;
            
            if (identifier == null) {
                throw new RuntimeException("사용자 식별 정보가 없습니다.");
            }
            
            // 1. 중복 투표 방지 (같은 가게에 하루 1번)
            if (voteMapper.isAlreadyVotedToday(identifier, placeId)) {
                logger.warn("User/IP {} already voted for place {} today", identifier, placeId);
                throw new RuntimeException("이미 오늘 이 장소에 투표하셨습니다.");
            }
            
            // 2. 하루 8곳 제한
            if (voteMapper.getTodayVotePlaceCount(identifier) >= 8) {
                logger.warn("User/IP {} exceeded daily vote limit", identifier);
                throw new RuntimeException("하루 최대 8곳까지만 투표 가능합니다.");
            }
            
            // 3. 투표 데이터 생성 (Model1과 동일)
            VoteNowHot vote = new VoteNowHot();
            vote.setPlaceId(placeId);
            vote.setVoterId(identifier);
            vote.setCongestion(congestion);
            vote.setGenderRatio(genderRatio);
            vote.setWaitTime(waitTime);
            vote.setVotedAt(LocalDateTime.now());
            
            // 4. vote_nowhot 테이블에 저장
            int result1 = voteMapper.insertVoteNowHot(vote);
            
            // 5. vote_nowhot_log 테이블에 저장 (히스토리용)  
            int result2 = voteMapper.insertVoteNowHotLog(vote);
            
            boolean success = result1 > 0 && result2 > 0;
            if (success) {
                logger.info("Vote submitted successfully: userId={}, placeId={}, ipAddress={}", userId, placeId, ipAddress);
                return true;
            } else {
                logger.error("Failed to insert vote: userId={}, placeId={}, result1={}, result2={}", userId, placeId, result1, result2);
                return false;
            }
            
        } catch (RuntimeException e) {
            // 비즈니스 로직 예외는 다시 던짐
            throw e;
        } catch (Exception e) {
            logger.error("Error submitting vote: userId={}, placeId={}, ipAddress={}", userId, placeId, ipAddress, e);
            throw new RuntimeException("투표 제출 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getVoteTrends(int placeId) {
        try {
            Map<String, Object> trends = voteMapper.getVoteTrends(placeId);
            
            if (trends == null) {
                // 투표 데이터가 없는 경우 기본값 반환
                trends = new HashMap<>();
                trends.put("congestion", "");
                trends.put("genderRatio", "");
                trends.put("waitTime", "");
            }
            
            logger.info("Vote trends retrieved for place: {}", placeId);
            return trends;
            
        } catch (Exception e) {
            logger.error("Error getting vote trends for place: {}", placeId, e);
            throw new RuntimeException("투표 현황 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    // VoteController에서 필요한 메서드들 구현
    @Override
    public boolean addNowHotVote(int hotplaceId, String voterId, String congestion, String genderRatio, String waitTime) {
        try {
            // 중복 투표 체크
            Optional<VoteNowHot> existingVote = voteMapper.findVoteNowHotByUserAndHotplace(voterId, hotplaceId);
            if (existingVote.isPresent()) {
                logger.warn("User {} already voted for hotplace {}", voterId, hotplaceId);
                return false;
            }
            
            // 새 투표 생성
            VoteNowHot vote = new VoteNowHot();
            vote.setUserId(voterId);
            vote.setHotplaceId(hotplaceId);
            vote.setCongestion(congestion);
            vote.setGenderRatio(genderRatio);
            vote.setWaitTime(waitTime);
            vote.setVotedAt(LocalDateTime.now());
            
            int result = voteMapper.insertVoteNowHot(vote);
            logger.info("Vote added: hotplaceId={}, voterId={}, result={}", hotplaceId, voterId, result);
            return result > 0;
            
        } catch (Exception e) {
            logger.error("Error adding vote: hotplaceId={}, voterId={}", hotplaceId, voterId, e);
            return false;
        }
    }
    
    @Override
    public Map<String, Object> getNowHotVoteStats(int hotplaceId) {
        try {
            Map<String, Object> stats = new HashMap<>();
            List<VoteNowHot> votes = voteMapper.findVoteNowHotByHotplace(hotplaceId);
            
            if (votes.isEmpty()) {
                stats.put("totalVotes", 0);
                stats.put("congestionStats", new HashMap<>());
                stats.put("genderStats", new HashMap<>());
                stats.put("waitStats", new HashMap<>());
                return stats;
            }
            
            // 통계 계산
            Map<String, Integer> congestionStats = new HashMap<>();
            Map<String, Integer> genderStats = new HashMap<>();
            Map<String, Integer> waitStats = new HashMap<>();
            
            for (VoteNowHot vote : votes) {
                congestionStats.merge(vote.getCongestion(), 1, Integer::sum);
                genderStats.merge(vote.getGenderRatio(), 1, Integer::sum);
                waitStats.merge(vote.getWaitTime(), 1, Integer::sum);
            }
            
            stats.put("totalVotes", votes.size());
            stats.put("congestionStats", congestionStats);
            stats.put("genderStats", genderStats);
            stats.put("waitStats", waitStats);
            
            return stats;
            
        } catch (Exception e) {
            logger.error("Error getting vote stats for hotplace: {}", hotplaceId, e);
            return new HashMap<>();
        }
    }
    
    @Override
    public boolean isWished(int hotplaceId, String userid) {
        try {
            return voteMapper.isWished(userid, hotplaceId);
        } catch (Exception e) {
            logger.error("Error checking wish status: hotplaceId={}, userid={}", hotplaceId, userid, e);
            return false;
        }
    }
    
    @Override
    public boolean toggleWish(int hotplaceId, String userid) {
        try {
            boolean isCurrentlyWished = voteMapper.isWished(userid, hotplaceId);
            
            if (isCurrentlyWished) {
                // 찜 해제
                int result = voteMapper.deleteWishlist(userid, hotplaceId);
                logger.info("Wish removed: hotplaceId={}, userid={}, result={}", hotplaceId, userid, result);
                return false; // 찜 해제됨
            } else {
                // 찜 추가
                int result = voteMapper.insertWishlist(userid, hotplaceId);
                logger.info("Wish added: hotplaceId={}, userid={}, result={}", hotplaceId, userid, result);
                return true; // 찜 추가됨
            }
            
        } catch (Exception e) {
            logger.error("Error toggling wish: hotplaceId={}, userid={}", hotplaceId, userid, e);
            throw new RuntimeException("찜하기 처리 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public int getWishCount(int hotplaceId) {
        try {
            return voteMapper.getWishCount(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting wish count for hotplace: {}", hotplaceId, e);
            return 0;
        }
    }
}
