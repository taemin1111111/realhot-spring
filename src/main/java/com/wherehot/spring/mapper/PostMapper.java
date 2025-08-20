package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Post;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 게시글 MyBatis Mapper
 */
@Mapper
public interface PostMapper {
    
    /**
     * 모든 게시글 조회 (페이징)
     */
    List<Post> findAll(@Param("offset") int offset, @Param("limit") int limit);
    
    /**
     * ID로 게시글 조회
     */
    Optional<Post> findById(@Param("id") int id);
    
    /**
     * 카테고리별 게시글 조회
     */
    List<Post> findByCategoryId(@Param("categoryId") int categoryId, 
                               @Param("offset") int offset, 
                               @Param("limit") int limit);
    
    /**
     * 작성자별 게시글 조회
     */
    List<Post> findByAuthorId(@Param("authorId") String authorId,
                             @Param("offset") int offset,
                             @Param("limit") int limit);
    
    /**
     * 키워드로 게시글 검색
     */
    List<Post> searchPosts(@Param("searchType") String searchType,
                          @Param("keyword") String keyword,
                          @Param("offset") int offset,
                          @Param("limit") int limit);
    
    /**
     * 인기 게시글 조회
     */
    List<Post> findPopularPosts(@Param("limit") int limit);
    
    /**
     * 최신 게시글 조회
     */
    List<Post> findRecentPosts(@Param("limit") int limit);
    
    /**
     * 공지사항 조회
     */
    List<Post> findNotices();
    
    /**
     * 고정 게시글 조회
     */
    List<Post> findPinnedPosts();
    
    /**
     * 게시글 등록
     */
    int insertPost(Post post);
    
    /**
     * 게시글 수정
     */
    int updatePost(Post post);
    
    /**
     * 게시글 삭제
     */
    int deletePost(@Param("id") int id);
    
    /**
     * 조회수 증가
     */
    int updateViewCount(@Param("id") int id);
    
    /**
     * 조회수 1 증가
     */
    int incrementViewCount(@Param("id") int id);
    
    /**
     * 신고수 증가
     * Model1: increaseReports(int id)
     */
    int updateReportCount(@Param("id") int id);
    
    /**
     * 좋아요 수 업데이트
     */
    int updateLikeCount(@Param("id") int id, @Param("likeCount") int likeCount);
    
    /**
     * 댓글 수 업데이트
     */
    int updateCommentCount(@Param("id") int id, @Param("commentCount") int commentCount);
    
    /**
     * 게시글 상태 변경
     */
    int updateStatus(@Param("id") int id, @Param("status") String status);
    
    /**
     * 공지사항 설정/해제
     */
    int updateNoticeStatus(@Param("id") int id, @Param("isNotice") boolean isNotice);
    
    /**
     * 고정 설정/해제
     */
    int updatePinnedStatus(@Param("id") int id, @Param("isPinned") boolean isPinned);
    
    /**
     * 전체 게시글 수
     */
    int countAll();
    
    /**
     * 카테고리별 게시글 수
     */
    int countByCategoryId(@Param("categoryId") int categoryId);
    
    /**
     * 검색 결과 수
     */
    int countSearchResults(@Param("searchType") String searchType, @Param("keyword") String keyword);
    
    /**
     * 작성자별 게시글 수
     */
    int countByAuthorId(@Param("authorId") String authorId);
    
    /**
     * 카테고리별 통계
     */
    List<Map<String, Object>> getCategoryStatistics();
    
    /**
     * 월별 게시글 통계
     */
    List<Map<String, Object>> getMonthlyStatistics();
    
    /**
     * 카테고리별 인기 게시글 조회 (좋아요 수 기준, 페이징)
     */
    List<Post> findPopularPostsByCategory(@Param("categoryId") int categoryId, 
                                         @Param("start") int start, 
                                         @Param("perPage") int perPage);
}
