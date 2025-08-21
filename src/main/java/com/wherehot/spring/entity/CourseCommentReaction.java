package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 댓글 좋아요/싫어요 엔티티
 * course_comment_reaction 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class CourseCommentReaction {
    
    private Integer commentId;
    private String userKey;
    private String reaction; // 'LIKE' 또는 'DISLIKE'
    private LocalDateTime createdAt;
    
    // 연관관계 (MyBatis에서 별도 조회)
    private CourseComment courseComment;
    
    // 생성자
    public CourseCommentReaction() {
        this.createdAt = LocalDateTime.now();
    }
    
    // Getter & Setter
    public Integer getCommentId() {
        return commentId;
    }
    
    public void setCommentId(Integer commentId) {
        this.commentId = commentId;
    }
    
    public String getUserKey() {
        return userKey;
    }
    
    public void setUserKey(String userKey) {
        this.userKey = userKey;
    }
    
    public String getReaction() {
        return reaction;
    }
    
    public void setReaction(String reaction) {
        this.reaction = reaction;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public CourseComment getCourseComment() {
        return courseComment;
    }
    
    public void setCourseComment(CourseComment courseComment) {
        this.courseComment = courseComment;
    }
    
    // 편의 메서드
    public boolean isLike() {
        return "LIKE".equals(reaction);
    }
    
    public boolean isDislike() {
        return "DISLIKE".equals(reaction);
    }
}
