package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 핫토크 투표 엔티티
 * hottalk_vote 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class HpostVote {
    
    private Integer id;                    // 투표 번호 (PK, AI)
    private Integer postId;                // 게시글 번호 (FK)
    private String userid;                 // 사용자 ID 또는 IP 주소
    private String voteType;               // 투표 타입 (like/dislike)
    private LocalDateTime createdAt;       // 생성 시간 (DATETIME, default CURRENT_TIMESTAMP)
    
    // 생성자
    public HpostVote() {
        this.createdAt = LocalDateTime.now();
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
    
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
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
    
    // 편의 메서드
    public boolean isLike() {
        return "like".equals(voteType);
    }
    
    public boolean isDislike() {
        return "dislike".equals(voteType);
    }
}
