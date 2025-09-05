package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 공지사항 엔티티
 * notice 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class Notice {
    
    private Long noticeId;
    private String title;
    private String content;
    private String photoUrl;
    private String writerUserid;
    private Integer viewCount = 0;
    private Boolean isPinned = false;
    private String status = "PUBLIC";
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 기본 생성자
    public Notice() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getter & Setter
    public Long getNoticeId() {
        return noticeId;
    }
    
    public void setNoticeId(Long noticeId) {
        this.noticeId = noticeId;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getPhotoUrl() {
        return photoUrl;
    }
    
    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }
    
    public String getWriterUserid() {
        return writerUserid;
    }
    
    public void setWriterUserid(String writerUserid) {
        this.writerUserid = writerUserid;
    }
    
    public Integer getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }
    
    public Boolean getIsPinned() {
        return isPinned;
    }
    
    public void setIsPinned(Boolean isPinned) {
        this.isPinned = isPinned;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
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
}