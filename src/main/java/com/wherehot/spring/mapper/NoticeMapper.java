package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Notice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeMapper {
    
    // PUBLIC 상태의 공지사항 목록 조회
    List<Notice> findPublicNotices();
    
    // ID로 공지사항 조회
    Notice findById(@Param("noticeId") Long noticeId);
    
    // 공지사항 작성
    int insert(Notice notice);
    
    // 공지사항 수정
    int update(Notice notice);
    
    // 공지사항 삭제 (상태를 DELETED로 변경)
    int delete(@Param("noticeId") Long noticeId);
    
    // 조회수 증가
    int incrementViewCount(@Param("noticeId") Long noticeId);
    
    // PUBLIC 상태 공지사항 개수 조회
    int countPublicNotices();
    
    // 전체 공지사항 개수 조회
    int countAllNotices();
    
    // 관리자용: 모든 공지사항 조회 (삭제된 것 제외)
    List<Notice> findAllForAdmin();
    
    // 관리자용: 특정 상태의 공지사항 조회
    List<Notice> findByStatus(@Param("status") String status);
    
    // 공지사항 고정/고정취소
    int togglePinned(@Param("noticeId") Long noticeId, @Param("isPinned") Boolean isPinned);
}
