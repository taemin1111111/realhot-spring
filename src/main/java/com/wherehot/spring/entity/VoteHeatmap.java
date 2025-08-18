package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 투표 히트맵 엔티티
 */
public class VoteHeatmap {
    
    private Integer id;
    private Double latitude;
    private Double longitude;
    private Integer voteCount;
    private Double averageScore;
    private String region;
    private String sigungu;
    private Integer hotplaceId;
    private LocalDateTime lastVoteDate;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 핫플레이스 정보 (조인용)
    private String hotplaceName;
    private String hotplaceAddress;
    private Integer hotplaceCategoryId;
    private String categoryName;
    
    // 기본 생성자
    public VoteHeatmap() {}
    
    // 필수 필드 생성자
    public VoteHeatmap(Double latitude, Double longitude, String region, String sigungu) {
        this.latitude = latitude;
        this.longitude = longitude;
        this.region = region;
        this.sigungu = sigungu;
        this.voteCount = 0;
        this.averageScore = 0.0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // 핫플레이스 연결 생성자
    public VoteHeatmap(Integer hotplaceId, Double latitude, Double longitude, String region, String sigungu) {
        this(latitude, longitude, region, sigungu);
        this.hotplaceId = hotplaceId;
    }
    
    // Getter/Setter
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    
    public Integer getVoteCount() { return voteCount; }
    public void setVoteCount(Integer voteCount) { this.voteCount = voteCount; }
    
    public Double getAverageScore() { return averageScore; }
    public void setAverageScore(Double averageScore) { this.averageScore = averageScore; }
    
    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }
    
    public String getSigungu() { return sigungu; }
    public void setSigungu(String sigungu) { this.sigungu = sigungu; }
    
    public Integer getHotplaceId() { return hotplaceId; }
    public void setHotplaceId(Integer hotplaceId) { this.hotplaceId = hotplaceId; }
    
    public LocalDateTime getLastVoteDate() { return lastVoteDate; }
    public void setLastVoteDate(LocalDateTime lastVoteDate) { this.lastVoteDate = lastVoteDate; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    // 조인 필드
    public String getHotplaceName() { return hotplaceName; }
    public void setHotplaceName(String hotplaceName) { this.hotplaceName = hotplaceName; }
    
    public String getHotplaceAddress() { return hotplaceAddress; }
    public void setHotplaceAddress(String hotplaceAddress) { this.hotplaceAddress = hotplaceAddress; }
    
    public Integer getHotplaceCategoryId() { return hotplaceCategoryId; }
    public void setHotplaceCategoryId(Integer hotplaceCategoryId) { this.hotplaceCategoryId = hotplaceCategoryId; }
    
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    
    /**
     * 투표 정보 업데이트
     */
    public void updateVoteInfo(Integer newVoteCount, Double newAverageScore) {
        this.voteCount = newVoteCount;
        this.averageScore = newAverageScore;
        this.lastVoteDate = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 투표 수 증가
     */
    public void incrementVoteCount() {
        this.voteCount = (this.voteCount != null ? this.voteCount : 0) + 1;
        this.lastVoteDate = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 히트맵 강도 계산 (투표 수와 평균 점수 기반)
     */
    public Double getHeatmapIntensity() {
        if (voteCount == null || voteCount == 0) return 0.0;
        if (averageScore == null) return voteCount.doubleValue();
        
        // 투표 수와 평균 점수를 조합한 강도 계산
        return voteCount * (averageScore / 5.0); // 5점 만점 기준으로 정규화
    }
    
    @Override
    public String toString() {
        return "VoteHeatmap{" +
                "id=" + id +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", voteCount=" + voteCount +
                ", averageScore=" + averageScore +
                ", region='" + region + '\'' +
                ", sigungu='" + sigungu + '\'' +
                ", hotplaceId=" + hotplaceId +
                ", lastVoteDate=" + lastVoteDate +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
