package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 게시글 신고 엔티티
 * hottalk_report 테이블과 매핑
 */
public class PostReport {
    
    private Integer id;
    private Integer postId;
    private String userKey;
    private String reason;
    private String content;
    private LocalDateTime reportTime;
    
    // 생성자
    public PostReport() {
        this.reportTime = LocalDateTime.now();
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
}