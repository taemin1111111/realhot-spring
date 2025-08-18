package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 게시글 신고 엔티티
 */
public class PostReport {
    
    private int id;
    private int postId;
    private String reporterUserId;
    private String reporterNickname;
    private String reportType; // spam, inappropriate, violence, etc.
    private String reportReason;
    private String description;
    private String status; // pending, reviewed, resolved, rejected
    private String adminNote;
    private String adminUserId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime resolvedAt;
    
    // 기본 생성자
    public PostReport() {}
    
    // 생성자
    public PostReport(int postId, String reporterUserId, String reportType, String reportReason) {
        this.postId = postId;
        this.reporterUserId = reporterUserId;
        this.reportType = reportType;
        this.reportReason = reportReason;
        this.status = "pending";
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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
    
    public String getReporterUserId() {
        return reporterUserId;
    }
    
    public void setReporterUserId(String reporterUserId) {
        this.reporterUserId = reporterUserId;
    }
    
    public String getReporterNickname() {
        return reporterNickname;
    }
    
    public void setReporterNickname(String reporterNickname) {
        this.reporterNickname = reporterNickname;
    }
    
    public String getReportType() {
        return reportType;
    }
    
    public void setReportType(String reportType) {
        this.reportType = reportType;
    }
    
    public String getReportReason() {
        return reportReason;
    }
    
    public void setReportReason(String reportReason) {
        this.reportReason = reportReason;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getAdminNote() {
        return adminNote;
    }
    
    public void setAdminNote(String adminNote) {
        this.adminNote = adminNote;
    }
    
    public String getAdminUserId() {
        return adminUserId;
    }
    
    public void setAdminUserId(String adminUserId) {
        this.adminUserId = adminUserId;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public LocalDateTime getResolvedAt() {
        return resolvedAt;
    }
    
    public void setResolvedAt(LocalDateTime resolvedAt) {
        this.resolvedAt = resolvedAt;
    }
    
    /**
     * 신고 처리 완료
     */
    public void resolve(String adminUserId, String adminNote) {
        this.status = "resolved";
        this.adminUserId = adminUserId;
        this.adminNote = adminNote;
        this.resolvedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 신고 거부
     */
    public void reject(String adminUserId, String adminNote) {
        this.status = "rejected";
        this.adminUserId = adminUserId;
        this.adminNote = adminNote;
        this.resolvedAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 처리 대기 중인지 확인
     */
    public boolean isPending() {
        return "pending".equals(status);
    }
    
    @Override
    public String toString() {
        return "PostReport{" +
                "id=" + id +
                ", postId=" + postId +
                ", reporterUserId='" + reporterUserId + '\'' +
                ", reportType='" + reportType + '\'' +
                ", reportReason='" + reportReason + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", resolvedAt=" + resolvedAt +
                '}';
    }
}
