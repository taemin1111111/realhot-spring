package com.wherehot.spring.service;

import com.wherehot.spring.entity.Comment;

import java.util.List;
import java.util.Optional;

/**
 * 댓글 서비스 인터페이스
 */
public interface CommentService {
    
    List<Comment> findCommentsByPost(int postId);
    List<Comment> findCommentsByPostWithPaging(int postId, int page, int size);
    Optional<Comment> findCommentById(int id);
    List<Comment> findCommentsByAuthor(String authorId, int page, int size);
    List<Comment> findRepliesByParent(int parentCommentId);
    List<Comment> findRecentComments(int limit);
    
    Comment saveComment(Comment comment);
    Comment updateComment(Comment comment);
    boolean deleteComment(int id);
    boolean hardDeleteComment(int id);
    boolean updateLikeCount(int id, int likeCount);
    boolean updateDislikeCount(int id, int dislikeCount);
    boolean updateCommentStatus(int id, String status);
    
    int getCommentCountByPost(int postId);
    int getCommentCountByAuthor(String authorId);
    int getRepliesCountByParent(int parentCommentId);
    int getTotalCommentCount();
    int getActiveCommentCount();
}
