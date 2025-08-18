package com.wherehot.spring.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 오늘의 핫플레이스 투표 엔티티
 */
public class VoteToday {
    
    private int id;
    private int hotplaceId;
    private String userId;
    private String userNickname;
    private LocalDate voteDate;
    private LocalDateTime votedAt;
    private String region;
    private String sigungu;
    private int categoryId;
    private String ipAddress;
    private boolean isValid;
    
    // 기본 생성자
    public VoteToday() {}
    
    // 생성자
    public VoteToday(int hotplaceId, String userId) {
        this.hotplaceId = hotplaceId;
        this.userId = userId;
        this.voteDate = LocalDate.now();
        this.votedAt = LocalDateTime.now();
        this.isValid = true;
    }
    
    // 생성자 (userId, hotplaceId, voteDate)
    public VoteToday(String userId, int hotplaceId, LocalDate voteDate) {
        this.userId = userId;
        this.hotplaceId = hotplaceId;
        this.voteDate = voteDate;
        this.votedAt = LocalDateTime.now();
        this.isValid = true;
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
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getUserNickname() {
        return userNickname;
    }
    
    public void setUserNickname(String userNickname) {
        this.userNickname = userNickname;
    }
    
    public LocalDate getVoteDate() {
        return voteDate;
    }
    
    public void setVoteDate(LocalDate voteDate) {
        this.voteDate = voteDate;
    }
    
    public LocalDateTime getVotedAt() {
        return votedAt;
    }
    
    public void setVotedAt(LocalDateTime votedAt) {
        this.votedAt = votedAt;
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
    
    public String getIpAddress() {
        return ipAddress;
    }
    
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
    
    public boolean isValid() {
        return isValid;
    }
    
    public void setValid(boolean valid) {
        isValid = valid;
    }
    
    public LocalDateTime getCreatedAt() {
        return votedAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.votedAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return votedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.votedAt = updatedAt;
    }
    
    /**
     * 오늘 투표한 것인지 확인
     */
    public boolean isToday() {
        return voteDate.equals(LocalDate.now());
    }
    
    @Override
    public String toString() {
        return "VoteToday{" +
                "id=" + id +
                ", hotplaceId=" + hotplaceId +
                ", userId='" + userId + '\'' +
                ", voteDate=" + voteDate +
                ", region='" + region + '\'' +
                ", sigungu='" + sigungu + '\'' +
                ", isValid=" + isValid +
                '}';
    }
}
