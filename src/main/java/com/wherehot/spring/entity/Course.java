package com.wherehot.spring.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 코스 글(루트 헤더) 엔티티
 * course 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class Course {
    
    private Integer id;
    private String userId;
    private String title;
    private String summary;
    private String authorUserid;
    private String nickname;
    private String passwdHash;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer viewCount = 0;
    private Integer likeCount = 0;
    private Integer dislikeCount = 0;
    private Integer commentCount = 0;
    private Boolean isDeleted = false;
    
    // 연관관계 (MyBatis에서 별도 조회)
    private List<CourseStep> courseSteps = new ArrayList<>();
    private List<CourseReaction> courseReactions = new ArrayList<>();
    private List<CourseComment> courseComments = new ArrayList<>();
    
    // 생성자
    public Course() {
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
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getSummary() {
        return summary;
    }
    
    public void setSummary(String summary) {
        this.summary = summary;
    }
    
    public String getAuthorUserid() {
        return authorUserid;
    }
    
    public void setAuthorUserid(String authorUserid) {
        this.authorUserid = authorUserid;
    }
    
    public String getNickname() {
        return nickname;
    }
    
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getPasswdHash() {
        return passwdHash;
    }
    
    public void setPasswdHash(String passwdHash) {
        this.passwdHash = passwdHash;
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
    
    public Integer getViewCount() {
        return viewCount;
    }
    
    public void setViewCount(Integer viewCount) {
        this.viewCount = viewCount;
    }
    
    public Integer getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(Integer likeCount) {
        this.likeCount = likeCount;
    }
    
    public Integer getDislikeCount() {
        return dislikeCount;
    }
    
    public void setDislikeCount(Integer dislikeCount) {
        this.dislikeCount = dislikeCount;
    }
    
    public Integer getCommentCount() {
        return commentCount;
    }
    
    public void setCommentCount(Integer commentCount) {
        this.commentCount = commentCount;
    }
    
    public Boolean getIsDeleted() {
        return isDeleted;
    }
    
    public void setIsDeleted(Boolean isDeleted) {
        this.isDeleted = isDeleted;
    }
    
    public List<CourseStep> getCourseSteps() {
        return courseSteps;
    }
    
    public void setCourseSteps(List<CourseStep> courseSteps) {
        this.courseSteps = courseSteps;
    }
    
    public List<CourseReaction> getCourseReactions() {
        return courseReactions;
    }
    
    public void setCourseReactions(List<CourseReaction> courseReactions) {
        this.courseReactions = courseReactions;
    }
    
    public List<CourseComment> getCourseComments() {
        return courseComments;
    }
    
    public void setCourseComments(List<CourseComment> courseComments) {
        this.courseComments = courseComments;
    }
}
