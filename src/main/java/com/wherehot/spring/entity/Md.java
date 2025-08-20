package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * MD 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class Md {
    private int mdId;
    private int placeId;  // hotplace_info.id를 참조
    private String mdName;
    private String contact;
    private String description;
    private String photo;
    private LocalDateTime createdAt;
    private boolean isVisible;
    
    // 기본 생성자
    public Md() {}
    
    // 전체 생성자
    public Md(int mdId, int placeId, String mdName, String contact, 
                 String description, String photo, LocalDateTime createdAt, boolean isVisible) {
        this.mdId = mdId;
        this.placeId = placeId;
        this.mdName = mdName;
        this.contact = contact;
        this.description = description;
        this.photo = photo;
        this.createdAt = createdAt;
        this.isVisible = isVisible;
    }
    
    // Getter와 Setter 메서드들
    public int getMdId() {
        return mdId;
    }
    
    public void setMdId(int mdId) {
        this.mdId = mdId;
    }
    
    public int getPlaceId() {
        return placeId;
    }
    
    public void setPlaceId(int placeId) {
        this.placeId = placeId;
    }
    
    public String getMdName() {
        return mdName;
    }
    
    public void setMdName(String mdName) {
        this.mdName = mdName;
    }
    
    public String getContact() {
        return contact;
    }
    
    public void setContact(String contact) {
        this.contact = contact;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getPhoto() {
        return photo;
    }
    
    public void setPhoto(String photo) {
        this.photo = photo;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public boolean isVisible() {
        return isVisible;
    }
    
    public void setVisible(boolean isVisible) {
        this.isVisible = isVisible;
    }
    
    @Override
    public String toString() {
        return "Md{" +
                "mdId=" + mdId +
                ", placeId=" + placeId +
                ", mdName='" + mdName + '\'' +
                ", contact='" + contact + '\'' +
                ", description='" + description + '\'' +
                ", photo='" + photo + '\'' +
                ", createdAt=" + createdAt +
                ", isVisible=" + isVisible +
                '}';
    }
}
