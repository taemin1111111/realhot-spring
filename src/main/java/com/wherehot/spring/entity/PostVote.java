package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 게시글 투표 엔티티 (HottalkVoteDto와 동일)
 */
public class PostVote {
    private Integer id;                 // 투표 번호 (PK)
    private Integer postId;            // 게시글 ID
    private String userKey;          // 사용자 ID
    private String voteType;       // 투표 타입 ("like" 또는 "dislike")
    private LocalDateTime createdAt;   // 투표 시간
    
    // 기본 생성자
    public PostVote() {}
    
    // 매개변수 생성자
    public PostVote(Integer postId, String userKey, String voteType) {
        this.postId = postId;
        this.userKey = userKey;
        this.voteType = voteType;
    }
    
    // Getter & Setter
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public Integer getPostId() {
        return postId;
    }
    
    public void setPostId(Integer postId) {
        this.postId = postId;
    }
    
    public String getUserKey() {
        return userKey;
    }
    
    public void setUserKey(String userKey) {
        this.userKey = userKey;
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
}