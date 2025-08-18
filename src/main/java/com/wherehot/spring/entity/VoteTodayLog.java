package com.wherehot.spring.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 오늘의 핫플레이스 투표 로그 엔티티
 */
public class VoteTodayLog {
    
    private int id;
    private int hotplaceId;
    private String hotplaceName;
    private LocalDate logDate;
    private int totalVotes;
    private int uniqueVoters;
    private String region;
    private String sigungu;
    private int categoryId;
    private int ranking;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public VoteTodayLog() {}
    
    // 생성자
    public VoteTodayLog(int hotplaceId, String hotplaceName, LocalDate logDate, int totalVotes, int uniqueVoters) {
        this.hotplaceId = hotplaceId;
        this.hotplaceName = hotplaceName;
        this.logDate = logDate;
        this.totalVotes = totalVotes;
        this.uniqueVoters = uniqueVoters;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getHotplaceId() {
        return hotplaceId;
    }
    
    public void setHotplaceId(int hotplaceId) {
        this.hotplaceId = hotplaceId;
    }
    
    public String getHotplaceName() {
        return hotplaceName;
    }
    
    public void setHotplaceName(String hotplaceName) {
        this.hotplaceName = hotplaceName;
    }
    
    public LocalDate getLogDate() {
        return logDate;
    }
    
    public void setLogDate(LocalDate logDate) {
        this.logDate = logDate;
    }
    
    public int getTotalVotes() {
        return totalVotes;
    }
    
    public void setTotalVotes(int totalVotes) {
        this.totalVotes = totalVotes;
    }
    
    public int getUniqueVoters() {
        return uniqueVoters;
    }
    
    public void setUniqueVoters(int uniqueVoters) {
        this.uniqueVoters = uniqueVoters;
    }
    
    public String getRegion() {
        return region;
    }
    
    public void setRegion(String region) {
        this.region = region;
    }
    
    public String getSigungu() {
        return sigungu;
    }
    
    public void setSigungu(String sigungu) {
        this.sigungu = sigungu;
    }
    
    public int getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }
    
    public int getRanking() {
        return ranking;
    }
    
    public void setRanking(int ranking) {
        this.ranking = ranking;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return createdAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.createdAt = updatedAt;
    }
    
    public int getVoteCount() {
        return totalVotes;
    }
    
    public void setVoteCount(int voteCount) {
        this.totalVotes = voteCount;
    }
    
    /**
     * 투표율 계산 (총 투표수 대비 고유 투표자 비율)
     */
    public double getVoteRate() {
        if (totalVotes == 0) return 0.0;
        return (double) uniqueVoters / totalVotes * 100;
    }
    
    /**
     * 오늘의 로그인지 확인
     */
    public boolean isToday() {
        return logDate.equals(LocalDate.now());
    }
    
    @Override
    public String toString() {
        return "VoteTodayLog{" +
                "id=" + id +
                ", hotplaceId=" + hotplaceId +
                ", hotplaceName='" + hotplaceName + '\'' +
                ", logDate=" + logDate +
                ", totalVotes=" + totalVotes +
                ", uniqueVoters=" + uniqueVoters +
                ", ranking=" + ranking +
                ", region='" + region + '\'' +
                '}';
    }
}
