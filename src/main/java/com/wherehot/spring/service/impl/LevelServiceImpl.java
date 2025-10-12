package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Level;
import com.wherehot.spring.mapper.LevelMapper;
import com.wherehot.spring.service.LevelService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 레벨 서비스 구현체
 */
@Service
@Transactional
public class LevelServiceImpl implements LevelService {
    
    private static final Logger logger = LoggerFactory.getLogger(LevelServiceImpl.class);
    
    @Autowired
    private LevelMapper levelMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Level> getAllLevels() {
        try {
            return levelMapper.selectAllLevels();
        } catch (Exception e) {
            logger.error("Error getting all levels", e);
            throw new RuntimeException("레벨 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Level getLevelById(int levelId) {
        try {
            return levelMapper.selectLevelById(levelId);
        } catch (Exception e) {
            logger.error("Error getting level by id: {}", levelId, e);
            throw new RuntimeException("레벨 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Level getLevelByExp(int exp) {
        try {
            return levelMapper.selectLevelByExp(exp);
        } catch (Exception e) {
            logger.error("Error getting level by exp: {}", exp, e);
            throw new RuntimeException("경험치에 따른 레벨 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Level getNextLevel(int exp) {
        try {
            return levelMapper.selectNextLevel(exp);
        } catch (Exception e) {
            logger.error("Error getting next level for exp: {}", exp, e);
            throw new RuntimeException("다음 레벨 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public int insertLevel(Level level) {
        try {
            return levelMapper.insertLevel(level);
        } catch (Exception e) {
            logger.error("Error inserting level: {}", level, e);
            throw new RuntimeException("레벨 등록 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public int updateLevel(Level level) {
        try {
            return levelMapper.updateLevel(level);
        } catch (Exception e) {
            logger.error("Error updating level: {}", level, e);
            throw new RuntimeException("레벨 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public int deleteLevel(int levelId) {
        try {
            return levelMapper.deleteLevel(levelId);
        } catch (Exception e) {
            logger.error("Error deleting level: {}", levelId, e);
            throw new RuntimeException("레벨 삭제 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public LevelInfo getUserLevelInfo(int currentExp) {
        try {
            Level currentLevel = getLevelByExp(currentExp);
            Level nextLevel = getNextLevel(currentExp);
            return new LevelInfo(currentLevel, nextLevel, currentExp);
        } catch (Exception e) {
            logger.error("Error getting user level info for exp: {}", currentExp, e);
            throw new RuntimeException("사용자 레벨 정보 조회 중 오류가 발생했습니다.", e);
        }
    }
}
