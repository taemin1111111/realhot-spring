package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.LevelLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 레벨 변경 로그 MyBatis Mapper
 */
@Mapper
public interface LevelLogMapper {
    
    /**
     * 레벨 로그 삽입
     */
    int insertLevelLog(LevelLog levelLog);
    
    /**
     * 사용자의 레벨 로그 조회
     */
    List<LevelLog> selectByUserId(@Param("userId") String userId);
    
    /**
     * 사용자의 최근 레벨 로그 조회
     */
    List<LevelLog> selectRecentByUserId(@Param("userId") String userId, @Param("limit") int limit);
    
    /**
     * 특정 레벨 변경 로그 조회
     */
    LevelLog selectByLogId(@Param("logId") int logId);
    
    /**
     * 사용자의 레벨 변경 횟수 조회
     */
    int countLevelChangesByUserId(@Param("userId") String userId);
}
