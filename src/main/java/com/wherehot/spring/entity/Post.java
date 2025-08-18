package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 게시글 엔티티 (Hpost)
 */
public class Post {
    
    private int id;
    private String title;
    private String content;
    private String authorId;
    private String authorNickname;
    private int categoryId;
    private int viewCount;
    private int likeCount;
    private int commentCount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String imageUrl;
    private boolean isNotice;
    private boolean isPinned;
    
    // 기본 생성자
    public Post() {}
    
    // 생성자
    public Post(String title, String content, String authorId, int categoryId) {
        this.title = title;
        this.content = content;
        this.authorId = authorId;
        this.categoryId = categoryId;
        this.viewCount = 0;
        this.likeCount = 0;
        this.commentCount = 0;
        this.status = "정상";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.isNotice = false;
        this.isPinned = false;
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
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
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
    
    public int getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
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
    
    public int getCommentCount() {
        return commentCount;
    }
    
    public void setCommentCount(int commentCount) {
        this.commentCount = commentCount;
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
    
    public boolean isNotice() {
        return isNotice;
    }
    
    public void setNotice(boolean notice) {
        isNotice = notice;
    }
    
    public boolean isPinned() {
        return isPinned;
    }
    
    public void setPinned(boolean pinned) {
        isPinned = pinned;
    }
    
    // Model1 호환성을 위한 메서드들
    public String getUserid() { return authorId; }
    public void setUserid(String userid) { this.authorId = userid; }
    
    public String getNickname() { return authorNickname; }
    public void setNickname(String nickname) { this.authorNickname = nickname; }
    
    public int getViews() { return viewCount; }
    public void setViews(int views) { this.viewCount = views; }
    
    public int getLikes() { return likeCount; }
    public void setLikes(int likes) { this.likeCount = likes; }
    
    public int getCategory_id() { return categoryId; }
    public void setCategory_id(int categoryId) { this.categoryId = categoryId; }
    
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
     * 댓글 수 증가
     */
    public void incrementCommentCount() {
        this.commentCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    @Override
    public String toString() {
        return "Post{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", authorId='" + authorId + '\'' +
                ", authorNickname='" + authorNickname + '\'' +
                ", categoryId=" + categoryId +
                ", viewCount=" + viewCount +
                ", likeCount=" + likeCount +
                ", commentCount=" + commentCount +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", isNotice=" + isNotice +
                ", isPinned=" + isPinned +
                '}';
    }
}
