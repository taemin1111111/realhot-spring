package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 코스 좋아요/싫어요 엔티티
 * course_reaction 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class CourseReaction {
    
    private Integer courseId;
    private String userKey;
    private String reaction; // 'LIKE' 또는 'DISLIKE'
    private LocalDateTime createdAt;
    
    // 연관관계 (MyBatis에서 별도 조회)
    private Course course;
    
    // 생성자
    public CourseReaction() {
        this.createdAt = LocalDateTime.now();
    }
    
    // Getter & Setter
    public Integer getCourseId() {
        return courseId;
    }
    
    public void setCourseId(Integer courseId) {
        this.courseId = courseId;
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
    
    public Course getCourse() {
        return course;
    }
    
    public void setCourse(Course course) {
        this.course = course;
    }
    
    // 편의 메서드
    public boolean isLike() {
        return "LIKE".equals(reaction);
    }
    
    public boolean isDislike() {
        return "DISLIKE".equals(reaction);
    }
}
