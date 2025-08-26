package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.CourseReaction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

@Mapper
public interface CourseReactionMapper {
    
    // 사용자의 특정 코스 리액션 조회
    Optional<CourseReaction> findByCourseIdAndUserKey(@Param("courseId") int courseId, @Param("userKey") String userKey);
    
    // 코스의 모든 리액션 조회
    List<CourseReaction> findByCourseId(@Param("courseId") int courseId);
    
    // 좋아요 개수 조회
    int countLikesByCourseId(@Param("courseId") int courseId);
    
    // 싫어요 개수 조회
    int countDislikesByCourseId(@Param("courseId") int courseId);
    
    // 리액션 추가/수정
    int insertOrUpdateReaction(CourseReaction reaction);
    
    // 리액션 삭제
    int deleteReaction(@Param("courseId") int courseId, @Param("userKey") String userKey);
    
    // 사용자의 리액션 존재 여부 확인
    boolean existsByCourseIdAndUserKey(@Param("courseId") int courseId, @Param("userKey") String userKey);
}
