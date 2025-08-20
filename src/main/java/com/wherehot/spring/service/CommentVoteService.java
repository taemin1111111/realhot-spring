package com.wherehot.spring.service;

import com.wherehot.spring.entity.CommentVote;

import java.util.List;

/**
 * 댓글 투표 서비스 인터페이스
 * Model1의 HottalkCommentVoteDao 기능을 Spring 방식으로 변환
 */
public interface CommentVoteService {
    
    /**
     * 댓글 투표 추가/변경/취소 처리 (로그인 사용자)
     * @param commentId 댓글 ID
     * @param userId 사용자 ID
     * @param action 액션 ("like", "dislike", "cancel")
     * @return 투표 결과 정보
     */
    VoteResult voteComment(int commentId, String userId, String action);
    
    /**
     * 댓글 투표 추가/변경/취소 처리 (비로그인 사용자)
     * @param commentId 댓글 ID
     * @param ipAddress IP 주소
     * @param action 액션 ("like", "dislike", "cancel")
     * @return 투표 결과 정보
     */
    VoteResult voteCommentByIp(int commentId, String ipAddress, String action);
    
    /**
     * 특정 사용자의 특정 댓글 투표 조회
     * @param commentId 댓글 ID
     * @param userId 사용자 ID
     * @return 투표 정보 (없으면 null)
     */
    CommentVote getUserVote(int commentId, String userId);
    
    /**
     * 특정 IP의 특정 댓글 투표 조회
     * @param commentId 댓글 ID
     * @param ipAddress IP 주소
     * @return 투표 정보 (없으면 null)
     */
    CommentVote getIpVote(int commentId, String ipAddress);
    
    /**
     * 댓글별 좋아요 수 조회
     * @param commentId 댓글 ID
     * @return 좋아요 수
     */
    int getLikeCount(int commentId);
    
    /**
     * 댓글별 싫어요 수 조회
     * @param commentId 댓글 ID
     * @return 싫어요 수
     */
    int getDislikeCount(int commentId);
    
    /**
     * 댓글의 모든 투표 조회
     * @param commentId 댓글 ID
     * @return 투표 목록
     */
    List<CommentVote> getVotesByComment(int commentId);
    
    /**
     * 사용자가 특정 댓글에 투표했는지 확인
     * @param commentId 댓글 ID
     * @param userId 사용자 ID
     * @return 투표 여부
     */
    boolean hasUserVoted(int commentId, String userId);
    
    /**
     * IP가 특정 댓글에 투표했는지 확인
     * @param commentId 댓글 ID
     * @param ipAddress IP 주소
     * @return 투표 여부
     */
    boolean hasIpVoted(int commentId, String ipAddress);
    
    /**
     * 투표 결과 클래스
     */
    class VoteResult {
        private boolean success;
        private String message;
        private String action;      // "added", "changed", "removed"
        private String voteType;    // "like", "dislike", null
        private int likeCount;
        private int dislikeCount;
        
        public VoteResult(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
        
        public VoteResult(boolean success, String message, String action, String voteType, int likeCount, int dislikeCount) {
            this.success = success;
            this.message = message;
            this.action = action;
            this.voteType = voteType;
            this.likeCount = likeCount;
            this.dislikeCount = dislikeCount;
        }
        
        // Getter & Setter
        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        
        public String getAction() { return action; }
        public void setAction(String action) { this.action = action; }
        
        public String getVoteType() { return voteType; }
        public void setVoteType(String voteType) { this.voteType = voteType; }
        
        public int getLikeCount() { return likeCount; }
        public void setLikeCount(int likeCount) { this.likeCount = likeCount; }
        
        public int getDislikeCount() { return dislikeCount; }
        public void setDislikeCount(int dislikeCount) { this.dislikeCount = dislikeCount; }
    }
}
