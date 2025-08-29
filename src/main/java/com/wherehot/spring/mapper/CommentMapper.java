package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CommentMapper {
    
    // 게시글별 댓글 조회
    List<Comment> getCommentsByPostId(@Param("postId") int postId);
    
    // 댓글 등록
    int insertComment(Comment comment);
    
    // 댓글 수정
    int updateComment(Comment comment);
    
    // 댓글 삭제
    int deleteComment(@Param("id") int id);
    
    // 댓글 수 조회
    int getCommentCountByPostId(@Param("postId") int postId);
}
