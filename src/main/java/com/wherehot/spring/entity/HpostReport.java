package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 핫토크 신고 엔티티
 * hottalk_report 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class HpostReport {
    
    private Integer id;                    // 신고 번호 (PK, AI)
    private String userId;                 // 사용자 ID (VARCHAR(50))
    private Integer postId;                // 게시글 번호 (FK, NN)
    private String reason;                 // 신고 사유 (VARCHAR(255))
    private String content;                // 신고 내용 (TEXT)
    private LocalDateTime reportTime;      // 신고 시간 (DATETIME, default CURRENT_TIMESTAMP)
    
    // 생성자
    public HpostReport() {
        this.reportTime = LocalDateTime.now();
    }
    
    // Getter & Setter
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public Integer getPostId() {
        return postId;
    }
    
    public void setPostId(Integer postId) {
        this.postId = postId;
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
