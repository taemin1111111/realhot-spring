package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

/**
 * 댓글 MyBatis Mapper
 */
@Mapper
public interface CommentMapper {
    
    /**
     * 게시글별 댓글 조회
     */
    List<Comment> findByPostId(@Param("postId") int postId);
    
    /**
     * 게시글별 댓글 조회 (페이징)
     */
    List<Comment> findByPostIdWithPaging(@Param("postId") int postId,
                                        @Param("offset") int offset,
                                        @Param("limit") int limit);
    
    /**
     * ID로 댓글 조회
     */
    Optional<Comment> findById(@Param("id") int id);
    
    /**
     * 작성자별 댓글 조회
     */
    List<Comment> findByAuthorId(@Param("authorId") String authorId,
                                @Param("offset") int offset,
                                @Param("limit") int limit);
    
    /**
     * 대댓글 조회
     */
    List<Comment> findRepliesByParent(@Param("parentCommentId") int parentCommentId);
    
    /**
     * 최신 댓글 조회
     */
    List<Comment> findRecentComments(@Param("limit") int limit);
    
    /**
     * 댓글 등록
     */
    int insertComment(Comment comment);
    
    /**
     * 댓글 수정
     */
    int updateComment(Comment comment);
    
    /**
     * 댓글 삭제 (소프트 삭제)
     */
    int deleteComment(@Param("id") int id);
    
    /**
     * 댓글 완전 삭제
     */
    int hardDeleteComment(@Param("id") int id);
    
    /**
     * 좋아요 수 업데이트
     */
    int updateLikeCount(@Param("id") int id, @Param("likeCount") int likeCount);
    
    /**
     * 싫어요 수 업데이트
     */
    int updateDislikeCount(@Param("id") int id, @Param("dislikeCount") int dislikeCount);
    
    /**
     * 댓글 상태 변경
     */
    int updateCommentStatus(@Param("id") int id, @Param("status") String status);
    
    /**
     * 게시글별 댓글 수
     */
    int countByPostId(@Param("postId") int postId);
    
    /**
     * 작성자별 댓글 수
     */
    int countByAuthorId(@Param("authorId") String authorId);
    
    /**
     * 대댓글 수
     */
    int countRepliesByParent(@Param("parentCommentId") int parentCommentId);
    
    /**
     * 전체 댓글 수
     */
    int countAll();
    
    /**
     * 활성 댓글 수
     */
    int countActive();
}
