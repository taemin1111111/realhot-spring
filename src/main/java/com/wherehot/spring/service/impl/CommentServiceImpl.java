package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Comment;
import com.wherehot.spring.mapper.CommentMapper;
import com.wherehot.spring.service.CommentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CommentServiceImpl implements CommentService {
    
    private static final Logger logger = LoggerFactory.getLogger(CommentServiceImpl.class);
    
    @Autowired
    private CommentMapper commentMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Comment> findCommentsByPost(int postId) {
        try {
            return commentMapper.findByPostId(postId);
        } catch (Exception e) {
            logger.error("Error finding comments by post: {}", postId, e);
            throw new RuntimeException("게시글별 댓글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Comment> findCommentsByPostWithPaging(int postId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return commentMapper.findByPostIdWithPaging(postId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding comments by post with paging: postId={}, page={}, size={}", postId, page, size, e);
            throw new RuntimeException("게시글별 댓글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Comment> findCommentById(int id) {
        try {
            return commentMapper.findById(id);
        } catch (Exception e) {
            logger.error("Error finding comment by id: {}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Comment> findCommentsByAuthor(String authorId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return commentMapper.findByAuthorId(authorId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding comments by author: {}", authorId, e);
            throw new RuntimeException("작성자별 댓글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Comment> findRepliesByParent(int parentCommentId) {
        try {
            return commentMapper.findRepliesByParent(parentCommentId);
        } catch (Exception e) {
            logger.error("Error finding replies by parent: {}", parentCommentId, e);
            throw new RuntimeException("부모 댓글별 답글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Comment> findRecentComments(int limit) {
        try {
            return commentMapper.findRecentComments(limit);
        } catch (Exception e) {
            logger.error("Error finding recent comments", e);
            throw new RuntimeException("최신 댓글 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Comment saveComment(Comment comment) {
        try {
            comment.setCreatedAt(LocalDateTime.now());
            comment.setUpdatedAt(LocalDateTime.now());
            if (comment.getStatus() == null) {
                comment.setStatus("ACTIVE");
            }
            
            int result = commentMapper.insertComment(comment);
            if (result > 0) {
                logger.info("Comment saved successfully: postId={}, authorId={}", 
                    comment.getPostId(), comment.getAuthorId());
                return comment;
            } else {
                throw new RuntimeException("댓글 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving comment: postId={}, authorId={}", 
                comment.getPostId(), comment.getAuthorId(), e);
            throw new RuntimeException("댓글 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Comment updateComment(Comment comment) {
        try {
            Optional<Comment> existingComment = commentMapper.findById(comment.getId());
            if (existingComment.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 댓글입니다: " + comment.getId());
            }
            
            comment.setUpdatedAt(LocalDateTime.now());
            
            int result = commentMapper.updateComment(comment);
            if (result > 0) {
                logger.info("Comment updated successfully: {}", comment.getId());
                return comment;
            } else {
                throw new RuntimeException("댓글 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating comment: {}", comment.getId(), e);
            throw new RuntimeException("댓글 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteComment(int id) {
        try {
            Optional<Comment> comment = commentMapper.findById(id);
            if (comment.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 댓글입니다: " + id);
            }
            
            // 소프트 삭제 (상태를 DELETED로 변경)
            int result = commentMapper.updateCommentStatus(id, "DELETED");
            if (result > 0) {
                logger.info("Comment deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting comment: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean hardDeleteComment(int id) {
        try {
            Optional<Comment> comment = commentMapper.findById(id);
            if (comment.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 댓글입니다: " + id);
            }
            
            int result = commentMapper.deleteComment(id);
            if (result > 0) {
                logger.info("Comment hard deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error hard deleting comment: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean updateLikeCount(int id, int likeCount) {
        try {
            int result = commentMapper.updateLikeCount(id, likeCount);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating like count: id={}, likeCount={}", id, likeCount, e);
            return false;
        }
    }
    
    @Override
    public boolean updateDislikeCount(int id, int dislikeCount) {
        try {
            int result = commentMapper.updateDislikeCount(id, dislikeCount);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating dislike count: id={}, dislikeCount={}", id, dislikeCount, e);
            return false;
        }
    }
    
    @Override
    public boolean updateCommentStatus(int id, String status) {
        try {
            int result = commentMapper.updateCommentStatus(id, status);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating comment status: id={}, status={}", id, status, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getCommentCountByPost(int postId) {
        try {
            return commentMapper.countByPostId(postId);
        } catch (Exception e) {
            logger.error("Error getting comment count by post: {}", postId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getCommentCountByAuthor(String authorId) {
        try {
            return commentMapper.countByAuthorId(authorId);
        } catch (Exception e) {
            logger.error("Error getting comment count by author: {}", authorId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getRepliesCountByParent(int parentCommentId) {
        try {
            return commentMapper.countRepliesByParent(parentCommentId);
        } catch (Exception e) {
            logger.error("Error getting replies count by parent: {}", parentCommentId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getTotalCommentCount() {
        try {
            return commentMapper.countAll();
        } catch (Exception e) {
            logger.error("Error getting total comment count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getActiveCommentCount() {
        try {
            return commentMapper.countActive();
        } catch (Exception e) {
            logger.error("Error getting active comment count", e);
            return 0;
        }
    }
}
