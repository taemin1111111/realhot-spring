package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 코스의 각 스텝 엔티티
 * course_step 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class CourseStep {
    
    private Integer id;
    private Integer courseId;
    private Integer stepNo;
    private Integer placeId;
    private String placeName; // 핫플레이스 이름 (JOIN으로 가져올 때 사용)
    private String photoUrl;
    private String description;
    private LocalDateTime createdAt;
    
    // 연관관계 (MyBatis에서 별도 조회)
    private Course course;
    private Hotplace hotplace;
    
    // 생성자
    public CourseStep() {
        this.createdAt = LocalDateTime.now();
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
    
    public Integer getStepNo() {
        return stepNo;
    }
    
    public void setStepNo(Integer stepNo) {
        this.stepNo = stepNo;
    }
    
    public Integer getPlaceId() {
        return placeId;
    }
    
    public void setPlaceId(Integer placeId) {
        this.placeId = placeId;
    }
    
    public String getPlaceName() {
        return placeName;
    }
    
    public void setPlaceName(String placeName) {
        this.placeName = placeName;
    }
    
    public String getPhotoUrl() {
        return photoUrl;
    }
    
    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
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
    
    public Hotplace getHotplace() {
        return hotplace;
    }
    
    public void setHotplace(Hotplace hotplace) {
        this.hotplace = hotplace;
    }
}
