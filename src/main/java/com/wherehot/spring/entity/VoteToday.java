package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 오늘의 핫플레이스 투표 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class VoteToday {
    
    private int id;
    private int placeId;
    private String voterId;
    private LocalDateTime votedAt;
    
    // 기본 생성자
    public VoteToday() {}
    
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

    public LocalDateTime getVotedAt() {
        return votedAt;
    }

    public void setVotedAt(LocalDateTime votedAt) {
        this.votedAt = votedAt;
    }
}
