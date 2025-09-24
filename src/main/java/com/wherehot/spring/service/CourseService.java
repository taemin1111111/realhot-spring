package com.wherehot.spring.service;

import com.wherehot.spring.entity.Course;
import com.wherehot.spring.entity.CourseStep;
import com.wherehot.spring.mapper.CourseMapper;
import com.wherehot.spring.mapper.CourseStepMapper;
import com.wherehot.spring.mapper.CourseCommentMapper;
import com.wherehot.spring.mapper.CourseCommentReactionMapper;
import com.wherehot.spring.mapper.CourseReactionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.util.List;

@Service
public class CourseService {
    
    @Autowired
    private CourseMapper courseMapper;
    
    @Autowired
    private CourseStepMapper courseStepMapper;
    
    @Autowired
    private CourseCommentMapper courseCommentMapper;
    
    @Autowired
    private CourseCommentReactionMapper courseCommentReactionMapper;
    
    @Autowired
    private CourseReactionMapper courseReactionMapper;
    
    @Value("${file.upload.path:uploads/course}")
    private String uploadPath;
    
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
        // 코스 등록
        int result = courseMapper.insertCourse(course);
        
        if (result > 0 && courseSteps != null) {
            // 스텝 등록
            for (CourseStep step : courseSteps) {
                step.setCourseId(course.getId());
                courseStepMapper.insertCourseStep(step);
            }
        }
        
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
    
    // 검색으로 최신글 조회
    public List<Course> getLatestCourseListBySearch(String keyword, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getLatestCourseListBySearch(keyword, offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 검색으로 인기글 조회
    public List<Course> getPopularCourseListBySearch(String keyword, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getPopularCourseListBySearch(keyword, offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 검색으로 코스 수 조회
    public int getCourseCountBySearch(String keyword) {
        return courseMapper.getCourseCountBySearch(keyword);
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
    
    // 코스 삭제
    @Transactional
    public void deleteCourse(int courseId) {
        // 코스 정보 조회 (파일 경로 확인용)
        Course course = courseMapper.getCourseById(courseId);
        if (course != null) {
            // 코스의 모든 스텝 조회
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(courseId);
            
            // 각 스텝의 사진 파일 삭제
            for (CourseStep step : steps) {
                if (step.getPhotoUrl() != null && !step.getPhotoUrl().isEmpty()) {
                    deletePhotoFile(step.getPhotoUrl());
                }
            }
        }
        
        // 코스의 모든 리액션 삭제
        courseReactionMapper.deleteAllReactionsByCourseId(courseId);
        
        // 코스의 모든 댓글 리액션 삭제
        courseCommentReactionMapper.deleteAllReactionsByCourseId(courseId);
        
        // 코스의 모든 댓글 삭제
        courseCommentMapper.deleteAllCommentsByCourseId(courseId);
        
        // 코스 스텝들 삭제
        courseStepMapper.deleteAllCourseStepsByCourseId(courseId);
        
        // 코스 삭제 (물리적 삭제)
        courseMapper.deleteCourse(courseId);
    }
    
    // 특정 가게가 포함된 코스 개수 조회
    public int getCourseCountByPlaceId(int placeId) {
        return courseStepMapper.getCourseCountByPlaceId(placeId);
    }
    
    // 특정 가게가 포함된 인기글 목록 조회
    public List<Course> getPopularCourseListByPlaceId(int placeId, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getPopularCourseListByPlaceId(placeId, offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 특정 가게가 포함된 최신글 목록 조회
    public List<Course> getLatestCourseListByPlaceId(int placeId, int page) {
        int offset = (page - 1) * PAGE_SIZE;
        List<Course> courses = courseMapper.getLatestCourseListByPlaceId(placeId, offset, PAGE_SIZE);
        // 각 코스의 스텝 정보 로드
        for (Course course : courses) {
            List<CourseStep> steps = courseStepMapper.getCourseStepsByCourseId(course.getId());
            course.setCourseSteps(steps);
        }
        return courses;
    }
    
    // 사진 파일 삭제
    private void deletePhotoFile(String photoUrl) {
        try {
            // URL에서 파일 경로 추출
            String fileName = photoUrl.substring(photoUrl.lastIndexOf('/') + 1);
            String filePath = uploadPath + File.separator + fileName;
            
            File file = new File(filePath);
            if (file.exists()) {
                boolean deleted = file.delete();
                if (!deleted) {
                    System.err.println("파일 삭제 실패: " + filePath);
                }
            }
        } catch (Exception e) {
            System.err.println("파일 삭제 중 오류 발생: " + e.getMessage());
        }
    }
}
