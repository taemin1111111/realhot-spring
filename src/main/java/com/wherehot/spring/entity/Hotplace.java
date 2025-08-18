package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 핫플레이스 엔티티
 */
public class Hotplace {
    
    private int id;
    private String name;
    private String address;
    private String description;
    private int categoryId;
    private double lat;
    private double lng;
    private String phone;
    private String website;
    private String operatingHours;
    private boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String region;
    private String sigungu;
    private double averageRating;
    private int reviewCount;
    private int wishCount;
    private int regionId; // region_id 추가
    private String genres; // 장르 정보 (임시 필드)
    
    // 기본 생성자
    public Hotplace() {}
    
    // 생성자
    public Hotplace(String name, String address, int categoryId) {
        this.name = name;
        this.address = address;
        this.categoryId = categoryId;
        this.active = true;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        this.averageRating = 0.0;
        this.reviewCount = 0;
        this.wishCount = 0;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }
    
    public double getLat() {
        return lat;
    }
    
    public void setLat(double lat) {
        this.lat = lat;
    }
    
    public double getLng() {
        return lng;
    }
    
    public void setLng(double lng) {
        this.lng = lng;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getWebsite() {
        return website;
    }
    
    public void setWebsite(String website) {
        this.website = website;
    }
    
    public String getOperatingHours() {
        return operatingHours;
    }
    
    public void setOperatingHours(String operatingHours) {
        this.operatingHours = operatingHours;
    }
    
    public boolean isActive() {
        return active;
    }
    
    public void setActive(boolean active) {
        this.active = active;
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
    
    public String getRegion() {
        return region;
    }
    
    public void setRegion(String region) {
        this.region = region;
    }
    
    public String getSigungu() {
        return sigungu;
    }
    
    public void setSigungu(String sigungu) {
        this.sigungu = sigungu;
    }
    
    public double getAverageRating() {
        return averageRating;
    }
    
    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }
    
    public int getReviewCount() {
        return reviewCount;
    }
    
    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }
    
    public int getWishCount() {
        return wishCount;
    }
    
    public void setWishCount(int wishCount) {
        this.wishCount = wishCount;
    }
    
    public int getRegionId() {
        return regionId;
    }
    
    public void setRegionId(int regionId) {
        this.regionId = regionId;
    }
    
    public String getGenres() {
        return genres;
    }
    
    public void setGenres(String genres) {
        this.genres = genres;
    }
    
    public double getLatitude() {
        return lat;
    }
    
    public void setLatitude(double latitude) {
        this.lat = latitude;
    }
    
    public double getLongitude() {
        return lng;
    }
    
    public void setLongitude(double longitude) {
        this.lng = longitude;
    }
    
    
    @Override
    public String toString() {
        return "Hotplace{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", address='" + address + '\'' +
                ", categoryId=" + categoryId +
                ", region='" + region + '\'' +
                ", sigungu='" + sigungu + '\'' +
                ", averageRating=" + averageRating +
                ", reviewCount=" + reviewCount +
                ", wishCount=" + wishCount +
                ", active=" + active +
                '}';
    }
}
