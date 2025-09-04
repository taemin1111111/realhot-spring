package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 콘텐츠 이미지 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class ContentImage {
    
    private int id;
    private int contentId;
    private String imagePath;
    private int imageOrder;
    private String caption;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public ContentImage() {}
    
    // 전체 매개변수 생성자
    public ContentImage(int id, int contentId, String imagePath, int imageOrder, String caption, LocalDateTime createdAt) {
        this.id = id;
        this.contentId = contentId;
        this.imagePath = imagePath;
        this.imageOrder = imageOrder;
        this.caption = caption;
        this.createdAt = createdAt;
    }
    
    // Getter와 Setter
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getContentId() {
        return contentId;
    }
    
    public void setContentId(int contentId) {
        this.contentId = contentId;
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
    
    public String getCaption() {
        return caption;
    }
    
    public void setCaption(String caption) {
        this.caption = caption;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
