package com.wherehot.spring.service;

import com.wherehot.spring.entity.Notice;

import java.util.List;
import java.util.Optional;

/**
 * 공지사항 서비스 인터페이스
 */
public interface NoticeService {
    
    List<Notice> findAllNotices(int page, int size);
    List<Notice> findActiveNotices(int page, int size);
    List<Notice> findPinnedNotices();
    Optional<Notice> findNoticeById(int id);
    List<Notice> findNoticesByAuthor(String authorId, int page, int size);
    List<Notice> searchNotices(String keyword, int page, int size);
    List<Notice> findRecentNotices(int limit);
    
    Notice saveNotice(Notice notice);
    Notice updateNotice(Notice notice);
    boolean deleteNotice(int id);
    boolean incrementViewCount(int id);
    boolean updatePinnedStatus(int id, boolean isPinned);
    boolean updateActiveStatus(int id, boolean isActive);
    
    int getTotalNoticeCount();
    int getActiveNoticeCount();
    int getSearchResultCount(String keyword);
    int getNoticeCountByAuthor(String authorId);
}
