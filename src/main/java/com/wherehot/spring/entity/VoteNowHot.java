package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 현재 핫플레이스 투표 엔티티 (Model1 DB 구조에 맞게)
 * vote_nowhot 테이블: id, place_id, voter_id, congestion, gender_ratio, wait_time, voted_at
 */
public class VoteNowHot {
    
    private int id;                    // 투표 ID
    private int placeId;              // 장소 ID (hotplace_info.id)
    private String voterId;           // 투표자 ID (로그인시 아이디, 비로그인시 IP)
    private String congestion;        // 혼잡도 (매우혼잡, 혼잡, 보통, 여유로움)
    private String genderRatio;       // 성비 (남성많음, 여성많음, 비슷함)
    private String waitTime;          // 대기시간 (30분이상, 10-30분, 10분미만, 대기없음)
    private LocalDateTime votedAt;    // 투표 시간
    
    // 기본 생성자
    public VoteNowHot() {}
    
    // 생성자 (Model1 방식)
    public VoteNowHot(int placeId, String voterId, String congestion, String genderRatio, String waitTime) {
        this.placeId = placeId;
        this.voterId = voterId;
        this.congestion = congestion;
        this.genderRatio = genderRatio;
        this.waitTime = waitTime;
        this.votedAt = LocalDateTime.now();
    }
    
    // Getters and Setters (Model1 DB 구조)
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getPlaceId() {
        return placeId;
    }
    
    public void setPlaceId(int placeId) {
        this.placeId = placeId;
    }
    
    public String getVoterId() {
        return voterId;
    }
    
    public void setVoterId(String voterId) {
        this.voterId = voterId;
    }
    
    public String getCongestion() {
        return congestion;
    }
    
    public void setCongestion(String congestion) {
        this.congestion = congestion;
    }
    
    public String getGenderRatio() {
        return genderRatio;
    }
    
    public void setGenderRatio(String genderRatio) {
        this.genderRatio = genderRatio;
    }
    
    public String getWaitTime() {
        return waitTime;
    }
    
    public void setWaitTime(String waitTime) {
        this.waitTime = waitTime;
    }
    
    public LocalDateTime getVotedAt() {
        return votedAt;
    }
    
    public void setVotedAt(LocalDateTime votedAt) {
        this.votedAt = votedAt;
    }
    
    // 하위 호환성을 위한 메서드들 (기존 코드에서 사용)
    public int getHotplaceId() {
        return placeId;
    }
    
    public void setHotplaceId(int hotplaceId) {
        this.placeId = hotplaceId;
    }
    
    public String getUserId() {
        return voterId;
    }
    
    public void setUserId(String userId) {
        this.voterId = userId;
    }
    
    /**
     * 투표 데이터가 유효한지 확인
     */
    public boolean isValidVote() {
        return placeId > 0 && voterId != null && !voterId.trim().isEmpty() 
            && congestion != null && genderRatio != null && waitTime != null;
    }
    
    /**
     * 오늘 투표한 것인지 확인
     */
    public boolean isToday() {
        return votedAt != null && votedAt.toLocalDate().equals(LocalDateTime.now().toLocalDate());
    }
    
    @Override
    public String toString() {
        return "VoteNowHot{" +
                "id=" + id +
                ", placeId=" + placeId +
                ", voterId='" + voterId + '\'' +
                ", congestion='" + congestion + '\'' +
                ", genderRatio='" + genderRatio + '\'' +
                ", waitTime='" + waitTime + '\'' +
                ", votedAt=" + votedAt +
                '}';
    }
}
