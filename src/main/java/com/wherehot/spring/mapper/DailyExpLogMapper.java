package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.DailyExpLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

/**
 * 일일 경험치 로그 MyBatis Mapper
 */
@Mapper
public interface DailyExpLogMapper {
    
    /**
     * 사용자의 특정 날짜 경험치 로그 조회
     */
    DailyExpLog selectByUserIdAndDate(@Param("userId") String userId, @Param("logDate") LocalDate logDate);
    
    /**
     * 사용자의 오늘 경험치 로그 조회
     */
    DailyExpLog selectTodayByUserId(@Param("userId") String userId);
    
    /**
     * 사용자의 최근 경험치 로그들 조회
     */
    List<DailyExpLog> selectRecentByUserId(@Param("userId") String userId, @Param("limit") int limit);
    
    /**
     * 경험치 로그 삽입
     */
    int insertDailyExpLog(DailyExpLog dailyExpLog);
    
    /**
     * 경험치 로그 업데이트
     */
    int updateDailyExpLog(DailyExpLog dailyExpLog);
    
    /**
     * 특정 타입의 경험치 추가
     */
    int addExpByType(@Param("userId") String userId, @Param("logDate") LocalDate logDate, 
                     @Param("expType") String expType, @Param("amount") int amount);
    
    /**
     * 사용자의 오늘 총 경험치 조회
     */
    int selectTodayTotalExp(@Param("userId") String userId);
    
    /**
     * 사용자의 특정 타입 오늘 경험치 조회
     */
    int selectTodayExpByType(@Param("userId") String userId, @Param("expType") String expType);
}
