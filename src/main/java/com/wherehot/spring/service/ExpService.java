package com.wherehot.spring.service;

import com.wherehot.spring.entity.DailyExpLog;
import com.wherehot.spring.entity.LevelLog;

import java.time.LocalDate;
import java.util.List;

/**
 * 경험치 시스템 서비스 인터페이스
 */
public interface ExpService {
    
    /**
     * 투표 경험치 지급 (1회 = +1 Exp, 하루 최대 4 Exp)
     */
    boolean addVoteExp(String userId, int amount);
    
    /**
     * 핫플썰 작성 경험치 지급 (1개 = +10 Exp, 하루 최대 10 Exp)
     */
    boolean addHpostExp(String userId, int amount);
    
    /**
     * 코스 작성 경험치 지급 (1개 = +20 Exp, 하루 최대 20 Exp)
     */
    boolean addCourseExp(String userId, int amount);
    
    /**
     * 댓글 경험치 지급 (1개 = +3 Exp)
     */
    boolean addCommentExp(String userId, int amount);
    
    /**
     * 좋아요 받은 경험치 지급 (1개 = +2 Exp)
     */
    boolean addLikeExp(String userId, int amount);
    
    /**
     * 찜하기 경험치 지급 (1개 = +1 Exp, 하루 최대 3 Exp)
     */
    boolean addWishExp(String userId, int amount);
    
    /**
     * 사용자의 오늘 특정 타입 경험치 조회
     */
    int getTodayExpByType(String userId, String expType);
    
    /**
     * 사용자의 오늘 총 경험치 조회
     */
    int getTodayTotalExp(String userId);
    
    /**
     * 사용자의 오늘 경험치 로그 조회
     */
    DailyExpLog getTodayExpLog(String userId);
    
    /**
     * 레벨업 체크 및 처리
     */
    boolean checkAndProcessLevelUp(String userId);
    
    /**
     * 사용자의 현재 레벨 정보 조회
     */
    LevelService.LevelInfo getUserLevelInfo(String userId);
    
    /**
     * 사용자의 최근 경험치 로그들 조회
     */
    List<DailyExpLog> getRecentExpLogs(String userId, int limit);
    
    /**
     * 사용자의 최근 레벨 로그들 조회
     */
    List<LevelLog> getRecentLevelLogs(String userId, int limit);
    
    /**
     * 오늘 특정 타입 경험치 추가 가능 여부 확인
     */
    boolean canAddExpToday(String userId, String expType, int amount);
    
    /**
     * 오늘 총 경험치 추가 가능 여부 확인
     */
    boolean canAddTotalExpToday(String userId, int amount);
}