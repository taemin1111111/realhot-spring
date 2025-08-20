package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 콘텐츠 이미지 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class ContentImage {
    
    private int id;
    private int hotplaceId;
    private String imagePath;
    private int imageOrder;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public ContentImage() {}
    
    // 전체 매개변수 생성자
    public ContentImage(int id, int hotplaceId, String imagePath, int imageOrder, LocalDateTime createdAt) {
        this.id = id;
        this.hotplaceId = hotplaceId;
        this.imagePath = imagePath;
        this.imageOrder = imageOrder;
        this.createdAt = createdAt;
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
    
    public String getImagePath() {
        return imagePath;
    }
    
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
    
    public int getImageOrder() {
        return imageOrder;
    }
    
    public void setImageOrder(int imageOrder) {
        this.imageOrder = imageOrder;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
