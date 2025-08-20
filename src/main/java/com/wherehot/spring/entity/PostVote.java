package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 게시글 투표 엔티티 (HottalkVoteDto와 동일)
 */
public class PostVote {
    private int id;                 // 투표 번호 (PK)
    private int post_id;            // 게시글 ID
    private String userid;          // 사용자 ID
    private String vote_type;       // 투표 타입 ("like" 또는 "dislike")
    private LocalDateTime createdAt;   // 투표 시간
    
    // 기본 생성자
    public PostVote() {}
    
    // 매개변수 생성자
    public PostVote(int post_id, String userid, String vote_type) {
        this.post_id = post_id;
        this.userid = userid;
        this.vote_type = vote_type;
    }
    
    // Getter & Setter
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getPost_id() {
        return post_id;
    }
    
    public void setPost_id(int post_id) {
        this.post_id = post_id;
    }
    
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public String getVote_type() {
        return vote_type;
    }
    
    public void setVote_type(String vote_type) {
        this.vote_type = vote_type;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}