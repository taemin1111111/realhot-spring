package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 미팅/데이트 찜하기 엔티티
 */
public class MeetingDateWish {
    
    private int id;
    private int meetingDateId;
    private String userId;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public MeetingDateWish() {}
    
    // 생성자
    public MeetingDateWish(String userId, int meetingDateId) {
        this.userId = userId;
        this.meetingDateId = meetingDateId;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getMeetingDateId() {
        return meetingDateId;
    }
    
    public void setMeetingDateId(int meetingDateId) {
        this.meetingDateId = meetingDateId;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    @Override
    public String toString() {
        return "MeetingDateWish{" +
                "id=" + id +
                ", meetingDateId=" + meetingDateId +
                ", userId='" + userId + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
