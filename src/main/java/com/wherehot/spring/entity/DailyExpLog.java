package com.wherehot.spring.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 일일 경험치 로그 엔티티
 */
public class DailyExpLog {
    
    private int id;
    private String userId;
    private LocalDate logDate;
    private int voteExp;
    private int courseExp;
    private int hpostExp;
    private int commentExp;
    private int likeExp;
    private int wishExp;
    private int totalExp;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 기본 생성자
    public DailyExpLog() {}
    
    // 생성자
    public DailyExpLog(String userId, LocalDate logDate) {
        this.userId = userId;
        this.logDate = logDate;
        this.voteExp = 0;
        this.courseExp = 0;
        this.hpostExp = 0;
        this.commentExp = 0;
        this.likeExp = 0;
        this.wishExp = 0;
        this.totalExp = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public LocalDate getLogDate() {
        return logDate;
    }
    
    public void setLogDate(LocalDate logDate) {
        this.logDate = logDate;
    }
    
    public int getVoteExp() {
        return voteExp;
    }
    
    public void setVoteExp(int voteExp) {
        this.voteExp = voteExp;
    }
    
    public int getCourseExp() {
        return courseExp;
    }
    
    public void setCourseExp(int courseExp) {
        this.courseExp = courseExp;
    }
    
    public int getHpostExp() {
        return hpostExp;
    }
    
    public void setHpostExp(int hpostExp) {
        this.hpostExp = hpostExp;
    }
    
    public int getCommentExp() {
        return commentExp;
    }
    
    public void setCommentExp(int commentExp) {
        this.commentExp = commentExp;
    }
    
    public int getLikeExp() {
        return likeExp;
    }
    
    public void setLikeExp(int likeExp) {
        this.likeExp = likeExp;
    }
    
    public int getWishExp() {
        return wishExp;
    }
    
    public void setWishExp(int wishExp) {
        this.wishExp = wishExp;
    }
    
    public int getTotalExp() {
        return totalExp;
    }
    
    public void setTotalExp(int totalExp) {
        this.totalExp = totalExp;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    /**
     * 총 경험치 계산
     */
    public void calculateTotalExp() {
        this.totalExp = voteExp + courseExp + hpostExp + commentExp + likeExp + wishExp;
    }
    
    /**
     * 특정 타입의 경험치 추가
     */
    public void addExp(String expType, int amount) {
        switch (expType) {
            case "vote":
                this.voteExp += amount;
                break;
            case "course":
                this.courseExp += amount;
                break;
            case "hpost":
                this.hpostExp += amount;
                break;
            case "comment":
                this.commentExp += amount;
                break;
            case "like":
                this.likeExp += amount;
                break;
            case "wish":
                this.wishExp += amount;
                break;
        }
        calculateTotalExp();
        this.updatedAt = LocalDateTime.now();
    }
    
    @Override
    public String toString() {
        return "DailyExpLog{" +
                "id=" + id +
                ", userId='" + userId + '\'' +
                ", logDate=" + logDate +
                ", voteExp=" + voteExp +
                ", courseExp=" + courseExp +
                ", hpostExp=" + hpostExp +
                ", commentExp=" + commentExp +
                ", likeExp=" + likeExp +
                ", wishExp=" + wishExp +
                ", totalExp=" + totalExp +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
