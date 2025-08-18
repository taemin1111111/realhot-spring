package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 콘텐츠 정보 엔티티
 */
public class ContentInfo {
    
    private int id;
    private String title;
    private String description;
    private String contentType; // hotplace, event, promotion 등
    private String status; // active, inactive, draft
    private String authorId;
    private String authorNickname;
    private int viewCount;
    private int likeCount;
    private String thumbnailUrl;
    private String contentUrl;
    private LocalDateTime publishedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isFeatured;
    private int sortOrder;
    
    // 기본 생성자
    public ContentInfo() {}
    
    // 생성자
    public ContentInfo(String title, String description, String contentType, String authorId) {
        this.title = title;
        this.description = description;
        this.contentType = contentType;
        this.authorId = authorId;
        this.status = "draft";
        this.viewCount = 0;
        this.likeCount = 0;
        this.isFeatured = false;
        this.sortOrder = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getContentType() {
        return contentType;
    }
    
    public void setContentType(String contentType) {
        this.contentType = contentType;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
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
    
    public int getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }
    
    public int getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }
    
    public String getThumbnailUrl() {
        return thumbnailUrl;
    }
    
    public void setThumbnailUrl(String thumbnailUrl) {
        this.thumbnailUrl = thumbnailUrl;
    }
    
    public String getContentUrl() {
        return contentUrl;
    }
    
    public void setContentUrl(String contentUrl) {
        this.contentUrl = contentUrl;
    }
    
    public LocalDateTime getPublishedAt() {
        return publishedAt;
    }
    
    public void setPublishedAt(LocalDateTime publishedAt) {
        this.publishedAt = publishedAt;
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
    
    public boolean isFeatured() {
        return isFeatured;
    }
    
    public void setFeatured(boolean featured) {
        isFeatured = featured;
    }
    
    public int getSortOrder() {
        return sortOrder;
    }
    
    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }
    
    /**
     * 조회수 증가
     */
    public void incrementViewCount() {
        this.viewCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 좋아요 수 증가
     */
    public void incrementLikeCount() {
        this.likeCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 발행 처리
     */
    public void publish() {
        this.status = "active";
        this.publishedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    @Override
    public String toString() {
        return "ContentInfo{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", contentType='" + contentType + '\'' +
                ", status='" + status + '\'' +
                ", authorId='" + authorId + '\'' +
                ", viewCount=" + viewCount +
                ", likeCount=" + likeCount +
                ", isFeatured=" + isFeatured +
                ", publishedAt=" + publishedAt +
                '}';
    }
}
