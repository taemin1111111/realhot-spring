package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.DailyExpLog;
import com.wherehot.spring.entity.Level;
import com.wherehot.spring.entity.LevelLog;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.mapper.DailyExpLogMapper;
import com.wherehot.spring.mapper.LevelLogMapper;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.service.ExpService;
import com.wherehot.spring.service.LevelService;
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

/**
 * 경험치 시스템 서비스 구현체
 */
@Service
@Transactional
public class ExpServiceImpl implements ExpService {
    
    private static final Logger logger = LoggerFactory.getLogger(ExpServiceImpl.class);
    
    // 경험치 지급 규칙 상수
    private static final int VOTE_EXP_PER_ACTION = 1;
    private static final int VOTE_EXP_DAILY_MAX = 4;
    
    private static final int HPOST_EXP_PER_ACTION = 10;
    private static final int HPOST_EXP_DAILY_MAX = 10;
    
    private static final int COURSE_EXP_PER_ACTION = 25;
    private static final int COURSE_EXP_DAILY_MAX = 25;
    
    private static final int COMMENT_EXP_PER_ACTION = 3;
    private static final int LIKE_EXP_PER_ACTION = 2;
    private static final int COMMENT_LIKE_EXP_DAILY_MAX = 10;
    
    private static final int WISH_EXP_PER_ACTION = 1;
    private static final int WISH_EXP_DAILY_MAX = 3;
    
    // 하루 총 경험치 제한
    private static final int TOTAL_DAILY_EXP_MAX = 50;
    
    @Autowired
    private DailyExpLogMapper dailyExpLogMapper;
    
    @Autowired
    private LevelLogMapper levelLogMapper;
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private LevelService levelService;
    
    @Override
    public boolean addVoteExp(String userId, int amount) {
        try {
            return addExpWithLimit(userId, "vote", amount, VOTE_EXP_PER_ACTION, VOTE_EXP_DAILY_MAX);
        } catch (Exception e) {
            logger.error("Error adding vote exp for user: {}", userId, e);
            return false;
        }
    }
    
    @Override
    public boolean addHpostExp(String userId, int amount) {
        try {
            return addExpWithLimit(userId, "hpost", amount, HPOST_EXP_PER_ACTION, HPOST_EXP_DAILY_MAX);
        } catch (Exception e) {
            logger.error("Error adding hpost exp for user: {}", userId, e);
            return false;
        }
    }
    
    @Override
    public boolean addCourseExp(String userId, int amount) {
        try {
            return addExpWithLimit(userId, "course", amount, COURSE_EXP_PER_ACTION, COURSE_EXP_DAILY_MAX);
        } catch (Exception e) {
            logger.error("Error adding course exp for user: {}", userId, e);
            return false;
        }
    }
    
    @Override
    public boolean addCommentExp(String userId, int amount) {
        try {
            return addExpWithLimit(userId, "comment", amount, COMMENT_EXP_PER_ACTION, COMMENT_LIKE_EXP_DAILY_MAX);
        } catch (Exception e) {
            logger.error("Error adding comment exp for user: {}", userId, e);
            return false;
        }
    }
    
    @Override
    public boolean addLikeExp(String userId, int amount) {
        try {
            return addExpWithLimit(userId, "like", amount, LIKE_EXP_PER_ACTION, COMMENT_LIKE_EXP_DAILY_MAX);
        } catch (Exception e) {
            logger.error("Error adding like exp for user: {}", userId, e);
            return false;
        }
    }
    
    @Override
    public boolean addWishExp(String userId, int amount) {
        try {
            return addExpWithLimit(userId, "wish", amount, WISH_EXP_PER_ACTION, WISH_EXP_DAILY_MAX);
        } catch (Exception e) {
            logger.error("Error adding wish exp for user: {}", userId, e);
            return false;
        }
    }
    
