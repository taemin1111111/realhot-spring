package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.CourseReport;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface CourseReportMapper {
    
    /**
     * 신고 저장
     */
    int insertReport(CourseReport report);
    
    /**
     * 코스 ID와 사용자 키로 신고 조회
     */
    CourseReport selectReportByCourseIdAndUserKey(@Param("courseId") int courseId, @Param("userKey") String userKey);
    
    /**
     * 코스 ID로 모든 신고 조회
     */
    List<CourseReport> selectReportsByCourseId(@Param("courseId") int courseId);
    
    /**
     * 신고 상태 업데이트
     */
    int updateReportStatus(@Param("id") int id, @Param("status") String status);
    
    /**
     * 신고 결과 업데이트
     */
    int updateReportResult(@Param("id") int id, @Param("result") String result);
    
    /**
     * 모든 신고 조회 (관리자용)
     */
    List<CourseReport> selectAllReports();
    
    /**
     * 상태별 신고 조회
     */
    List<CourseReport> selectReportsByStatus(@Param("status") String status);
    
    /**
     * 코스 ID로 모든 신고 삭제
     */
    int deleteReportsByCourseId(@Param("courseId") int courseId);
}
