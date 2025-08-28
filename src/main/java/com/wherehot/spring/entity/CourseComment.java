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
    
    private int id;
    private int courseId;
    private Integer parentId;
    private String authorUserid;
    private String nickname;
    private String passwdHash;
    private String content;
    private int likeCount = 0;
    private int dislikeCount = 0;
    private int replyCount = 0; // 대댓글 갯수 (DB에 저장되지 않음, 조회 시 계산)
    private String userReaction; // 현재 사용자의 리액션 상태 (DB에 저장되지 않음, 조회 시 설정)
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
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getCourseId() {
        return courseId;
    }
    
    public void setCourseId(int courseId) {
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
    
    public int getLikeCount() {
        return likeCount;
    }
    
    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }
    
    public int getDislikeCount() {
        return dislikeCount;
    }
    
    public void setDislikeCount(int dislikeCount) {
        this.dislikeCount = dislikeCount;
    }
    
    public int getReplyCount() {
        return replyCount;
    }
    
    public void setReplyCount(int replyCount) {
        this.replyCount = replyCount;
    }
    
    public String getUserReaction() {
        return userReaction;
    }
    
    public void setUserReaction(String userReaction) {
        this.userReaction = userReaction;
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
