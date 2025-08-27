package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.CourseComment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CourseCommentMapper {
    
    // 코스의 모든 댓글 조회 (계층 구조)
    List<CourseComment> getCommentsByCourseId(@Param("courseId") int courseId);
    
    // 코스의 부모 댓글만 조회
    List<CourseComment> getParentCommentsByCourseId(@Param("courseId") int courseId);
    
    // 댓글 등록
    int insertCourseComment(CourseComment courseComment);
    
    // 댓글 수정
    int updateCourseComment(CourseComment courseComment);
    
    // 댓글 삭제 (soft delete)
    int deleteCourseComment(@Param("id") int id);
    
    // 특정 댓글 조회
    CourseComment getCourseCommentById(@Param("id") int id);
    
    // 코스의 댓글 개수 조회
    int getCommentCountByCourseId(@Param("courseId") int courseId);
    
    // 부모 댓글의 대댓글 개수 조회
    int getReplyCountByParentId(@Param("parentId") int parentId);
    
    // 부모 댓글의 대댓글 목록 조회
    List<CourseComment> getRepliesByParentId(@Param("parentId") int parentId);
}
