package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.CommentVote;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 댓글 투표 매퍼 인터페이스
 * Model1의 HottalkCommentVoteDao와 동일한 기능을 MyBatis 방식으로 구현
 */
@Mapper
public interface CommentVoteMapper {
    
    /**
     * 투표 추가
     */
    int insertVote(CommentVote commentVote);
    
    /**
     * 특정 사용자의 특정 댓글 투표 조회 (로그인 사용자)
     */
    CommentVote getUserVote(@Param("commentId") int commentId, @Param("userId") String userId);
    
    /**
     * 특정 IP의 특정 댓글 투표 조회 (비로그인 사용자)
     */
    CommentVote getIpVote(@Param("commentId") int commentId, @Param("ipAddress") String ipAddress);
    
    /**
     * 투표 변경 (좋아요 → 싫어요 또는 그 반대) - 로그인 사용자
     */
    int updateVoteByUser(@Param("commentId") int commentId, @Param("userId") String userId, @Param("voteType") String voteType);
    
    /**
     * 투표 변경 (좋아요 → 싫어요 또는 그 반대) - 비로그인 사용자
     */
    int updateVoteByIp(@Param("commentId") int commentId, @Param("ipAddress") String ipAddress, @Param("voteType") String voteType);
    
    /**
     * 투표 삭제 (투표 취소) - 로그인 사용자
     */
    int deleteVoteByUser(@Param("commentId") int commentId, @Param("userId") String userId);
    
    /**
     * 투표 삭제 (투표 취소) - 비로그인 사용자
     */
    int deleteVoteByIp(@Param("commentId") int commentId, @Param("ipAddress") String ipAddress);
    
    /**
     * 댓글별 좋아요 수 조회
     */
    int getLikeCount(@Param("commentId") int commentId);
    
    /**
     * 댓글별 싫어요 수 조회
     */
    int getDislikeCount(@Param("commentId") int commentId);
    
    /**
     * 댓글의 모든 투표 조회
     */
    List<CommentVote> getVotesByComment(@Param("commentId") int commentId);
    
    /**
     * 사용자가 특정 댓글에 투표했는지 확인 - 로그인 사용자
     */
    boolean hasUserVoted(@Param("commentId") int commentId, @Param("userId") String userId);
    
    /**
     * IP가 특정 댓글에 투표했는지 확인 - 비로그인 사용자
     */
    boolean hasIpVoted(@Param("commentId") int commentId, @Param("ipAddress") String ipAddress);
}
