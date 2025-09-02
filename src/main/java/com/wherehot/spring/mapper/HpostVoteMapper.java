package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.HpostVote;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

/**
 * HpostVote MyBatis Mapper
 * hottalk_vote 테이블과 매핑
 */
@Mapper
public interface HpostVoteMapper {
    
    /**
     * 투표 등록
     */
    int insertVote(HpostVote vote);
    
    /**
     * 사용자별 게시글 투표 조회
     */
    Optional<HpostVote> findVoteByUserAndPost(@Param("userid") String userid, 
                                             @Param("postId") int postId);
    
    /**
     * 게시글별 투표 목록 조회
     */
    List<HpostVote> findVotesByPost(@Param("postId") int postId);
    
    /**
     * 게시글별 좋아요 수 조회
     */
    int countLikesByPost(@Param("postId") int postId);
    
    /**
     * 게시글별 싫어요 수 조회
     */
    int countDislikesByPost(@Param("postId") int postId);
    
    /**
     * 투표 수정
     */
    int updateVote(HpostVote vote);
    
    /**
     * 투표 삭제
     */
    int deleteVote(@Param("id") int id);
    
    /**
     * 사용자별 게시글 투표 삭제
     */
    int deleteVoteByUserAndPost(@Param("userid") String userid, 
                               @Param("postId") int postId);
}
