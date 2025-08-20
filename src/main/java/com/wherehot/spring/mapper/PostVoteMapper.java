package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.PostVote;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 게시글 투표 매퍼 인터페이스
 * Model1의 HottalkVoteDao와 동일한 기능을 MyBatis 방식으로 구현
 */
@Mapper
public interface PostVoteMapper {
    
    /**
     * 투표 추가
     */
    int insertVote(PostVote postVote);
    
    /**
     * 특정 사용자의 특정 게시글 투표 조회
     */
    PostVote getUserVote(@Param("postId") int postId, @Param("userid") String userid);
    
    /**
     * 투표 변경 (좋아요 → 싫어요 또는 그 반대)
     */
    int updateVote(@Param("postId") int postId, @Param("userid") String userid, @Param("voteType") String voteType);
    
    /**
     * 투표 삭제 (투표 취소)
     */
    int deleteVote(@Param("postId") int postId, @Param("userid") String userid);
    
    /**
     * 게시글별 좋아요 수 조회
     */
    int getLikeCount(@Param("postId") int postId);
    
    /**
     * 게시글별 싫어요 수 조회
     */
    int getDislikeCount(@Param("postId") int postId);
    
    /**
     * 게시글의 모든 투표 조회
     */
    List<PostVote> getVotesByPost(@Param("postId") int postId);
    
    /**
     * 사용자가 특정 게시글에 투표했는지 확인
     */
    boolean hasUserVoted(@Param("postId") int postId, @Param("userid") String userid);
}
