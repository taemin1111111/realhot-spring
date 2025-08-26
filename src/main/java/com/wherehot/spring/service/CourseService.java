package com.wherehot.spring.service;

import com.wherehot.spring.entity.Course;
import com.wherehot.spring.entity.CourseStep;
import com.wherehot.spring.mapper.CourseMapper;
import com.wherehot.spring.mapper.CourseStepMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CourseService {
    
    @Autowired
    private CourseMapper courseMapper;
    
    @Autowired
    private CourseStepMapper courseStepMapper;
    
    // 페이징 크기
    private static final int PAGE_SIZE = 12;
    
    // 최신글 목록 조회
    public List<Course> getLatestCourseList(int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getLatestCourseList(offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 인기글 목록 조회
    public List<Course> getPopularCourseList(int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getPopularCourseList(offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 지역별 최신글 조회
    public List<Course> getLatestCourseListByRegion(String sido, String sigungu, String dong, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getCourseListByRegion(sido, sigungu, dong, offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 지역별 인기글 조회
    public List<Course> getPopularCourseListByRegion(String sido, String sigungu, String dong, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getPopularCourseListByRegion(sido, sigungu, dong, offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 코스 상세 조회 (조회수 증가 없음)
    @Transactional
    public Course getCourseById(int id) {
        return courseMapper.getCourseById(id);
    }
    
    // 코스 상세 조회 (조회수 증가 없음)
    @Transactional
    public Course getCourseByIdWithoutIncrement(int id) {
        return courseMapper.getCourseById(id);
    }
    
    // 조회수 증가
    @Transactional
    public void incrementViewCount(int id) {
        courseMapper.incrementViewCount(id);
    }
    
    // 코스 등록
    @Transactional
    public int createCourse(Course course, List<CourseStep> courseSteps) {
        System.out.println("=== CourseService.createCourse 시작 ===");
        System.out.println("코스 정보: " + course.getTitle() + ", " + course.getSummary() + ", " + course.getNickname());
        System.out.println("스텝 개수: " + (courseSteps != null ? courseSteps.size() : 0));
        
        // 코스 등록
        int result = courseMapper.insertCourse(course);
        System.out.println("코스 등록 결과: " + result);
        System.out.println("생성된 코스 ID: " + course.getId());
        
        if (result > 0 && courseSteps != null) {
            // 스텝 등록
            for (CourseStep step : courseSteps) {
                step.setCourseId(course.getId());
                int stepResult = courseStepMapper.insertCourseStep(step);
                System.out.println("스텝 등록 결과: " + stepResult + " (스텝번호: " + step.getStepNo() + ")");
            }
        }
        
        System.out.println("=== CourseService.createCourse 완료 ===");
        return result;
    }
    
    // 코스의 스텝 목록 조회
    public List<CourseStep> getCourseSteps(int courseId) {
        return courseStepMapper.getCourseStepsByCourseId(courseId);
    }
    
    // 전체 코스 수 조회
    public int getTotalCourseCount() {
        return courseMapper.getTotalCourseCount();
    }
    
    // 지역별 코스 수 조회
    public int getCourseCountByRegion(String sido, String sigungu, String dong) {
        return courseMapper.getCourseCountByRegion(sido, sigungu, dong);
    }
    
    // 좋아요 처리
    @Transactional
    public void toggleLike(int courseId, boolean isLike) {
        if (isLike) {
            courseMapper.incrementLikeCount(courseId);
        } else {
            courseMapper.decrementLikeCount(courseId);
        }
    }
    
    // 싫어요 처리
    @Transactional
    public void toggleDislike(int courseId, boolean isDislike) {
        if (isDislike) {
            courseMapper.incrementDislikeCount(courseId);
        } else {
            courseMapper.decrementDislikeCount(courseId);
        }
    }
}