    /**
     * 경험치 지급 (일일 한도 체크 포함)
     */
    private boolean addExpWithLimit(String userId, String expType, int amount, int expPerAction, int dailyMax) {
        try {
            // 오늘의 경험치 로그 조회
            DailyExpLog todayLog = getTodayExpLogInternal(userId);
            
            // 하루 총 경험치 제한 체크
            int currentTotalTodayExp = getTodayTotalExp(userId);
            if (currentTotalTodayExp >= TOTAL_DAILY_EXP_MAX) {
                logger.info("Total daily exp limit reached. User: {}, Current Total: {}, Max: {}", 
                    userId, currentTotalTodayExp, TOTAL_DAILY_EXP_MAX);
                return false;
            }
            
            // 현재 해당 타입의 오늘 경험치 조회
            int currentTodayExp = getTodayExpByType(userId, expType);
            
            // 일일 한도 체크
            int availableExp = dailyMax - currentTodayExp;
            if (availableExp <= 0) {
                logger.info("Daily limit reached for {} exp. User: {}, Current: {}, Max: {}", 
                    expType, userId, currentTodayExp, dailyMax);
                return false;
            }
            
            // 실제 지급할 경험치 계산 (개별 활동 제한 고려)
            int requestedExp = amount * expPerAction;
            int actualExp = Math.min(requestedExp, availableExp);
            
            // 총 경험치 제한을 고려한 실제 지급 경험치 재계산
            int totalAvailableExp = TOTAL_DAILY_EXP_MAX - currentTotalTodayExp;
            actualExp = Math.min(actualExp, totalAvailableExp);
            
            // 실제 지급할 경험치가 0이면 false 반환
            if (actualExp <= 0) {
                logger.info("No exp can be added due to total daily limit. User: {}, Total: {}/{}", 
                    userId, currentTotalTodayExp, TOTAL_DAILY_EXP_MAX);
                return false;
            }
            
            // 부분 지급 로그 (요청한 경험치와 실제 지급된 경험치가 다른 경우)
            if (actualExp < requestedExp) {
                logger.info("Partial exp granted due to daily limit. User: {}, Requested: {}, Granted: {}, Total: {}/{}", 
                    userId, requestedExp, actualExp, currentTotalTodayExp + actualExp, TOTAL_DAILY_EXP_MAX);
            }
            
            // 경험치 로그 업데이트
            updateDailyExpLog(todayLog, expType, actualExp);
            
            // 사용자의 총 경험치 업데이트
            updateUserTotalExp(userId, actualExp);
            
            logger.info("Added {} exp for user: {}, type: {}, amount: {}", 
                actualExp, userId, expType, amount);
            
            // 레벨업 체크
            checkAndProcessLevelUp(userId);
            
            return true;
            
        } catch (Exception e) {
            logger.error("Error adding exp with limit for user: {}, type: {}", userId, expType, e);
            return false;
        }
    }
    
    /**
     * 오늘의 경험치 로그 조회 (없으면 생성) - 내부용
     */
    private DailyExpLog getTodayExpLogInternal(String userId) {
        DailyExpLog todayLog = dailyExpLogMapper.selectTodayByUserId(userId);
        
        if (todayLog == null) {
            // 오늘 로그가 없으면 생성
            todayLog = new DailyExpLog(userId, LocalDate.now());
            dailyExpLogMapper.insertDailyExpLog(todayLog);
            logger.info("Created new daily exp log for user: {}", userId);
        }
        
        return todayLog;
    }
    
    /**
     * 일일 경험치 로그 업데이트
     */
    private void updateDailyExpLog(DailyExpLog log, String expType, int amount) {
        log.addExp(expType, amount);
        dailyExpLogMapper.updateDailyExpLog(log);
    }
    
    /**
     * 사용자의 총 경험치 업데이트
     */
    private void updateUserTotalExp(String userId, int amount) {
        // 익명 사용자는 경험치를 받지 않음 (member 테이블에 없음)
        if (userId == null || userId.startsWith("anonymous|")) {
            logger.info("Anonymous user {} cannot receive exp (not in member table)", userId);
            return;
        }
        
        var memberOpt = memberMapper.findByUserid(userId);
        if (memberOpt.isPresent()) {
            Member member = memberOpt.get();
            int oldExp = member.getExp();
            member.setExp(member.getExp() + amount);
            member.setUpdateDate(LocalDateTime.now());
            memberMapper.updateMember(member);
            logger.info("Updated user {} exp: {} -> {}", userId, oldExp, member.getExp());
        } else {
            logger.warn("User {} not found in member table, cannot update exp", userId);
        }
    }
    
    @Override
    public int getTodayExpByType(String userId, String expType) {
        try {
            return dailyExpLogMapper.selectTodayExpByType(userId, expType);
        } catch (Exception e) {
            logger.error("Error getting today exp by type for user: {}, type: {}", userId, expType, e);
            return 0;
        }
    }
    
    @Override
    public int getTodayTotalExp(String userId) {
        try {
            return dailyExpLogMapper.selectTodayTotalExp(userId);
        } catch (Exception e) {
            logger.error("Error getting today total exp for user: {}", userId, e);
            return 0;
        }
    }
    
