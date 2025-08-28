package com.wherehot.spring.service;

import com.wherehot.spring.entity.CourseCommentReaction;

import java.util.List;

public interface CourseCommentReactionService {
    
    /**
     * 댓글 리액션 토글 (좋아요/싫어요 추가/변경/취소)
     * @param commentId 댓글 ID
     * @param userKey 사용자 키 (로그인 시 userid, 비로그인 시 IP)
     * @param reactionType 리액션 타입 ("LIKE" 또는 "DISLIKE")
     * @return 리액션 결과 정보
     */
    ReactionResult toggleReaction(Integer commentId, String userKey, String reactionType);
    
    /**
     * 특정 사용자의 특정 댓글 리액션 조회
     * @param commentId 댓글 ID
     * @param userKey 사용자 키
     * @return 리액션 정보 (없으면 null)
     */
    CourseCommentReaction getReactionByUserKey(Integer commentId, String userKey);
    
    /**
     * 댓글의 모든 리액션 조회
     * @param commentId 댓글 ID
     * @return 리액션 목록
     */
    List<CourseCommentReaction> getReactionsByCommentId(Integer commentId);
    
    /**
     * 댓글의 좋아요 수 조회
     * @param commentId 댓글 ID
     * @return 좋아요 수
     */
    int getLikeCount(Integer commentId);
    
    /**
     * 댓글의 싫어요 수 조회
     * @param commentId 댓글 ID
     * @return 싫어요 수
     */
    int getDislikeCount(Integer commentId);
    
    /**
     * 리액션 결과를 담는 클래스
     */
    class ReactionResult {
        private boolean success;
        private String action; // "added", "updated", "removed"
        private String currentReaction; // "LIKE", "DISLIKE", null
        private int likeCount;
        private int dislikeCount;
        private String message;
        
        public ReactionResult() {}
        
        public ReactionResult(boolean success, String action, String currentReaction, 
                            int likeCount, int dislikeCount, String message) {
            this.success = success;
            this.action = action;
            this.currentReaction = currentReaction;
            this.likeCount = likeCount;
            this.dislikeCount = dislikeCount;
            this.message = message;
        }
        
        // Getter & Setter
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public String getAction() { return action; }
        public void setAction(String action) { this.action = action; }
        
        public String getCurrentReaction() { return currentReaction; }
        public void setCurrentReaction(String currentReaction) { this.currentReaction = currentReaction; }
        
        public int getLikeCount() { return likeCount; }
        public void setLikeCount(int likeCount) { this.likeCount = likeCount; }
        
        public int getDislikeCount() { return dislikeCount; }
        public void setDislikeCount(int dislikeCount) { this.dislikeCount = dislikeCount; }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
}
