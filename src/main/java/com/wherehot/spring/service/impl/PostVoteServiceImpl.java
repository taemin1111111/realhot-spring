package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.PostVote;
import com.wherehot.spring.mapper.PostVoteMapper;
import com.wherehot.spring.service.PostVoteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 게시글 투표 서비스 구현체
 * Model1의 HottalkVoteDao 로직을 Spring 방식으로 변환
 */
@Service
@Transactional
public class PostVoteServiceImpl implements PostVoteService {
    
    @Autowired
    private PostVoteMapper postVoteMapper;
    
    @Override
    public VoteResult votePost(int postId, String userid, String action) {
        try {
            // 기존 투표 확인
            PostVote existingVote = postVoteMapper.getUserVote(postId, userid);
            
            if ("cancel".equals(action)) {
                // 투표 취소
                if (existingVote != null) {
                    postVoteMapper.deleteVote(postId, userid);
                    int likeCount = postVoteMapper.getLikeCount(postId);
                    int dislikeCount = postVoteMapper.getDislikeCount(postId);
                    return new VoteResult(true, "투표가 취소되었습니다.", "removed", null, likeCount, dislikeCount);
                } else {
                    return new VoteResult(false, "취소할 투표가 없습니다.");
                }
            }
            
            if (!"like".equals(action) && !"dislike".equals(action)) {
                return new VoteResult(false, "올바르지 않은 투표 타입입니다.");
            }
            
            String resultAction;
            if (existingVote == null) {
                // 새 투표 추가
                PostVote newVote = new PostVote(postId, userid, action);
                postVoteMapper.insertVote(newVote);
                resultAction = "added";
            } else if (!existingVote.getVote_type().equals(action)) {
                // 투표 변경
                postVoteMapper.updateVote(postId, userid, action);
                resultAction = "changed";
            } else {
                // 같은 투표 - 취소 처리
                postVoteMapper.deleteVote(postId, userid);
                int likeCount = postVoteMapper.getLikeCount(postId);
                int dislikeCount = postVoteMapper.getDislikeCount(postId);
                return new VoteResult(true, "투표가 취소되었습니다.", "removed", null, likeCount, dislikeCount);
            }
            
            // 현재 투표 수 조회
            int likeCount = postVoteMapper.getLikeCount(postId);
            int dislikeCount = postVoteMapper.getDislikeCount(postId);
            
            String message = "like".equals(action) ? "좋아요가 추가되었습니다." : "싫어요가 추가되었습니다.";
            if ("changed".equals(resultAction)) {
                message = "like".equals(action) ? "싫어요에서 좋아요로 변경되었습니다." : "좋아요에서 싫어요로 변경되었습니다.";
            }
            
            return new VoteResult(true, message, resultAction, action, likeCount, dislikeCount);
            
        } catch (Exception e) {
            e.printStackTrace();
            return new VoteResult(false, "투표 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    @Override
    public PostVote getUserVote(int postId, String userid) {
        return postVoteMapper.getUserVote(postId, userid);
    }
    
    @Override
    public int getLikeCount(int postId) {
        return postVoteMapper.getLikeCount(postId);
    }
    
    @Override
    public int getDislikeCount(int postId) {
        return postVoteMapper.getDislikeCount(postId);
    }
    
    @Override
    public List<PostVote> getVotesByPost(int postId) {
        return postVoteMapper.getVotesByPost(postId);
    }
    
    @Override
    public boolean hasUserVoted(int postId, String userid) {
        return postVoteMapper.hasUserVoted(postId, userid);
    }
}
