package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 현재 핫플레이스 투표 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class VoteNowHot {
    
    private int id;
    private int placeId;
    private String voterId;
    private String congestion;
    private String genderRatio;
    private String waitTime;
    private LocalDateTime votedAt;
    
    // 보안 강화를 위한 추가 컬럼들
    private String userAgentHash;
    private boolean isVpnProxy;
    private int riskScore;
    
    // 기본 생성자
    public VoteNowHot() {}
    
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
    
    // 보안 강화 컬럼들의 getter/setter
    public String getUserAgentHash() {
        return userAgentHash;
    }
    
    public void setUserAgentHash(String userAgentHash) {
        this.userAgentHash = userAgentHash;
    }
    
    public boolean isVpnProxy() {
        return isVpnProxy;
    }
    
    public void setVpnProxy(boolean isVpnProxy) {
        this.isVpnProxy = isVpnProxy;
    }
    
    public int getRiskScore() {
        return riskScore;
    }
    
    public void setRiskScore(int riskScore) {
        this.riskScore = riskScore;
    }
}
