package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 콘텐츠 이미지 엔티티
 */
public class ContentImage {
    
    private Integer id;
    private Integer hotplaceId;
    private String imagePath;
    private String originalName;
    private String description;
    private Integer sortOrder;
    private Boolean isMainImage;
    private Boolean isActive;
    private String uploadedBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 핫플레이스 정보 (조인용)
    private String hotplaceName;
    private String hotplaceAddress;
    private String hotplaceRegion;
    
    // 기본 생성자
    public ContentImage() {}
    
    // 필수 필드 생성자
    public ContentImage(Integer hotplaceId, String imagePath, String originalName, String uploadedBy) {
        this.hotplaceId = hotplaceId;
        this.imagePath = imagePath;
        this.originalName = originalName;
        this.uploadedBy = uploadedBy;
        this.sortOrder = 0;
        this.isMainImage = false;
        this.isActive = true;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    // Getter/Setter
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    
    public Integer getHotplaceId() { return hotplaceId; }
    public void setHotplaceId(Integer hotplaceId) { this.hotplaceId = hotplaceId; }
    
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    
    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }
    
    public Boolean getIsMainImage() { return isMainImage; }
    public void setIsMainImage(Boolean isMainImage) { this.isMainImage = isMainImage; }
    
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    
    public String getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(String uploadedBy) { this.uploadedBy = uploadedBy; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    // 조인 필드
    public String getHotplaceName() { return hotplaceName; }
    public void setHotplaceName(String hotplaceName) { this.hotplaceName = hotplaceName; }
    
    public String getHotplaceAddress() { return hotplaceAddress; }
    public void setHotplaceAddress(String hotplaceAddress) { this.hotplaceAddress = hotplaceAddress; }
    
    public String getHotplaceRegion() { return hotplaceRegion; }
    public void setHotplaceRegion(String hotplaceRegion) { this.hotplaceRegion = hotplaceRegion; }
    
    @Override
    public String toString() {
        return "ContentImage{" +
                "id=" + id +
                ", hotplaceId=" + hotplaceId +
                ", imagePath='" + imagePath + '\'' +
                ", originalName='" + originalName + '\'' +
                ", description='" + description + '\'' +
                ", sortOrder=" + sortOrder +
                ", isMainImage=" + isMainImage +
                ", isActive=" + isActive +
                ", uploadedBy='" + uploadedBy + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
