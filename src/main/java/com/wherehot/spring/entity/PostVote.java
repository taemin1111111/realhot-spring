package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 게시글 투표 엔티티
 */
public class PostVote {
    
    private int id;
    private int postId;
    private String userId;
    private String voteType; // like, dislike
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public PostVote() {}
    
    // 생성자
    public PostVote(int postId, String userId, String voteType) {
        this.postId = postId;
        this.userId = userId;
        this.voteType = voteType;
        this.createdAt = LocalDateTime.now();
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
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getVoteType() {
        return voteType;
    }
    
    public void setVoteType(String voteType) {
        this.voteType = voteType;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    /**
     * 좋아요인지 확인
     */
    public boolean isLike() {
        return "like".equals(voteType);
    }
    
    /**
     * 싫어요인지 확인
     */
    public boolean isDislike() {
        return "dislike".equals(voteType);
    }
    
    @Override
    public String toString() {
        return "PostVote{" +
                "id=" + id +
                ", postId=" + postId +
                ", userId='" + userId + '\'' +
                ", voteType='" + voteType + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
