package com.wherehot.spring.service;

import com.wherehot.spring.entity.HpostVote;

import java.util.Map;

/**
 * HpostVote 서비스 인터페이스
 */
public interface HpostVoteService {
    
    /**
     * 투표 처리 (좋아요/싫어요)
     * @param postId 게시글 ID
     * @param userid 사용자 ID 또는 IP
     * @param voteType 투표 타입 (like/dislike)
     * @return 투표 결과 정보
     */
    Map<String, Object> processVote(int postId, String userid, String voteType);
    
    /**
     * 게시글별 투표 통계 조회
     * @param postId 게시글 ID
     * @return 투표 통계 정보
     */
    Map<String, Object> getVoteStatistics(int postId);
    
    /**
     * 사용자별 게시글 투표 상태 조회
     * @param postId 게시글 ID
     * @param userid 사용자 ID 또는 IP
     * @return 사용자 투표 상태
     */
    String getUserVoteStatus(int postId, String userid);
}
