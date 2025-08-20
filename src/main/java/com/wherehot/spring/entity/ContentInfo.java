package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 콘텐츠 정보 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class ContentInfo {
    
    private int id;
    private int hotplaceId;
    private String contentText;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 기본 생성자
    public ContentInfo() {}
    
    // 전체 매개변수 생성자
    public ContentInfo(int id, int hotplaceId, String contentText, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.hotplaceId = hotplaceId;
        this.contentText = contentText;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
    
    // Getter와 Setter
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
    
    public String getContentText() {
        return contentText;
    }
    
    public void setContentText(String contentText) {
        this.contentText = contentText;
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
}
