package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.CourseCommentReaction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CourseCommentReactionMapper {
    
    /**
     * 댓글 리액션 추가
     */
    int insertReaction(CourseCommentReaction reaction);
    
    /**
     * 댓글 리액션 수정
     */
    int updateReaction(CourseCommentReaction reaction);
    
    /**
     * 댓글 리액션 삭제
     */
    int deleteReaction(@Param("commentId") Integer commentId, @Param("userKey") String userKey);
    
    /**
     * 특정 사용자의 특정 댓글 리액션 조회
     */
    CourseCommentReaction getReactionByUserKey(@Param("commentId") Integer commentId, @Param("userKey") String userKey);
    
    /**
     * 댓글의 모든 리액션 조회
     */
    List<CourseCommentReaction> getReactionsByCommentId(@Param("commentId") Integer commentId);
    
    /**
     * 댓글의 좋아요 수 조회
     */
    int getLikeCount(@Param("commentId") Integer commentId);
    
    /**
     * 댓글의 싫어요 수 조회
     */
    int getDislikeCount(@Param("commentId") Integer commentId);
    
    /**
     * 댓글의 좋아요 수 업데이트
     */
    int updateLikeCount(@Param("commentId") Integer commentId, @Param("likeCount") Integer likeCount);
    
    /**
     * 댓글의 싫어요 수 업데이트
     */
    int updateDislikeCount(@Param("commentId") Integer commentId, @Param("dislikeCount") Integer dislikeCount);
    
    /**
     * 코스의 모든 댓글 리액션 삭제
     */
    int deleteAllReactionsByCourseId(@Param("courseId") Integer courseId);
}
