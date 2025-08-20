package com.wherehot.spring.service;

import com.wherehot.spring.entity.PostVote;

import java.util.List;

/**
 * 게시글 투표 서비스 인터페이스
 * Model1의 HottalkVoteDao 기능을 Spring 방식으로 변환
 */
public interface PostVoteService {
    
    /**
     * 투표 추가/변경/취소 처리
     * @param postId 게시글 ID
     * @param userid 사용자 ID
     * @param action 액션 ("like", "dislike", "cancel")
     * @return 투표 결과 정보
     */
    VoteResult votePost(int postId, String userid, String action);
    
    /**
     * 특정 사용자의 특정 게시글 투표 조회
     * @param postId 게시글 ID
     * @param userid 사용자 ID
     * @return 투표 정보 (없으면 null)
     */
    PostVote getUserVote(int postId, String userid);
    
    /**
     * 게시글별 좋아요 수 조회
     * @param postId 게시글 ID
     * @return 좋아요 수
     */
    int getLikeCount(int postId);
    
    /**
     * 게시글별 싫어요 수 조회
     * @param postId 게시글 ID
     * @return 싫어요 수
     */
    int getDislikeCount(int postId);
    
    /**
     * 게시글의 모든 투표 조회
     * @param postId 게시글 ID
     * @return 투표 목록
     */
    List<PostVote> getVotesByPost(int postId);
    
    /**
     * 사용자가 특정 게시글에 투표했는지 확인
     * @param postId 게시글 ID
     * @param userid 사용자 ID
     * @return 투표 여부
     */
    boolean hasUserVoted(int postId, String userid);
    
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