    @Override
    public DailyExpLog getTodayExpLog(String userId) {
        try {
            return dailyExpLogMapper.selectTodayByUserId(userId);
        } catch (Exception e) {
            logger.error("Error getting today exp log for user: {}", userId, e);
            return null;
        }
    }
    
    @Override
    public boolean checkAndProcessLevelUp(String userId) {
        try {
            // 익명 사용자는 레벨업 체크하지 않음
            if (userId == null || userId.startsWith("anonymous|")) {
                logger.info("Anonymous user {} cannot level up (not in member table)", userId);
                return false;
            }
            
            var memberOpt = memberMapper.findByUserid(userId);
            if (!memberOpt.isPresent()) {
                return false;
            }
            
            Member member = memberOpt.get();
            int currentExp = member.getExp();
            int currentLevelId = member.getLevelId();
            
            // 현재 경험치에 맞는 레벨 조회
            Level newLevel = levelService.getLevelByExp(currentExp);
            
            if (newLevel != null && newLevel.getLevelId() > currentLevelId) {
                // 레벨업 발생
                int oldLevelId = currentLevelId;
                int gainedExp = currentExp - member.getExp(); // 이번에 얻은 경험치
                
                // 사용자 레벨 업데이트
                member.setLevelId(newLevel.getLevelId());
                member.setUpdateDate(LocalDateTime.now());
                memberMapper.updateMember(member);
                
                // 레벨업 로그 기록
                LevelLog levelLog = new LevelLog(userId, oldLevelId, newLevel.getLevelId(), gainedExp);
                levelLogMapper.insertLevelLog(levelLog);
                
                logger.info("Level up! User: {}, Old Level: {}, New Level: {}, Gained Exp: {}", 
                    userId, oldLevelId, newLevel.getLevelId(), gainedExp);
                
                return true;
            }
            
            return false;
            
        } catch (Exception e) {
            logger.error("Error checking level up for user: {}", userId, e);
            return false;
        }
    }
    
    @Override
    public LevelService.LevelInfo getUserLevelInfo(String userId) {
        try {
            var memberOpt = memberMapper.findByUserid(userId);
            if (!memberOpt.isPresent()) {
                return null;
            }
            
            Member member = memberOpt.get();
            return levelService.getUserLevelInfo(member.getExp());
            
        } catch (Exception e) {
            logger.error("Error getting user level info for user: {}", userId, e);
            return null;
        }
    }
    
    @Override
    public List<DailyExpLog> getRecentExpLogs(String userId, int limit) {
        try {
            return dailyExpLogMapper.selectRecentByUserId(userId, limit);
        } catch (Exception e) {
            logger.error("Error getting recent exp logs for user: {}", userId, e);
            return List.of();
        }
    }
    
    @Override
    public List<LevelLog> getRecentLevelLogs(String userId, int limit) {
        try {
            return levelLogMapper.selectRecentByUserId(userId, limit);
        } catch (Exception e) {
            logger.error("Error getting recent level logs for user: {}", userId, e);
            return List.of();
        }
    }
    
    @Override
    public boolean canAddExpToday(String userId, String expType, int amount) {
        try {
            int currentTodayExp = getTodayExpByType(userId, expType);
            int dailyMax = getDailyMaxForType(expType);
            return (currentTodayExp + amount) <= dailyMax;
        } catch (Exception e) {
            logger.error("Error checking if can add exp today for user: {}, type: {}", userId, expType, e);
            return false;
        }
    }
    
    @Override
    public boolean canAddTotalExpToday(String userId, int amount) {
        try {
            int todayTotal = getTodayTotalExp(userId);
            return (todayTotal + amount) <= TOTAL_DAILY_EXP_MAX;
        } catch (Exception e) {
            logger.error("Error checking if can add total exp today for user: {}", userId, e);
            return false;
        }
    }
    
    /**
     * 경험치 타입별 일일 한도 조회
     */
    private int getDailyMaxForType(String expType) {
        switch (expType) {
            case "vote": return VOTE_EXP_DAILY_MAX;
            case "hpost": return HPOST_EXP_DAILY_MAX;
            case "course": return COURSE_EXP_DAILY_MAX;
            case "comment":
            case "like": return COMMENT_LIKE_EXP_DAILY_MAX;
            case "wish": return WISH_EXP_DAILY_MAX;
            default: return 0;
        }
    }
}