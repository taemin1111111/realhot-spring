package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.HpostVote;
import com.wherehot.spring.mapper.HpostVoteMapper;
import com.wherehot.spring.service.HpostVoteService;
import com.wherehot.spring.service.HpostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * HpostVote 서비스 구현체
 */
@Service
@Transactional
public class HpostVoteServiceImpl implements HpostVoteService {
    
    @Autowired
    private HpostVoteMapper hpostVoteMapper;
    
    @Autowired
    private HpostService hpostService;
    
    @Override
    public Map<String, Object> processVote(int postId, String userid, String voteType) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 기존 투표 조회
            var existingVote = hpostVoteMapper.findVoteByUserAndPost(userid, postId);
            
            if (existingVote.isPresent()) {
                HpostVote vote = existingVote.get();
                
                // 같은 타입의 투표를 다시 누른 경우 - 투표 취소
                if (vote.getVoteType().equals(voteType)) {
                    hpostVoteMapper.deleteVote(vote.getId());
                    result.put("action", "cancelled");
                    result.put("message", "투표가 취소되었습니다.");
                } else {
                    // 다른 타입의 투표로 변경
                    vote.setVoteType(voteType);
                    hpostVoteMapper.updateVote(vote);
                    result.put("action", "changed");
                    result.put("message", "투표가 변경되었습니다.");
                }
            } else {
                // 새로운 투표 등록
                HpostVote newVote = new HpostVote();
                newVote.setPostId(postId);
                newVote.setUserid(userid);
                newVote.setVoteType(voteType);
                newVote.setCreatedAt(LocalDateTime.now());
                
                hpostVoteMapper.insertVote(newVote);
                result.put("action", "added");
                result.put("message", "투표가 등록되었습니다.");
            }
            
            // 업데이트된 투표 통계 조회
            Map<String, Object> statistics = getVoteStatistics(postId);
            int likes = (Integer) statistics.get("likes");
            int dislikes = (Integer) statistics.get("dislikes");
            
            // Hpost 테이블의 좋아요/싫어요 수 업데이트
            hpostService.updateVoteCounts(postId, likes, dislikes);
            
            result.put("likes", likes);
            result.put("dislikes", dislikes);
            result.put("userVoteStatus", getUserVoteStatus(postId, userid));
            result.put("success", true);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "투표 처리 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return result;
    }
    
    @Override
    public Map<String, Object> getVoteStatistics(int postId) {
        Map<String, Object> statistics = new HashMap<>();
        
        int likes = hpostVoteMapper.countLikesByPost(postId);
        int dislikes = hpostVoteMapper.countDislikesByPost(postId);
        
        statistics.put("likes", likes);
        statistics.put("dislikes", dislikes);
        statistics.put("total", likes + dislikes);
        
        return statistics;
    }
    
    @Override
    public String getUserVoteStatus(int postId, String userid) {
        var vote = hpostVoteMapper.findVoteByUserAndPost(userid, postId);
        return vote.map(HpostVote::getVoteType).orElse("none");
    }
}
