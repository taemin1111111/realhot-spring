package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Notice;
import com.wherehot.spring.mapper.NoticeMapper;
import com.wherehot.spring.service.NoticeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class NoticeServiceImpl implements NoticeService {
    
    private static final Logger logger = LoggerFactory.getLogger(NoticeServiceImpl.class);
    
    @Autowired
    private NoticeMapper noticeMapper;
    
    @Override
    @Transactional(readOnly = true)
    public List<Notice> findAllNotices(int page, int size) {
        try {
            int offset = (page - 1) * size;
            return noticeMapper.findAll(offset, size);
        } catch (Exception e) {
            logger.error("Error finding all notices", e);
            throw new RuntimeException("공지사항 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Notice> findActiveNotices(int page, int size) {
        try {
            int offset = (page - 1) * size;
            return noticeMapper.findActiveNotices(offset, size);
        } catch (Exception e) {
            logger.error("Error finding active notices", e);
            throw new RuntimeException("활성 공지사항 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Notice> findPinnedNotices() {
        try {
            return noticeMapper.findPinnedNotices();
        } catch (Exception e) {
            logger.error("Error finding pinned notices", e);
            throw new RuntimeException("고정 공지사항 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Notice> findNoticeById(int id) {
        try {
            return noticeMapper.findById(id);
        } catch (Exception e) {
            logger.error("Error finding notice by id: {}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Notice> findNoticesByAuthor(String authorId, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return noticeMapper.findByAuthorId(authorId, offset, size);
        } catch (Exception e) {
            logger.error("Error finding notices by author: {}", authorId, e);
            throw new RuntimeException("작성자별 공지사항 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Notice> searchNotices(String keyword, int page, int size) {
        try {
            int offset = (page - 1) * size;
            return noticeMapper.searchNotices(keyword, offset, size);
        } catch (Exception e) {
            logger.error("Error searching notices with keyword: {}", keyword, e);
            throw new RuntimeException("공지사항 검색 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Notice> findRecentNotices(int limit) {
        try {
            return noticeMapper.findRecentNotices(limit);
        } catch (Exception e) {
            logger.error("Error finding recent notices", e);
            throw new RuntimeException("최신 공지사항 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Notice saveNotice(Notice notice) {
        try {
            notice.setCreatedAt(LocalDateTime.now());
            notice.setUpdatedAt(LocalDateTime.now());
            
            int result = noticeMapper.insertNotice(notice);
            if (result > 0) {
                logger.info("Notice saved successfully: {}", notice.getTitle());
                return notice;
            } else {
                throw new RuntimeException("공지사항 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving notice: {}", notice.getTitle(), e);
            throw new RuntimeException("공지사항 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Notice updateNotice(Notice notice) {
        try {
            Optional<Notice> existingNotice = noticeMapper.findById(notice.getNoticeId());
            if (existingNotice.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 공지사항입니다: " + notice.getNoticeId());
            }
            
            notice.setUpdatedAt(LocalDateTime.now());
            
            int result = noticeMapper.updateNotice(notice);
            if (result > 0) {
                logger.info("Notice updated successfully: {}", notice.getNoticeId());
                return notice;
            } else {
                throw new RuntimeException("공지사항 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating notice: {}", notice.getNoticeId(), e);
            throw new RuntimeException("공지사항 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean deleteNotice(int id) {
        try {
            Optional<Notice> notice = noticeMapper.findById(id);
            if (notice.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 공지사항입니다: " + id);
            }
            
            int result = noticeMapper.deleteNotice(id);
            if (result > 0) {
                logger.info("Notice deleted successfully: {}", id);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting notice: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean incrementViewCount(int id) {
        try {
            int result = noticeMapper.updateViewCount(id);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error incrementing view count: {}", id, e);
            return false;
        }
    }
    
    @Override
    public boolean updatePinnedStatus(int id, boolean isPinned) {
        try {
            int result = noticeMapper.updatePinnedStatus(id, isPinned);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating pinned status: id={}, isPinned={}", id, isPinned, e);
            return false;
        }
    }
    
    @Override
    public boolean updateActiveStatus(int id, boolean isActive) {
        try {
            int result = noticeMapper.updateActiveStatus(id, isActive);
            return result > 0;
        } catch (Exception e) {
            logger.error("Error updating active status: id={}, isActive={}", id, isActive, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getTotalNoticeCount() {
        try {
            return noticeMapper.countAll();
        } catch (Exception e) {
            logger.error("Error getting total notice count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getActiveNoticeCount() {
        try {
            return noticeMapper.countActive();
        } catch (Exception e) {
            logger.error("Error getting active notice count", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getSearchResultCount(String keyword) {
        try {
            return noticeMapper.countSearchResults(keyword);
        } catch (Exception e) {
            logger.error("Error getting search result count: {}", keyword, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getNoticeCountByAuthor(String authorId) {
        try {
            return noticeMapper.countByAuthorId(authorId);
        } catch (Exception e) {
            logger.error("Error getting notice count by author: {}", authorId, e);
            return 0;
        }
    }
}
