package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 리뷰 엔티티
 */
public class Review {
    
    private int id;
    private int hotplaceId;
    private String authorId;
    private String authorNickname;
    private String title;
    private String content;
    private int rating;
    private String region;
    private String sigungu;
    private int categoryId;
    private int likeCount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String imageUrl;
    private boolean isRecommended;
    
    // 기본 생성자
    public Review() {}
    
    // 생성자
    public Review(int hotplaceId, String authorId, String title, String content, int rating) {
        this.hotplaceId = hotplaceId;
        this.authorId = authorId;
        this.title = title;
        this.content = content;
        this.rating = rating;
        this.likeCount = 0;
        this.status = "정상";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.isRecommended = false;
    }
    
    // Getters and Setters
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
    
    public String getAuthorId() {
        return authorId;
    }
    
    public void setAuthorId(String authorId) {
        this.authorId = authorId;
    }
    
    public String getAuthorNickname() {
        return authorNickname;
    }
    
    public void setAuthorNickname(String authorNickname) {
        this.authorNickname = authorNickname;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public int getRating() {
        return rating;
    }
    
    public void setRating(int rating) {
        this.rating = rating;
    }
    
    public String getRegion() {
        return region;
    }
    
    public void setRegion(String region) {
        this.region = region;
    }
    
    public String getSigungu() {
        return sigungu;
    }
    
    public void setSigungu(String sigungu) {
        this.sigungu = sigungu;
    }
    
    public int getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }
    
    public int getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
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
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    public boolean isRecommended() {
        return isRecommended;
    }
    
    public void setRecommended(boolean recommended) {
        isRecommended = recommended;
    }
    
    /**
     * 추천 수 증가
     */
    public void incrementLikeCount() {
        this.likeCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 별점이 유효한지 확인
     */
    public boolean isValidRating() {
        return rating >= 1 && rating <= 5;
    }
    
    @Override
    public String toString() {
        return "Review{" +
                "id=" + id +
                ", hotplaceId=" + hotplaceId +
                ", authorId='" + authorId + '\'' +
                ", authorNickname='" + authorNickname + '\'' +
                ", title='" + title + '\'' +
                ", rating=" + rating +
                ", region='" + region + '\'' +
                ", sigungu='" + sigungu + '\'' +
                ", likeCount=" + likeCount +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", isRecommended=" + isRecommended +
                '}';
    }
}
