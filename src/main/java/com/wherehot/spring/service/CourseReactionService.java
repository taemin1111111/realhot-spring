package com.wherehot.spring.service;

import com.wherehot.spring.entity.CourseReaction;

import java.util.Map;

public interface CourseReactionService {
    
    /**
     * 좋아요/싫어요 토글
     * @param courseId 코스 ID
     * @param userKey 사용자 키
     * @param reactionType 'LIKE' 또는 'DISLIKE'
     * @return 결과 정보 (현재 상태, 좋아요 개수, 싫어요 개수)
     */
    Map<String, Object> toggleReaction(int courseId, String userKey, String reactionType);
    
    /**
     * 사용자의 현재 리액션 상태 조회
     * @param courseId 코스 ID
     * @param userKey 사용자 키
     * @return 현재 리액션 ('LIKE', 'DISLIKE', null)
     */
    String getCurrentReaction(int courseId, String userKey);
    
    /**
     * 코스의 좋아요/싫어요 개수 조회
     * @param courseId 코스 ID
     * @return 좋아요/싫어요 개수 정보
     */
    Map<String, Integer> getReactionCounts(int courseId);
    
    /**
     * 사용자의 리액션 삭제
     * @param courseId 코스 ID
     * @param userKey 사용자 키
     * @return 삭제 성공 여부
     */
    boolean removeReaction(int courseId, String userKey);
}
