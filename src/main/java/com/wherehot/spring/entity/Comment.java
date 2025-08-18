package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 댓글 엔티티
 */
public class Comment {
    
    private int id;
    private int postId;
    private String authorId;
    private String authorNickname;
    private String content;
    private int parentCommentId; // 대댓글용
    private int likeCount;
    private int dislikeCount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isDeleted;
    
    // 기본 생성자
    public Comment() {}
    
    // 생성자
    public Comment(int postId, String authorId, String content) {
        this.postId = postId;
        this.authorId = authorId;
        this.content = content;
        this.parentCommentId = 0;
        this.likeCount = 0;
        this.dislikeCount = 0;
        this.status = "정상";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.isDeleted = false;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getPostId() {
        return postId;
    }
    
    public void setPostId(int postId) {
        this.postId = postId;
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
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public int getParentCommentId() {
        return parentCommentId;
    }
    
    public void setParentCommentId(int parentCommentId) {
        this.parentCommentId = parentCommentId;
    }
    
    public int getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }
    
    public int getDislikeCount() {
        return dislikeCount;
    }
    
    public void setDislikeCount(int dislikeCount) {
        this.dislikeCount = dislikeCount;
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
    
    public boolean isDeleted() {
        return isDeleted;
    }
    
    public void setDeleted(boolean deleted) {
        isDeleted = deleted;
    }
    
    /**
     * 대댓글인지 확인
     */
    public boolean isReply() {
        return parentCommentId > 0;
    }
    
    /**
     * 좋아요 증가
     */
    public void incrementLikeCount() {
        this.likeCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 싫어요 증가
     */
    public void incrementDislikeCount() {
        this.dislikeCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    @Override
    public String toString() {
        return "Comment{" +
                "id=" + id +
                ", postId=" + postId +
                ", authorId='" + authorId + '\'' +
                ", authorNickname='" + authorNickname + '\'' +
                ", parentCommentId=" + parentCommentId +
                ", likeCount=" + likeCount +
                ", dislikeCount=" + dislikeCount +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", isDeleted=" + isDeleted +
                '}';
    }
}
