package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 댓글 투표 엔티티
 * hottalk_comment_vote 테이블과 매핑
 */
public class HcommentVote {
    private Integer id;                 // 투표 번호 (PK, AI)
    private Integer commentId;          // 댓글 ID (NN)
    private String userId;              // 사용자 ID (VARCHAR(100))
    private String ipAddress;           // IP 주소 (VARCHAR(100))
    private String voteType;            // 투표 타입 (ENUM('like', 'dislike'))
    private LocalDateTime createdAt;    // 투표 시간 (DATETIME, default CURRENT_TIMESTAMP)
    
    // 기본 생성자
    public HcommentVote() {
        this.createdAt = LocalDateTime.now();
    }
    
    // 매개변수 생성자 (로그인 사용자용)
    public HcommentVote(Integer commentId, String userId, String voteType) {
        this.commentId = commentId;
        this.userId = userId;
        this.ipAddress = null;
        this.voteType = voteType;
        this.createdAt = LocalDateTime.now();
    }

    // 정적 팩토리 메서드 (비로그인 사용자용)
    public static HcommentVote createForIp(Integer commentId, String ipAddress, String voteType) {
        HcommentVote dto = new HcommentVote();
        dto.commentId = commentId;
        dto.userId = null;
        dto.ipAddress = ipAddress;
        dto.voteType = voteType;
        dto.createdAt = LocalDateTime.now();
        return dto;
    }

    // Getter & Setter
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getCommentId() {
        return commentId;
    }

    public void setCommentId(Integer commentId) {
        this.commentId = commentId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
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
