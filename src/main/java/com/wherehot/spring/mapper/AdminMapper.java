package com.wherehot.spring.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 관리자 기능을 위한 Mapper
 */
@Mapper
public interface AdminMapper {
    
    /**
     * 신고된 게시물 목록 조회 (신고 개수 순)
     */
    List<Map<String, Object>> getReportedPostsByReportCount();
    
    /**
     * 신고된 게시물 목록 조회 (최신 신고 순)
     */
    List<Map<String, Object>> getReportedPostsByLatestReport();
    
    /**
     * 특정 게시물의 신고 상세 정보 조회
     */
    List<Map<String, Object>> getReportDetailsByPostId(@Param("postId") int postId);
    
    /**
     * 게시물별 신고 개수 조회
     */
    int getReportCountByPostId(@Param("postId") int postId);
    
    // ========== 코스 관련 관리자 기능 ==========
    
    /**
     * 신고된 코스 목록 조회 (신고 개수 순)
     */
    List<Map<String, Object>> getReportedCoursesByReportCount();
    
    /**
     * 신고된 코스 목록 조회 (최신 신고 순)
     */
    List<Map<String, Object>> getReportedCoursesByLatestReport();
    
    /**
     * 특정 코스의 신고 상세 정보 조회
     */
    List<Map<String, Object>> getCourseReportDetailsByCourseId(@Param("courseId") int courseId);
    
    /**
     * 코스별 신고 개수 조회
     */
    int getCourseReportCountByCourseId(@Param("courseId") int courseId);
}
