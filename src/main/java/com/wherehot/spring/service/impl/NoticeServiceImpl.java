package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Notice;
import com.wherehot.spring.mapper.NoticeMapper;
import com.wherehot.spring.service.NoticeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NoticeServiceImpl implements NoticeService {
    
    @Autowired
    private NoticeMapper noticeMapper;
    
    @Override
    public List<Notice> getPublicNotices() {
        return noticeMapper.findPublicNotices();
    }
    
    @Override
    public Notice getNoticeById(Long noticeId) {
        return noticeMapper.findById(noticeId);
    }
    
    @Override
    public boolean createNotice(Notice notice) {
        int result = noticeMapper.insert(notice);
        return result > 0;
    }
    
    @Override
    public boolean updateNotice(Notice notice) {
        int result = noticeMapper.update(notice);
        return result > 0;
    }
    
    @Override
    public boolean deleteNotice(Long noticeId) {
        int result = noticeMapper.delete(noticeId);
        return result > 0;
    }
    
    @Override
    public void incrementViewCount(Long noticeId) {
        noticeMapper.incrementViewCount(noticeId);
    }
    
    @Override
    public int getTotalNoticeCount() {
        return noticeMapper.countPublicNotices();
    }
    
    @Override
    public boolean togglePinned(Long noticeId, Boolean isPinned) {
        int result = noticeMapper.togglePinned(noticeId, isPinned);
        return result > 0;
    }
}
