package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 레벨 변경 로그 엔티티
 */
public class LevelLog {
    
    private int logId;
    private String userId;
    private int oldLevel;
    private int newLevel;
    private int gainedExp;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public LevelLog() {}
    
    // 생성자
    public LevelLog(String userId, int oldLevel, int newLevel, int gainedExp) {
        this.userId = userId;
        this.oldLevel = oldLevel;
        this.newLevel = newLevel;
        this.gainedExp = gainedExp;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public int getLogId() {
        return logId;
    }
    
    public void setLogId(int logId) {
        this.logId = logId;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public int getOldLevel() {
        return oldLevel;
    }
    
    public void setOldLevel(int oldLevel) {
        this.oldLevel = oldLevel;
    }
    
    public int getNewLevel() {
        return newLevel;
    }
    
    public void setNewLevel(int newLevel) {
        this.newLevel = newLevel;
    }
    
    public int getGainedExp() {
        return gainedExp;
    }
    
    public void setGainedExp(int gainedExp) {
        this.gainedExp = gainedExp;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    @Override
    public String toString() {
        return "LevelLog{" +
                "logId=" + logId +
                ", userId='" + userId + '\'' +
                ", oldLevel=" + oldLevel +
                ", newLevel=" + newLevel +
                ", gainedExp=" + gainedExp +
                ", createdAt=" + createdAt +
                '}';
    }
}
