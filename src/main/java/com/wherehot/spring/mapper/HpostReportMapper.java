package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.HpostReport;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface HpostReportMapper {
    
    /**
     * 신고 저장
     */
    int insertReport(HpostReport report);
    
    /**
     * 게시글별 신고 목록 조회
     */
    List<HpostReport> selectReportsByPostId(@Param("postId") Integer postId);
    
    /**
     * 사용자별 신고 목록 조회
     */
    List<HpostReport> selectReportsByUserId(@Param("userId") String userId);
    
    /**
     * 전체 신고 목록 조회 (관리자용)
     */
    List<HpostReport> selectAllReports();
    
    /**
     * 신고 상세 조회
     */
    HpostReport selectReportById(@Param("id") Integer id);
    
    /**
     * 게시글의 모든 신고 삭제
     */
    void deleteReportsByPostId(@Param("postId") int postId);
}
