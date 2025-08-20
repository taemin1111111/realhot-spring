package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 공지사항 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class Notice {
    
    private int noticeId;
    private String title;
    private String content;
    private String writer;
    private String photo;
    private boolean pinned;
    private int viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isActive;
    
    // 기본 생성자
    public Notice() {}
    
    // 전체 필드 생성자
    public Notice(int noticeId, String title, String content, String writer, 
                    String photo, boolean pinned, int viewCount, 
                    LocalDateTime createdAt, LocalDateTime updatedAt, boolean isActive) {
        this.noticeId = noticeId;
        this.title = title;
        this.content = content;
        this.writer = writer;
        this.photo = photo;
        this.pinned = pinned;
        this.viewCount = viewCount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.isActive = isActive;
    }
    
    // Getters and Setters
    public int getNoticeId() {
        return noticeId;
    }
    
    public void setNoticeId(int noticeId) {
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
    
    public String getWriter() {
        return writer;
    }
    
    public void setWriter(String writer) {
        this.writer = writer;
    }
    
    public String getPhoto() {
        return photo;
    }
    
    public void setPhoto(String photo) {
        this.photo = photo;
    }
    
    public boolean isPinned() {
        return pinned;
    }
    
    public void setPinned(boolean pinned) {
        this.pinned = pinned;
    }
    
    public int getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
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
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    @Override
    public String toString() {
        return "Notice{" +
                "noticeId=" + noticeId +
                ", title='" + title + '\'' +
                ", content='" + content + '\'' +
                ", writer='" + writer + '\'' +
                ", photo='" + photo + '\'' +
                ", pinned=" + pinned +
                ", viewCount=" + viewCount +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                ", isActive=" + isActive +
                '}';
    }
}
