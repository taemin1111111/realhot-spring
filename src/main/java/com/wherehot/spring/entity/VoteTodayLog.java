package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 투표 로그 엔티티 - VoteNowHot과 동일한 구조 (vote_nowhot_log 테이블)
 */
public class VoteTodayLog {
    
    private int id;
    private int placeId;
    private String voterId;
    private int congestion;
    private int genderRatio;
    private int waitTime;
    private LocalDateTime votedAt;
    
    // 기본 생성자
    public VoteTodayLog() {}
    
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
    public int getCongestion() {
        return congestion;
    }
    public void setCongestion(int congestion) {
        this.congestion = congestion;
    }
    public int getGenderRatio() {
        return genderRatio;
    }
    public void setGenderRatio(int genderRatio) {
        this.genderRatio = genderRatio;
    }
    public int getWaitTime() {
        return waitTime;
    }
    public void setWaitTime(int waitTime) {
        this.waitTime = waitTime;
    }
    public LocalDateTime getVotedAt() {
        return votedAt;
    }
    public void setVotedAt(LocalDateTime votedAt) {
        this.votedAt = votedAt;
    }
}
