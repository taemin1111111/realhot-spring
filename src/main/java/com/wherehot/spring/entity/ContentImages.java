package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 콘텐츠 이미지 엔티티
 */
public class ContentImages {
    
    private int id;
    private int contentId;
    private String contentType; // hotplace, post, review 등
    private String imagePath;
    private String originalFilename;
    private String storedFilename;
    private long fileSize;
    private String mimeType;
    private boolean isMain; // 메인 이미지 여부
    private int sortOrder;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 기본 생성자
    public ContentImages() {}
    
    // 생성자
    public ContentImages(int contentId, String contentType, String imagePath, String originalFilename) {
        this.contentId = contentId;
        this.contentType = contentType;
        this.imagePath = imagePath;
        this.originalFilename = originalFilename;
        this.isMain = false;
        this.sortOrder = 0;
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
    
    public int getContentId() {
        return contentId;
    }
    
    public void setContentId(int contentId) {
        this.contentId = contentId;
    }
    
    public String getContentType() {
        return contentType;
    }
    
    public void setContentType(String contentType) {
        this.contentType = contentType;
    }
    
    public String getImagePath() {
        return imagePath;
    }
    
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
    
    public String getOriginalFilename() {
        return originalFilename;
    }
    
    public void setOriginalFilename(String originalFilename) {
        this.originalFilename = originalFilename;
    }
    
    public String getStoredFilename() {
        return storedFilename;
    }
    
    public void setStoredFilename(String storedFilename) {
        this.storedFilename = storedFilename;
    }
    
    public long getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }
    
    public String getMimeType() {
        return mimeType;
    }
    
    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }
    
    public boolean isMain() {
        return isMain;
    }
    
    public void setMain(boolean main) {
        isMain = main;
    }
    
    public int getSortOrder() {
        return sortOrder;
    }
    
    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
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
    
    // Model1 호환성을 위한 메소드들 추가
    public int getHotplaceId() {
        return contentId;
    }
    
    public void setHotplaceId(int hotplaceId) {
        this.contentId = hotplaceId;
    }
    
    public int getImageOrder() {
        return sortOrder;
    }
    
    public void setImageOrder(int imageOrder) {
        this.sortOrder = imageOrder;
    }
    
    @Override
    public String toString() {
        return "ContentImages{" +
                "id=" + id +
                ", contentId=" + contentId +
                ", contentType='" + contentType + '\'' +
                ", imagePath='" + imagePath + '\'' +
                ", originalFilename='" + originalFilename + '\'' +
                ", storedFilename='" + storedFilename + '\'' +
                ", isMain=" + isMain +
                ", sortOrder=" + sortOrder +
                '}';
    }
}
