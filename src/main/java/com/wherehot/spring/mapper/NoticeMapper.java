package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Notice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

/**
 * 공지사항 MyBatis Mapper
 */
@Mapper
public interface NoticeMapper {
    
    /**
     * 모든 공지사항 조회 (페이징)
     */
    List<Notice> findAll(@Param("offset") int offset, @Param("limit") int limit);
    
    /**
     * 활성 공지사항 조회
     */
    List<Notice> findActiveNotices(@Param("offset") int offset, @Param("limit") int limit);
    
    /**
     * 고정 공지사항 조회
     */
    List<Notice> findPinnedNotices();
    
    /**
     * ID로 공지사항 조회
     */
    Optional<Notice> findById(@Param("id") int id);
    
    /**
     * 작성자별 공지사항 조회
     */
    List<Notice> findByAuthorId(@Param("authorId") String authorId,
                               @Param("offset") int offset,
                               @Param("limit") int limit);
    
    /**
     * 키워드로 공지사항 검색
     */
    List<Notice> searchNotices(@Param("keyword") String keyword,
                              @Param("offset") int offset,
                              @Param("limit") int limit);
    
    /**
     * 최신 공지사항 조회
     */
    List<Notice> findRecentNotices(@Param("limit") int limit);
    
    /**
     * 공지사항 등록
     */
    int insertNotice(Notice notice);
    
    /**
     * 공지사항 수정
     */
    int updateNotice(Notice notice);
    
    /**
     * 공지사항 삭제 (비활성화)
     */
    int deleteNotice(@Param("id") int id);
    
    /**
     * 조회수 증가
     */
    int updateViewCount(@Param("id") int id);
    
    /**
     * 고정 설정/해제
     */
    int updatePinnedStatus(@Param("id") int id, @Param("isPinned") boolean isPinned);
    
    /**
     * 활성/비활성 설정
     */
    int updateActiveStatus(@Param("id") int id, @Param("isActive") boolean isActive);
    
    /**
     * 전체 공지사항 수
     */
    int countAll();
    
    /**
     * 활성 공지사항 수
     */
    int countActive();
    
    /**
     * 검색 결과 수
     */
    int countSearchResults(@Param("keyword") String keyword);
    
    /**
     * 작성자별 공지사항 수
     */
    int countByAuthorId(@Param("authorId") String authorId);
}
