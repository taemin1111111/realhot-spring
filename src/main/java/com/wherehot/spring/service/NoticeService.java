package com.wherehot.spring.service;

import com.wherehot.spring.entity.Notice;
import java.util.List;

public interface NoticeService {
    
    // 공지사항 목록 조회 (PUBLIC 상태만)
    List<Notice> getPublicNotices();
    
    // 공지사항 상세 조회
    Notice getNoticeById(Long noticeId);
    
    // 공지사항 작성
    boolean createNotice(Notice notice);
    
    // 공지사항 수정
    boolean updateNotice(Notice notice);
    
    // 공지사항 삭제
    boolean deleteNotice(Long noticeId);
    
    // 조회수 증가
    void incrementViewCount(Long noticeId);
    
    // 전체 공지사항 개수 조회
    int getTotalNoticeCount();
}
