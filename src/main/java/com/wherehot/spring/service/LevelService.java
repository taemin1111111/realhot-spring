package com.wherehot.spring.service;

import com.wherehot.spring.entity.Level;

import java.util.List;

/**
 * 레벨 서비스 인터페이스
 */
public interface LevelService {
    
    /**
     * 모든 레벨 조회
     */
    List<Level> getAllLevels();
    
    /**
     * 레벨 ID로 레벨 조회
     */
    Level getLevelById(int levelId);
    
    /**
     * 경험치로 해당하는 레벨 조회
     */
    Level getLevelByExp(int exp);
    
    /**
     * 다음 레벨 정보 조회
     */
    Level getNextLevel(int exp);
    
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
    int deleteLevel(int levelId);
    
    /**
     * 사용자의 현재 레벨과 다음 레벨 정보 조회
     */
    LevelInfo getUserLevelInfo(int currentExp);
    
    /**
     * 레벨 정보 DTO
     */
    class LevelInfo {
        private Level currentLevel;
        private Level nextLevel;
        private int expToNext;
        private double progressPercentage;
        
        public LevelInfo(Level currentLevel, Level nextLevel, int currentExp) {
            this.currentLevel = currentLevel;
            this.nextLevel = nextLevel;
            if (nextLevel != null) {
                this.expToNext = nextLevel.getExpRequired() - currentExp;
                int totalExpNeeded = nextLevel.getExpRequired() - currentLevel.getExpRequired();
                this.progressPercentage = totalExpNeeded > 0 ? 
                    (double)(currentExp - currentLevel.getExpRequired()) / totalExpNeeded * 100 : 100.0;
            } else {
                this.expToNext = 0;
                this.progressPercentage = 100.0;
            }
        }
        
        // Getters
        public Level getCurrentLevel() { return currentLevel; }
        public Level getNextLevel() { return nextLevel; }
        public int getExpToNext() { return expToNext; }
        public double getProgressPercentage() { return progressPercentage; }
    }
}
