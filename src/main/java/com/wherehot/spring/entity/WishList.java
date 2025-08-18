package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 위시리스트 엔티티
 */
public class WishList {
    
    private int id;
    private String userId;
    private int hotplaceId;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public WishList() {}
    
    // 생성자
    public WishList(String userId, int hotplaceId) {
        this.userId = userId;
        this.hotplaceId = hotplaceId;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public int getHotplaceId() { return hotplaceId; }
    public void setHotplaceId(int hotplaceId) { this.hotplaceId = hotplaceId; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    // Model1 호환성을 위한 메서드들
    public String getUserid() { return userId; }
    public void setUserid(String userid) { this.userId = userid; }
    
    public int getPlace_id() { return hotplaceId; }
    public void setPlace_id(int placeId) { this.hotplaceId = placeId; }
}
