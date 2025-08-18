package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 댓글 투표 엔티티
 */
public class CommentVote {
    
    private int id;
    private int commentId;
    private String userId;
    private String voteType; // like, dislike
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public CommentVote() {}
    
    // 생성자
    public CommentVote(int commentId, String userId, String voteType) {
        this.commentId = commentId;
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
    
    public int getCommentId() {
        return commentId;
    }
    
    public void setCommentId(int commentId) {
        this.commentId = commentId;
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
        return "CommentVote{" +
                "id=" + id +
                ", commentId=" + commentId +
                ", userId='" + userId + '\'' +
                ", voteType='" + voteType + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
