package com.wherehot.spring.service;

import com.wherehot.spring.entity.PostReport;

import java.util.List;
import java.util.Optional;

/**
 * 게시글 신고 서비스 인터페이스
 * Model1 Hottalk_ReportDao 기능을 Spring Service로 변환
 */
public interface PostReportService {
    
    /**
     * 신고 추가
     * Model1: insertReport(Hottalk_ReportDto dto)
     */
    PostReport createReport(PostReport postReport);
    
    /**
     * 특정 글의 신고 목록 조회
     * Model1: getReportsByPostId(int postId)
     */
    List<PostReport> findReportsByPostId(int postId);
    
    /**
     * 전체 신고 목록 조회
     * Model1: getAllReports()
     */
    List<PostReport> findAllReports();
    
    /**
     * 전체 신고 목록 조회 (게시글 정보 포함) - 관리자용
     */
    List<PostReport> findAllReportsWithPostInfo();
    
    /**
     * 페이징을 위한 신고 목록 조회 (게시글 정보 포함)
     */
    List<PostReport> findAllReportsWithPostInfoPaged(int page, int pageSize);
    
    /**
     * 특정 신고 조회
     * Model1: getReportById(int id)
     */
    Optional<PostReport> findReportById(int id);
    
    /**
     * 신고 삭제
     * Model1: deleteReport(int id)
     */
    boolean deleteReport(int id);
    
    /**
     * 특정 글의 신고 개수 조회
     * Model1: getReportCountByPostId(int postId)
     */
    int getReportCountByPostId(int postId);
    
    /**
     * 특정 글에 대해 해당 user_id가 이미 신고했는지 확인
     * Model1: hasUserReported(int postId, String userId)
     */
    boolean hasUserReported(int postId, String userId);
    
    /**
     * 신고된 게시물 ID 목록 조회 (중복 제거)
     * Model1: getReportedPostIds()
     */
    List<Integer> getReportedPostIds();
    
    /**
     * 특정 사용자의 신고 목록 조회
     */
    List<PostReport> findReportsByUserId(String userId);
    
    /**
     * 신고 처리 상태 업데이트
     */
    boolean updateReportStatus(int id, String status);
    
    /**
     * 전체 신고 개수 조회
     */
    int getTotalReportCount();
    
    /**
     * 총 페이지 수 계산
     */
    int getTotalPages(int pageSize);
}
