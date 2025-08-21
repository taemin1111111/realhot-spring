package com.wherehot.spring.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 코스 댓글 엔티티
 * course_comment 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class CourseComment {
    
    private Integer id;
    private Integer courseId;
    private Integer parentId;
    private String authorUserid;
    private String nickname;
    private String passwdHash;
    private String content;
    private Integer likeCount = 0;
    private Integer dislikeCount = 0;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean isDeleted = false;
    
    // 연관관계 (MyBatis에서 별도 조회)
    private Course course;
    private CourseComment parentComment;
    private List<CourseComment> childComments = new ArrayList<>();
    private List<CourseCommentReaction> commentReactions = new ArrayList<>();
    
    // 생성자
    public CourseComment() {
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
    
    public Integer getParentId() {
        return parentId;
    }
    
    public void setParentId(Integer parentId) {
        this.parentId = parentId;
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
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
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
    
    public Boolean getIsDeleted() {
        return isDeleted;
    }
    
    public void setIsDeleted(Boolean isDeleted) {
        this.isDeleted = isDeleted;
    }
    
    public Course getCourse() {
        return course;
    }
    
    public void setCourse(Course course) {
        this.course = course;
    }
    
    public CourseComment getParentComment() {
        return parentComment;
    }
    
    public void setParentComment(CourseComment parentComment) {
        this.parentComment = parentComment;
    }
    
    public List<CourseComment> getChildComments() {
        return childComments;
    }
    
    public void setChildComments(List<CourseComment> childComments) {
        this.childComments = childComments;
    }
    
    public List<CourseCommentReaction> getCommentReactions() {
        return commentReactions;
    }
    
    public void setCommentReactions(List<CourseCommentReaction> commentReactions) {
        this.commentReactions = commentReactions;
    }
    
    // 편의 메서드
    public boolean isReply() {
        return parentId != null;
    }
    
    public boolean isRootComment() {
        return parentId == null;
    }
}
