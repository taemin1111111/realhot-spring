package com.wherehot.spring.service;

import com.wherehot.spring.entity.CourseCommentReaction;
import com.wherehot.spring.entity.CourseComment;
import com.wherehot.spring.mapper.CourseCommentReactionMapper;
import com.wherehot.spring.mapper.CourseCommentMapper;
import com.wherehot.spring.service.ExpService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CourseCommentReactionServiceImpl implements CourseCommentReactionService {
    
    @Autowired
    private CourseCommentReactionMapper reactionMapper;
    
    @Autowired
    private CourseCommentMapper courseCommentMapper;
    
    @Autowired
    private ExpService expService;
    
    @Override
    @Transactional
    public ReactionResult toggleReaction(Integer commentId, String userKey, String reactionType) {
        try {
            // 기존 리액션 조회
            CourseCommentReaction existingReaction = reactionMapper.getReactionByUserKey(commentId, userKey);
            
            if (existingReaction == null) {
                // 새로운 리액션 추가
                CourseCommentReaction newReaction = new CourseCommentReaction();
                newReaction.setCommentId(commentId);
                newReaction.setUserKey(userKey);
                newReaction.setReaction(reactionType);
                newReaction.setCreatedAt(LocalDateTime.now());
                
                reactionMapper.insertReaction(newReaction);
                
                // 좋아요를 받은 경우 댓글 작성자에게 경험치 지급
                if ("LIKE".equals(reactionType)) {
                    try {
                        // 댓글 작성자 정보 조회
                        CourseComment comment = courseCommentMapper.getCourseCommentById(commentId);
                        if (comment != null && comment.getAuthorUserid() != null && 
                            !comment.getAuthorUserid().trim().isEmpty() && 
                            !comment.getAuthorUserid().startsWith("anonymous|")) {
                            boolean expAdded = expService.addLikeExp(comment.getAuthorUserid(), 1);
                            if (expAdded) {
                                System.out.println("Like exp added successfully for course comment author: " + comment.getAuthorUserid());
                            } else {
                                System.out.println("Like exp not added (daily limit reached) for course comment author: " + comment.getAuthorUserid());
                            }
                        }
                    } catch (Exception e) {
                        System.err.println("Error adding like exp for course comment author: " + e.getMessage());
                        // 경험치 지급 실패는 추천 자체를 실패시키지 않음
                    }
                }
                
                // 댓글의 좋아요/싫어요 수 업데이트
                updateCommentReactionCounts(commentId);
                
                return new ReactionResult(true, "added", reactionType, 
                    reactionMapper.getLikeCount(commentId), 
                    reactionMapper.getDislikeCount(commentId), 
                    "리액션이 추가되었습니다.");
                
            } else {
                // 기존 리액션이 있는 경우
                if (existingReaction.getReaction().equals(reactionType)) {
                    // 같은 리액션을 다시 누른 경우 - 리액션 제거
                    reactionMapper.deleteReaction(commentId, userKey);
                    
                    // 댓글의 좋아요/싫어요 수 업데이트
                    updateCommentReactionCounts(commentId);
                    
                    return new ReactionResult(true, "removed", null, 
                        reactionMapper.getLikeCount(commentId), 
                        reactionMapper.getDislikeCount(commentId), 
                        "리액션이 제거되었습니다.");
                    
                } else {
                    // 다른 리액션으로 변경
                    existingReaction.setReaction(reactionType);
                    existingReaction.setCreatedAt(LocalDateTime.now());
                    
                    reactionMapper.updateReaction(existingReaction);
                    
                    // 댓글의 좋아요/싫어요 수 업데이트
                    updateCommentReactionCounts(commentId);
                    
                    return new ReactionResult(true, "updated", reactionType, 
                        reactionMapper.getLikeCount(commentId), 
                        reactionMapper.getDislikeCount(commentId), 
                        "리액션이 변경되었습니다.");
                }
            }
            
        } catch (Exception e) {
            return new ReactionResult(false, null, null, 0, 0, "리액션 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    @Override
    public CourseCommentReaction getReactionByUserKey(Integer commentId, String userKey) {
        return reactionMapper.getReactionByUserKey(commentId, userKey);
    }
    
    @Override
    public List<CourseCommentReaction> getReactionsByCommentId(Integer commentId) {
        return reactionMapper.getReactionsByCommentId(commentId);
    }
    
    @Override
    public int getLikeCount(Integer commentId) {
        return reactionMapper.getLikeCount(commentId);
    }
    
    @Override
    public int getDislikeCount(Integer commentId) {
        return reactionMapper.getDislikeCount(commentId);
    }
    
    /**
     * 댓글의 좋아요/싫어요 수를 업데이트
     */
    private void updateCommentReactionCounts(Integer commentId) {
        int likeCount = reactionMapper.getLikeCount(commentId);
        int dislikeCount = reactionMapper.getDislikeCount(commentId);
        
        reactionMapper.updateLikeCount(commentId, likeCount);
        reactionMapper.updateDislikeCount(commentId, dislikeCount);
    }
}
