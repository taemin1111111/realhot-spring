package com.wherehot.spring.mapper;


import com.wherehot.spring.entity.Hpost;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface HpostMapper {
    
    // 게시글 목록 조회 (페이징, 성능 최적화)
    List<Hpost> getHpostList(@Param("offset") int offset, @Param("limit") int limit);
    
    // 인기글 조회 (가중치 계산)
    List<Hpost> getPopularHpostList(@Param("offset") int offset, @Param("limit") int limit);
    
    // 최신글 조회
    List<Hpost> getLatestHpostList(@Param("offset") int offset, @Param("limit") int limit);
    
    // 카테고리별 게시글 조회
    List<Hpost> getHpostListByCategory(@Param("categoryId") int categoryId,
                                      @Param("offset") int offset, 
                                      @Param("limit") int limit);
    
    // 카테고리별 인기글 조회
    List<Hpost> getPopularHpostListByCategory(@Param("categoryId") int categoryId,
                                             @Param("offset") int offset, 
                                             @Param("limit") int limit);
    
    // 게시글 상세 조회
    Hpost getHpostById(@Param("id") int id);
    
    // 게시글 등록
    int insertHpost(Hpost hpost);
    
    // 게시글 수정
    int updateHpost(Hpost hpost);
    
    // 조회수 증가
    int incrementViewCount(@Param("id") int id);
    
    // 좋아요 수 증가
    int incrementLikeCount(@Param("id") int id);
    
    // 좋아요 수 감소
    int decrementLikeCount(@Param("id") int id);
    
    // 싫어요 수 증가
    int incrementDislikeCount(@Param("id") int id);
    
    // 싫어요 수 감소
    int decrementDislikeCount(@Param("id") int id);
    
    // 댓글 수 증가
    int incrementCommentCount(@Param("id") int id);
    
    // 댓글 수 감소
    int decrementCommentCount(@Param("id") int id);
    
    // 신고 수 증가
    int incrementReportCount(@Param("id") int id);
    
    // 게시글 삭제 (논리적 삭제)
    int deleteHpost(@Param("id") int id);
    
    // 전체 게시글 수 조회
    int getTotalHpostCount();
    
    // 카테고리별 게시글 수 조회
    int getHpostCountByCategory(@Param("categoryId") int categoryId);
    
    // 검색
    List<Hpost> searchHposts(@Param("keyword") String keyword, 
                            @Param("searchType") String searchType,
                            @Param("offset") int offset, 
                            @Param("limit") int limit);
}
