package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 알림 엔티티
 * notification 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class Notification {
    
    private Long notificationId;           // 알림 PK (BIGINT AUTO_INCREMENT)
    private String userid;                 // 사용자 ID (VARCHAR(50), FK)
    private String message;                // 알림 메시지 (VARCHAR(255))
    private String type;                   // 알림 유형 (VARCHAR(30), default 'INFO')
    private Boolean isRead;                // 읽음 여부 (TINYINT(1), 0=안읽음, 1=읽음)
    private LocalDateTime createdAt;       // 생성일시 (TIMESTAMP)
    private LocalDateTime readAt;          // 읽은 시간 (TIMESTAMP, NULL 가능)
    
    // 생성자
    public Notification() {
        this.type = "INFO";
        this.isRead = false;
        this.createdAt = LocalDateTime.now();
    }
    
    public Notification(String userid, String message) {
        this();
        this.userid = userid;
        this.message = message;
    }
    
    public Notification(String userid, String message, String type) {
        this(userid, message);
        this.type = type;
    }
    
    // Getter & Setter
    public Long getNotificationId() {
        return notificationId;
    }
    
    public void setNotificationId(Long notificationId) {
        this.notificationId = notificationId;
    }
    
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public Boolean getIsRead() {
        return isRead;
    }
    
    public void setIsRead(Boolean isRead) {
        this.isRead = isRead;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getReadAt() {
        return readAt;
    }
    
    public void setReadAt(LocalDateTime readAt) {
        this.readAt = readAt;
    }
    
    // 편의 메서드
    public boolean isRead() {
        return isRead != null && isRead;
    }
    
    public void markAsRead() {
        this.isRead = true;
        this.readAt = LocalDateTime.now();
    }
    
    public void markAsUnread() {
        this.isRead = false;
        this.readAt = null;
    }
    
    @Override
    public String toString() {
        return "Notification{" +
                "notificationId=" + notificationId +
                ", userid='" + userid + '\'' +
                ", message='" + message + '\'' +
                ", type='" + type + '\'' +
                ", isRead=" + isRead +
                ", createdAt=" + createdAt +
                ", readAt=" + readAt +
                '}';
    }
}
