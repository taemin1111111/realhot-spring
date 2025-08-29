package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.PostVote;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PostVoteMapper {
    
    // 투표 존재 여부 확인
    boolean existsVote(@Param("postId") int postId, @Param("userKey") String userKey);
    
    // 투표 추가
    int insertVote(@Param("postId") int postId, @Param("userKey") String userKey, @Param("voteType") String voteType);
    
    // 투표 삭제
    int deleteVote(@Param("postId") int postId, @Param("userKey") String userKey);
    
    // 게시글별 투표 조회
    List<PostVote> getVotesByPostId(@Param("postId") int postId);
    
    // 사용자별 투표 조회
    List<PostVote> getVotesByUserKey(@Param("userKey") String userKey);
}
