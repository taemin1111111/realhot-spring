package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 댓글 투표 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class CommentVote {
    private int id;                 // 투표 번호 (PK)
    private int comment_id;         // 댓글 ID
    private String user_id;         // 사용자 ID (로그인된 경우)
    private String ip_address;      // IP 주소 (비로그인 사용자)
    private String vote_type;       // 투표 타입 ("like" 또는 "dislike")
    private LocalDateTime createdAt;   // 투표 시간
    
    // 기본 생성자
    public CommentVote() {}
    
    // 매개변수 생성자 (로그인 사용자용)
    public CommentVote(int comment_id, String user_id, String vote_type) {
        this.comment_id = comment_id;
        this.user_id = user_id;
        this.ip_address = null;
        this.vote_type = vote_type;
    }

    // 정적 팩토리 메서드 (비로그인 사용자용)
    public static CommentVote createForIp(int comment_id, String ip_address, String vote_type) {
        CommentVote dto = new CommentVote();
        dto.comment_id = comment_id;
        dto.user_id = null;
        dto.ip_address = ip_address;
        dto.vote_type = vote_type;
        return dto;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getComment_id() {
        return comment_id;
    }

    public void setComment_id(int comment_id) {
        this.comment_id = comment_id;
    }

    public String getUser_id() {
        return user_id;
    }

    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }

    public String getIp_address() {
        return ip_address;
    }

    public void setIp_address(String ip_address) {
        this.ip_address = ip_address;
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