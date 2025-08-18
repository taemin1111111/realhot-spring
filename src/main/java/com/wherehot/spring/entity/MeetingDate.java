package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 미팅/데이트 엔티티 (MD)
 */
public class MeetingDate {
    
    private int id;
    private String title;
    private String description;
    private String authorId;
    private String authorNickname;
    private String meetingType; // meeting, date, group
    private String gender; // male, female, mixed
    private int maxParticipants;
    private int currentParticipants;
    private String location;
    private String locationDetail;
    private LocalDateTime meetingDateTime;
    private int ageMinLimit;
    private int ageMaxLimit;
    private String requirements;
    private String contactInfo;
    private String status; // recruiting, full, closed, cancelled, completed
    private int viewCount;
    private int likeCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime deadline;
    private boolean isVerified;
    private String imageUrl;
    
    // 기본 생성자
    public MeetingDate() {}
    
    // 생성자
    public MeetingDate(String title, String description, String authorId, String meetingType) {
        this.title = title;
        this.description = description;
        this.authorId = authorId;
        this.meetingType = meetingType;
        this.status = "recruiting";
        this.currentParticipants = 1; // 작성자 포함
        this.viewCount = 0;
        this.likeCount = 0;
        this.isVerified = false;
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
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getAuthorId() {
        return authorId;
    }
    
    public void setAuthorId(String authorId) {
        this.authorId = authorId;
    }
    
    public String getAuthorNickname() {
        return authorNickname;
    }
    
    public void setAuthorNickname(String authorNickname) {
        this.authorNickname = authorNickname;
    }
    
    public String getMeetingType() {
        return meetingType;
    }
    
    public void setMeetingType(String meetingType) {
        this.meetingType = meetingType;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public int getMaxParticipants() {
        return maxParticipants;
    }
    
    public void setMaxParticipants(int maxParticipants) {
        this.maxParticipants = maxParticipants;
    }
    
    public int getCurrentParticipants() {
        return currentParticipants;
    }
    
    public void setCurrentParticipants(int currentParticipants) {
        this.currentParticipants = currentParticipants;
    }
    
    public String getLocation() {
        return location;
    }
    
    public void setLocation(String location) {
        this.location = location;
    }
    
    public String getLocationDetail() {
        return locationDetail;
    }
    
    public void setLocationDetail(String locationDetail) {
        this.locationDetail = locationDetail;
    }
    
    public LocalDateTime getMeetingDateTime() {
        return meetingDateTime;
    }
    
    public void setMeetingDateTime(LocalDateTime meetingDateTime) {
        this.meetingDateTime = meetingDateTime;
    }
    
    public int getAgeMinLimit() {
        return ageMinLimit;
    }
    
    public void setAgeMinLimit(int ageMinLimit) {
        this.ageMinLimit = ageMinLimit;
    }
    
    public int getAgeMaxLimit() {
        return ageMaxLimit;
    }
    
    public void setAgeMaxLimit(int ageMaxLimit) {
        this.ageMaxLimit = ageMaxLimit;
    }
    
    public String getRequirements() {
        return requirements;
    }
    
    public void setRequirements(String requirements) {
        this.requirements = requirements;
    }
    
    public String getContactInfo() {
        return contactInfo;
    }
    
    public void setContactInfo(String contactInfo) {
        this.contactInfo = contactInfo;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public int getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(int viewCount) {
        this.viewCount = viewCount;
    }
    
    public int getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
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
    
    public LocalDateTime getDeadline() {
        return deadline;
    }
    
    public void setDeadline(LocalDateTime deadline) {
        this.deadline = deadline;
    }
    
    public boolean isVerified() {
        return isVerified;
    }
    
    public void setVerified(boolean verified) {
        isVerified = verified;
    }
    
    public String getImageUrl() {
        return imageUrl;
    }
    
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
    
    /**
     * 모집 가능한지 확인
     */
    public boolean isRecruiting() {
        return "recruiting".equals(status) && currentParticipants < maxParticipants;
    }
    
    /**
     * 마감되었는지 확인
     */
    public boolean isFull() {
        return currentParticipants >= maxParticipants;
    }
    
    /**
     * 조회수 증가
     */
    public void incrementViewCount() {
        this.viewCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 좋아요 수 증가
     */
    public void incrementLikeCount() {
        this.likeCount++;
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * 참가자 추가
     */
    public void addParticipant() {
        if (currentParticipants < maxParticipants) {
            this.currentParticipants++;
            if (isFull()) {
                this.status = "full";
            }
            this.updatedAt = LocalDateTime.now();
        }
    }
    
    /**
     * 참가자 제거
     */
    public void removeParticipant() {
        if (currentParticipants > 1) {
            this.currentParticipants--;
            if ("full".equals(status)) {
                this.status = "recruiting";
            }
            this.updatedAt = LocalDateTime.now();
        }
    }
    
    @Override
    public String toString() {
        return "MeetingDate{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", authorId='" + authorId + '\'' +
                ", meetingType='" + meetingType + '\'' +
                ", gender='" + gender + '\'' +
                ", currentParticipants=" + currentParticipants +
                ", maxParticipants=" + maxParticipants +
                ", status='" + status + '\'' +
                ", meetingDateTime=" + meetingDateTime +
                ", location='" + location + '\'' +
                '}';
    }
}
