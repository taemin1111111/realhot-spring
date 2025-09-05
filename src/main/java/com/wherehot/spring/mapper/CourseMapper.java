package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Course;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CourseMapper {
    
    // 코스 목록 조회 (페이징, 성능 최적화)
    List<Course> getCourseList(@Param("offset") int offset, @Param("limit") int limit);
    
    // 인기글 조회 (가중치 계산)
    List<Course> getPopularCourseList(@Param("offset") int offset, @Param("limit") int limit);
    
    // 최신글 조회
    List<Course> getLatestCourseList(@Param("offset") int offset, @Param("limit") int limit);
    
    // 지역별 코스 조회
    List<Course> getCourseListByRegion(@Param("sido") String sido, 
                                      @Param("sigungu") String sigungu, 
                                      @Param("dong") String dong,
                                      @Param("offset") int offset, 
                                      @Param("limit") int limit);
    
    // 지역별 인기글 조회
    List<Course> getPopularCourseListByRegion(@Param("sido") String sido, 
                                             @Param("sigungu") String sigungu, 
                                             @Param("dong") String dong,
                                             @Param("offset") int offset, 
                                             @Param("limit") int limit);
    
    // 코스 상세 조회
    Course getCourseById(@Param("id") int id);
    
    // 코스 등록
    int insertCourse(Course course);
    
    // 코스 수정
    int updateCourse(Course course);
    
    // 조회수 증가
    int incrementViewCount(@Param("id") int id);
    
    // 좋아요 수 증가
    int incrementLikeCount(@Param("id") int id);
    
    // 좋아요 수 감소
    int decrementLikeCount(@Param("id") int id);
    
    // 싫어요 수 증가
    int incrementDislikeCount(@Param("id") int id);
    
    // 싫어요 수 감소
    int decrementDislikeCount(@Param("id") int id);
    
    // 댓글 수 증가
    int incrementCommentCount(@Param("id") int id);
    
    // 댓글 수 감소
    int decrementCommentCount(@Param("id") int id);
    
    // 전체 코스 수 조회
    int getTotalCourseCount();
    
    // 지역별 코스 수 조회
    int getCourseCountByRegion(@Param("sido") String sido, 
                              @Param("sigungu") String sigungu, 
                              @Param("dong") String dong);
    
    // 코스 삭제 (논리적 삭제)
    int deleteCourse(@Param("id") int id);
    
    // 검색으로 최신글 조회
    List<Course> getLatestCourseListBySearch(@Param("keyword") String keyword, 
                                           @Param("offset") int offset, 
                                           @Param("limit") int limit);
    
    // 검색으로 인기글 조회
    List<Course> getPopularCourseListBySearch(@Param("keyword") String keyword, 
                                            @Param("offset") int offset, 
                                            @Param("limit") int limit);
    
    // 검색으로 코스 수 조회
    int getCourseCountBySearch(@Param("keyword") String keyword);
}
