package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 게시글 신고 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class PostReport {
    
    private int id;
    private int post_id;
    private String reason;
    private String content;
    private LocalDateTime reportTime;
    private String user_id;
    
    // 기본 생성자
    public PostReport() {}
    
    // 전체 매개변수 생성자
    public PostReport(int id, int post_id, String reason, String content, LocalDateTime reportTime) {
        this.id = id;
        this.post_id = post_id;
        this.reason = reason;
        this.content = content;
        this.reportTime = reportTime;
    }
    
    // content 포함 생성자 (신고 추가용)
    public PostReport(int post_id, String user_id, String reason, String content) {
        this.post_id = post_id;
        this.user_id = user_id;
        this.reason = reason;
        this.content = content;
    }
    
    // Getter와 Setter 메서드들
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
    
    public String getReason() {
        return reason;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public LocalDateTime getReportTime() {
        return reportTime;
    }
    
    public void setReportTime(LocalDateTime reportTime) {
        this.reportTime = reportTime;
    }

    public String getUser_id() {
        return user_id;
    }
    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }
}