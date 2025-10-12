package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Level;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 레벨 MyBatis Mapper
 */
@Mapper
public interface LevelMapper {
    
    /**
     * 모든 레벨 조회
     */
    List<Level> selectAllLevels();
    
    /**
     * 레벨 ID로 레벨 조회
     */
    Level selectLevelById(@Param("levelId") int levelId);
    
    /**
     * 경험치로 해당하는 레벨 조회
     */
    Level selectLevelByExp(@Param("exp") int exp);
    
    /**
     * 다음 레벨 정보 조회
     */
    Level selectNextLevel(@Param("exp") int exp);
    
    /**
     * 레벨 삽입
     */
    int insertLevel(Level level);
    
    /**
     * 레벨 업데이트
     */
    int updateLevel(Level level);
    
    /**
     * 레벨 삭제
     */
    int deleteLevel(@Param("levelId") int levelId);
}
