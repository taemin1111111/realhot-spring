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
    
    // 댓글 삭제 (물리적 삭제)
    int deleteCourseComment(@Param("id") int id);
    
    // 코스의 모든 댓글 삭제
    int deleteAllCommentsByCourseId(@Param("courseId") int courseId);
    
    // 특정 댓글 조회
    CourseComment getCourseCommentById(@Param("id") int id);
    
    // 코스의 댓글 개수 조회
    int getCommentCountByCourseId(@Param("courseId") int courseId);
    
    // 부모 댓글의 대댓글 개수 조회
    int getReplyCountByParentId(@Param("parentId") int parentId);
    
    // 부모 댓글의 대댓글 목록 조회
    List<CourseComment> getRepliesByParentId(@Param("parentId") int parentId);
    
    // 코스의 부모 댓글만 조회 (현재 사용자의 리액션 상태 포함)
    List<CourseComment> getParentCommentsByCourseIdWithUserReaction(@Param("courseId") int courseId, @Param("userKey") String userKey);
    
    // 부모 댓글의 대댓글 목록 조회 (현재 사용자의 리액션 상태 포함)
    List<CourseComment> getRepliesByParentIdWithUserReaction(@Param("parentId") int parentId, @Param("userKey") String userKey);
    
    // 부모 댓글의 모든 대댓글 삭제
    int deleteRepliesByParentId(@Param("parentId") int parentId);
    
    // 댓글과 관련된 모든 리액션 삭제
    int deleteReactionsByCommentId(@Param("commentId") int commentId);
}
