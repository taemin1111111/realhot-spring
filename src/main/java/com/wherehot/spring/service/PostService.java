package com.wherehot.spring.service;

import com.wherehot.spring.entity.Post;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 게시글 서비스 인터페이스
 */
public interface PostService {
    
    /**
     * 모든 게시글 조회 (페이징)
     */
    List<Post> findAllPosts(int page, int size);
    
    /**
     * ID로 게시글 조회
     */
    Optional<Post> findPostById(int id);
    
    /**
     * ID로 게시글 조회 - null 허용
     */
    Post findById(int id);
    
    /**
     * 카테고리별 게시글 조회
     */
    List<Post> findPostsByCategory(int categoryId, int page, int size);
    
    /**
     * 작성자별 게시글 조회
     */
    List<Post> findPostsByAuthor(String authorId, int page, int size);
    
    /**
     * 키워드로 게시글 검색
     */
    List<Post> searchPosts(String searchType, String keyword, int page, int size);
    
    /**
     * 인기 게시글 조회
     */
    List<Post> findPopularPosts(int limit);
    
    /**
     * 최신 게시글 조회
     */
    List<Post> findRecentPosts(int limit);
    
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
    Post savePost(Post post);
    
    /**
     * 게시글 수정
     */
    Post updatePost(Post post);
    
    /**
     * 게시글 삭제
     */
    boolean deletePost(int id);
    
    /**
     * 조회수 증가
     */
    boolean incrementViewCount(int id);
    
    /**
     * 신고수 증가
     * Model1: increaseReports(int id)
     */
    boolean incrementReportCount(int id);
    
    /**
     * 좋아요 수 업데이트
     */
    boolean updateLikeCount(int id, int likeCount);
    
    /**
     * 댓글 수 업데이트
     */
    boolean updateCommentCount(int id, int commentCount);
    
    /**
     * 게시글 상태 변경
     */
    boolean updatePostStatus(int id, String status);
    
    /**
     * 공지사항 설정/해제
     */
    boolean updateNoticeStatus(int id, boolean isNotice);
    
    /**
     * 고정 설정/해제
     */
    boolean updatePinnedStatus(int id, boolean isPinned);
    
    /**
     * 전체 게시글 수
     */
    int getTotalPostCount();
    
    /**
     * 카테고리별 게시글 수
     */
    int getPostCountByCategory(int categoryId);
    
    /**
     * 검색 결과 수
     */
    int getSearchResultCount(String searchType, String keyword);
    
    /**
     * 작성자별 게시글 수
     */
    int getPostCountByAuthor(String authorId);
    
    /**
     * 카테고리별 통계
     */
    List<Map<String, Object>> getCategoryStatistics();
    
    /**
     * 월별 게시글 통계
     */
    List<Map<String, Object>> getMonthlyStatistics();
    
    /**
     * 카테고리별 인기 게시글 조회 (좋아요 수 기준)
     */
    List<Post> findPopularPostsByCategory(int categoryId, int start, int perPage);
    
    /**
     * 게시글 조회 및 조회수 증가
     */
    Post findPostByIdAndIncrementViews(int id);
}
