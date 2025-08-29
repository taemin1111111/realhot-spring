package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 코스 신고 엔티티
 * course_report 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class CourseReport {
    
    private Integer id;
    private Integer courseId;
    private String userKey;
    private String reason;
    private String details;
    private String status = "RECEIVED";
    private String result = "PENDING";
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 연관관계 (MyBatis에서 별도 조회)
    private Course course;
    
    // 생성자
    public CourseReport() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getter & Setter
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public Integer getCourseId() {
        return courseId;
    }
    
    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
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
    
    public String getDetails() {
        return details;
    }
    
    public void setDetails(String details) {
        this.details = details;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getResult() {
        return result;
    }
    
    public void setResult(String result) {
        this.result = result;
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
    
    public Course getCourse() {
        return course;
    }
    
    public void setCourse(Course course) {
        this.course = course;
    }
    
    // 상태 업데이트 메서드
    public void updateStatus(String newStatus) {
        this.status = newStatus;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void updateResult(String newResult) {
        this.result = newResult;
        this.updatedAt = LocalDateTime.now();
    }
    
    // 상태 확인 메서드
    public boolean isReceived() {
        return "RECEIVED".equals(this.status);
    }
    
    public boolean isConfirmed() {
        return "CONFIRMED".equals(this.status);
    }
    
    public boolean isProcessed() {
        return "PROCESSED".equals(this.status);
    }
    
    public boolean isPending() {
        return "PENDING".equals(this.result);
    }
    
    public boolean isSanctioned() {
        return "SANCTION".equals(this.result);
    }
    
    public boolean isDismissed() {
        return "DISMISSED".equals(this.result);
    }
    
    @Override
    public String toString() {
        return "CourseReport{" +
                "id=" + id +
                ", courseId=" + courseId +
                ", userKey='" + userKey + '\'' +
                ", reason='" + reason + '\'' +
                ", details='" + details + '\'' +
                ", status='" + status + '\'' +
                ", result='" + result + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
