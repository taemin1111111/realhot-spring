package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.VoteNowHot;
import com.wherehot.spring.mapper.VoteMapper;
import com.wherehot.spring.service.VoteService;
import com.wherehot.spring.service.SecurityUtils;
import com.wherehot.spring.service.ExpService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    
    @Autowired
    private SecurityUtils securityUtils;
    
    @Autowired
    private ExpService expService;
    
    // VoteNowHot 관련
    @Override
    public VoteNowHot saveVoteNowHot(VoteNowHot vote) {
        try {
            vote.setVotedAt(LocalDateTime.now());
            
            int result = voteMapper.insertVoteNowHot(vote);
            if (result > 0) {
                logger.info("VoteNowHot saved successfully: voterId={}, placeId={}", 
                    vote.getVoterId(), vote.getPlaceId());
                return vote;
            } else {
                throw new RuntimeException("현재 핫 투표 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving VoteNowHot: voterId={}, placeId={}", 
                vote.getVoterId(), vote.getPlaceId(), e);
            throw new RuntimeException("현재 핫 투표 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<VoteNowHot> findVoteNowHotByUserAndHotplace(String voterId, int placeId) {
        try {
            return voteMapper.findVoteNowHotByUserAndHotplace(voterId, placeId);
        } catch (Exception e) {
            logger.error("Error finding VoteNowHot by user and hotplace: voterId={}, placeId={}", voterId, placeId, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<VoteNowHot> findVoteNowHotByHotplace(int placeId) {
        try {
            return voteMapper.findVoteNowHotByHotplace(placeId);
        } catch (Exception e) {
            logger.error("Error finding VoteNowHot by hotplace: {}", placeId, e);
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
                logger.warn("VoteNowHot not found for deletion: {}", id);
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting VoteNowHot: {}", id, e);
            throw new RuntimeException("현재 핫 투표 삭제 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Double getAverageScoreByHotplace(int hotplaceId) {
        try {
            return voteMapper.getAverageScoreByHotplace(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting average score by hotplace: {}", hotplaceId, e);
            return 0.0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getVoteNowHotCountByHotplace(int hotplaceId) {
        try {
            return voteMapper.countVoteNowHotByHotplace(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting vote count by hotplace: {}", hotplaceId, e);
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
    
    @Override
    @Transactional(readOnly = true)
    public int getVoteCount(int placeId) {
        try {
            logger.info("=== getVoteCount called with placeId: {} ===", placeId);
            int count = voteMapper.getVoteCount(placeId);
            logger.info("=== Vote count retrieved for place: {} = {} ===", placeId, count);
            return count;
        } catch (Exception e) {
            logger.error("Error getting vote count for place: {}", placeId, e);
            return 0;
        }
    }
    
    // VoteController에서 필요한 메서드들 구현
    @Override
    public boolean addNowHotVote(int hotplaceId, String voterId, String congestion, String genderRatio, String waitTime) {
        return addNowHotVoteWithSecurity(hotplaceId, voterId, congestion, genderRatio, waitTime, null, null);
    }
    
    /**
     * 보안 정보를 포함한 투표 추가
     */
    public boolean addNowHotVoteWithSecurity(int hotplaceId, String voterId, String congestion, 
                                           String genderRatio, String waitTime, String userAgent, String ipAddress) {
        try {
            // 1. 중복 투표 방지 (같은 가게에 하루 1번) - 날짜 조건 포함
            Optional<VoteNowHot> existingVote = voteMapper.findVoteNowHotByUserAndHotplace(voterId, hotplaceId);
            if (existingVote.isPresent()) {
                logger.warn("User {} already voted for hotplace {} today", voterId, hotplaceId);
                throw new RuntimeException("이미 오늘 이 장소에 투표하셨습니다.");
            }
            
            // 2. 동적 투표 제한 (IP별 상황에 맞는 제한)
            String userAgentHash = securityUtils.generateUserAgentHash(userAgent);
            int maxVotes = securityUtils.calculateMaxVotesByIp(ipAddress, userAgentHash);
            int currentVoteCount = voteMapper.getTodayVotePlaceCount(voterId);
            
            if (currentVoteCount >= maxVotes) {
                logger.warn("User/IP {} exceeded dynamic vote limit ({} places, current: {})", 
                           voterId, maxVotes, currentVoteCount);
                throw new RuntimeException(String.format("하루 최대 %d곳까지만 투표 가능합니다.", maxVotes));
            }
            
            // 3. 보안 정보 처리
            boolean isVpnProxy = securityUtils.isVpnOrProxy(ipAddress);
            int riskScore = securityUtils.calculateRiskScore(ipAddress, userAgent, isVpnProxy);
            
            // 3-1. User-Agent 해시 기반 추가 검증
            if (securityUtils.isSuspiciousUserAgentHash(userAgentHash)) {
                logger.warn("의심스러운 User-Agent 해시 감지: {}, voterId={}", userAgentHash, voterId);
                riskScore += 20; // 위험도 점수 추가
            }
            
            // 3-2. 동일 User-Agent 해시로 과도한 투표 체크
            int userAgentVoteCount = voteMapper.getVoteCountByUserAgentHash(userAgentHash);
            if (userAgentVoteCount > 5) {
                logger.warn("동일 User-Agent로 과도한 투표: {}, count={}", userAgentHash, userAgentVoteCount);
                riskScore += 15; // 위험도 점수 추가
            }
            
            // 4. 새 투표 생성
            VoteNowHot vote = new VoteNowHot();
            vote.setVoterId(voterId);
            vote.setPlaceId(hotplaceId);
            vote.setCongestion(congestion);
            vote.setGenderRatio(genderRatio);
            vote.setWaitTime(waitTime);
            vote.setVotedAt(LocalDateTime.now());
            
            // 보안 정보 설정
            vote.setUserAgentHash(userAgentHash);
            vote.setVpnProxy(isVpnProxy);
            vote.setRiskScore(riskScore);
            
            // 5. vote_nowhot 테이블에 저장
            int result1 = voteMapper.insertVoteNowHot(vote);
            
            // 6. vote_nowhot_log 테이블에 저장 (히스토리용)
            int result2 = voteMapper.insertVoteNowHotLog(vote);
            
            boolean success = result1 > 0 && result2 > 0;
            if (success) {
                logger.info("Vote added successfully: placeId={}, voterId={}, riskScore={}, isVpn={}", 
                           hotplaceId, voterId, riskScore, isVpnProxy);
                
                // 투표 경험치 지급 (1회 = +1 Exp, 하루 최대 4 Exp)
                try {
                    boolean expAdded = expService.addVoteExp(voterId, 1);
                    if (expAdded) {
                        logger.info("Vote exp added successfully for user: {}", voterId);
                    } else {
                        logger.info("Vote exp not added (daily limit reached) for user: {}", voterId);
                    }
                } catch (Exception e) {
                    logger.error("Error adding vote exp for user: {}", voterId, e);
                    // 경험치 지급 실패는 투표 자체를 실패시키지 않음
                }
                
                return true;
            } else {
                logger.error("Failed to insert vote: placeId={}, voterId={}, result1={}, result2={}", 
                           hotplaceId, voterId, result1, result2);
                throw new RuntimeException("투표 저장에 실패했습니다.");
            }
            
        } catch (RuntimeException e) {
            // 비즈니스 로직 예외는 다시 던짐
            throw e;
        } catch (Exception e) {
            logger.error("Error adding vote: placeId={}, voterId={}", hotplaceId, voterId, e);
            throw new RuntimeException("투표 처리 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Map<String, Object> getNowHotVoteStats(int hotplaceId) {
        Map<String, Object> stats = new HashMap<>();
        try {
            int totalVotes = voteMapper.getVoteCount(hotplaceId);
            stats.put("totalVotes", totalVotes);
            stats.put("success", true);
        } catch (Exception e) {
            logger.error("Error getting vote stats for hotplace: {}", hotplaceId, e);
            stats.put("success", false);
            stats.put("error", "통계 조회 중 오류가 발생했습니다.");
        }
        return stats;
    }
    
    @Override
    public Map<String, Object> getVoteTrends(int placeId) {
        try {
            return voteMapper.getVoteTrends(placeId);
        } catch (Exception e) {
            logger.error("Error getting vote trends for place: {}", placeId, e);
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
            boolean isWished = voteMapper.isWished(userid, hotplaceId);
            if (isWished) {
                voteMapper.deleteWishlist(userid, hotplaceId);
                logger.info("Wish removed: hotplaceId={}, userid={}", hotplaceId, userid);
                return false;
            } else {
                voteMapper.insertWishlist(userid, hotplaceId);
                logger.info("Wish added: hotplaceId={}, userid={}", hotplaceId, userid);
                
                // 찜하기 경험치 지급 (1개 = +1 Exp, 하루 최대 3 Exp)
                try {
                    boolean expAdded = expService.addWishExp(userid, 1);
                    if (expAdded) {
                        logger.info("Wish exp added successfully for user: {}", userid);
                    } else {
                        logger.info("Wish exp not added (daily limit reached) for user: {}", userid);
                    }
                } catch (Exception e) {
                    logger.error("Error adding wish exp for user: {}", userid, e);
                    // 경험치 지급 실패는 찜하기 자체를 실패시키지 않음
                }
                
                return true;
            }
        } catch (Exception e) {
            logger.error("Error toggling wish: hotplaceId={}, userid={}", hotplaceId, userid, e);
            throw new RuntimeException("위시리스트 처리 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public int getWishCount(int hotplaceId) {
        try {
            return voteMapper.getWishCount(hotplaceId);
        } catch (Exception e) {
            logger.error("Error getting wish count: hotplaceId={}", hotplaceId, e);
            return 0;
        }
    }
    
    @Override
    public List<Map<String, Object>> getTodayHotRanking() {
        try {
            return voteMapper.getTodayHotRanking();
        } catch (Exception e) {
            logger.error("Error getting today hot ranking", e);
            return List.of();
        }
    }
}