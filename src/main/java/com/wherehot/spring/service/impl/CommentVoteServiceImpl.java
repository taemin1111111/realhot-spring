package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.CommentVote;
import com.wherehot.spring.mapper.CommentVoteMapper;
import com.wherehot.spring.service.CommentVoteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 댓글 투표 서비스 구현체
 * Model1의 HottalkCommentVoteDao 로직을 Spring 방식으로 변환
 */
@Service
@Transactional
public class CommentVoteServiceImpl implements CommentVoteService {
    
    @Autowired
    private CommentVoteMapper commentVoteMapper;
    
    @Override
    public VoteResult voteComment(int commentId, String userId, String action) {
        try {
            // 기존 투표 확인
            CommentVote existingVote = commentVoteMapper.getUserVote(commentId, userId);
            
            if ("cancel".equals(action)) {
                // 투표 취소
                if (existingVote != null) {
                    commentVoteMapper.deleteVoteByUser(commentId, userId);
                    int likeCount = commentVoteMapper.getLikeCount(commentId);
                    int dislikeCount = commentVoteMapper.getDislikeCount(commentId);
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
                CommentVote newVote = new CommentVote(commentId, userId, action);
                commentVoteMapper.insertVote(newVote);
                resultAction = "added";
            } else if (!existingVote.getVote_type().equals(action)) {
                // 투표 변경
                commentVoteMapper.updateVoteByUser(commentId, userId, action);
                resultAction = "changed";
            } else {
                // 같은 투표 - 취소 처리
                commentVoteMapper.deleteVoteByUser(commentId, userId);
                int likeCount = commentVoteMapper.getLikeCount(commentId);
                int dislikeCount = commentVoteMapper.getDislikeCount(commentId);
                return new VoteResult(true, "투표가 취소되었습니다.", "removed", null, likeCount, dislikeCount);
            }
            
            // 현재 투표 수 조회
            int likeCount = commentVoteMapper.getLikeCount(commentId);
            int dislikeCount = commentVoteMapper.getDislikeCount(commentId);
            
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
    public VoteResult voteCommentByIp(int commentId, String ipAddress, String action) {
        try {
            // 기존 투표 확인
            CommentVote existingVote = commentVoteMapper.getIpVote(commentId, ipAddress);
            
            if ("cancel".equals(action)) {
                // 투표 취소
                if (existingVote != null) {
                    commentVoteMapper.deleteVoteByIp(commentId, ipAddress);
                    int likeCount = commentVoteMapper.getLikeCount(commentId);
                    int dislikeCount = commentVoteMapper.getDislikeCount(commentId);
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
                CommentVote newVote = CommentVote.createForIp(commentId, ipAddress, action);
                commentVoteMapper.insertVote(newVote);
                resultAction = "added";
            } else if (!existingVote.getVote_type().equals(action)) {
                // 투표 변경
                commentVoteMapper.updateVoteByIp(commentId, ipAddress, action);
                resultAction = "changed";
            } else {
                // 같은 투표 - 취소 처리
                commentVoteMapper.deleteVoteByIp(commentId, ipAddress);
                int likeCount = commentVoteMapper.getLikeCount(commentId);
                int dislikeCount = commentVoteMapper.getDislikeCount(commentId);
                return new VoteResult(true, "투표가 취소되었습니다.", "removed", null, likeCount, dislikeCount);
            }
            
            // 현재 투표 수 조회
            int likeCount = commentVoteMapper.getLikeCount(commentId);
            int dislikeCount = commentVoteMapper.getDislikeCount(commentId);
            
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
    public CommentVote getUserVote(int commentId, String userId) {
        return commentVoteMapper.getUserVote(commentId, userId);
    }
    
    @Override
    public CommentVote getIpVote(int commentId, String ipAddress) {
        return commentVoteMapper.getIpVote(commentId, ipAddress);
    }
    
    @Override
    public int getLikeCount(int commentId) {
        return commentVoteMapper.getLikeCount(commentId);
    }
    
    @Override
    public int getDislikeCount(int commentId) {
        return commentVoteMapper.getDislikeCount(commentId);
    }
    
    @Override
    public List<CommentVote> getVotesByComment(int commentId) {
        return commentVoteMapper.getVotesByComment(commentId);
    }
    
    @Override
    public boolean hasUserVoted(int commentId, String userId) {
        return commentVoteMapper.hasUserVoted(commentId, userId);
    }
    
    @Override
    public boolean hasIpVoted(int commentId, String ipAddress) {
        return commentVoteMapper.hasIpVoted(commentId, ipAddress);
    }
}
