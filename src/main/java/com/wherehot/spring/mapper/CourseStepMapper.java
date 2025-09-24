package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.CourseStep;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CourseStepMapper {
    
    // 코스의 모든 스텝 조회
    List<CourseStep> getCourseStepsByCourseId(@Param("courseId") int courseId);
    
    // 코스 스텝 등록
    int insertCourseStep(CourseStep courseStep);
    
    // 코스 스텝 수정
    int updateCourseStep(CourseStep courseStep);
    
    // 코스 스텝 삭제
    int deleteCourseStep(@Param("id") int id);
    
    // 코스의 모든 스텝 삭제
    int deleteAllCourseStepsByCourseId(@Param("courseId") int courseId);
    
    // 특정 스텝 번호의 스텝 조회
    CourseStep getCourseStepByCourseIdAndStepNo(@Param("courseId") int courseId, @Param("stepNo") int stepNo);
    
    // 코스의 스텝 개수 조회
    int getCourseStepCount(@Param("courseId") int courseId);
    
    // 특정 가게가 포함된 코스 개수 조회
    int getCourseCountByPlaceId(@Param("placeId") int placeId);
}
