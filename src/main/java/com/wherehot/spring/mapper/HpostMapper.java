package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Hpost;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface HpostMapper {
    
    /**
     * 최신순 게시글 목록 조회
     */
    List<Hpost> selectLatestHpostList(@Param("offset") int offset);
    
    /**
     * 인기순 게시글 목록 조회
     */
    List<Hpost> selectPopularHpostList(@Param("offset") int offset);
    
    /**
     * 전체 게시글 수 조회
     */
    int selectTotalHpostCount();
    
    /**
     * 게시글 상세 조회
     */
    Hpost selectHpostById(@Param("id") int id);
    
    /**
     * 조회수 증가
     */
    void incrementViewCount(@Param("id") int id);
    
    /**
     * 게시글 저장
     */
    void insertHpost(Hpost hpost);
    
    /**
     * 좋아요/싫어요 수 업데이트
     */
    void updateVoteCounts(@Param("postId") int postId, 
                         @Param("likes") int likes, 
                         @Param("dislikes") int dislikes);
    
    /**
     * 게시글 삭제
     */
    int deleteHpost(@Param("id") int id);
}
