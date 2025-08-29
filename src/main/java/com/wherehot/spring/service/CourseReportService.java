package com.wherehot.spring.service;

import com.wherehot.spring.entity.CourseReport;
import com.wherehot.spring.mapper.CourseReportMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CourseReportService {
    
    @Autowired
    private CourseReportMapper courseReportMapper;
    
    /**
     * 신고 저장
     */
    public boolean saveReport(CourseReport report) {
        try {
            int result = courseReportMapper.insertReport(report);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 코스 ID와 사용자 키로 신고 조회
     */
    public CourseReport getReportByCourseIdAndUserKey(int courseId, String userKey) {
        try {
            return courseReportMapper.selectReportByCourseIdAndUserKey(courseId, userKey);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * 코스 ID로 모든 신고 조회
     */
    public List<CourseReport> getReportsByCourseId(int courseId) {
        try {
            return courseReportMapper.selectReportsByCourseId(courseId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * 신고 상태 업데이트
     */
    public boolean updateReportStatus(int reportId, String status) {
        try {
            int result = courseReportMapper.updateReportStatus(reportId, status);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 신고 결과 업데이트
     */
    public boolean updateReportResult(int reportId, String result) {
        try {
            int resultCount = courseReportMapper.updateReportResult(reportId, result);
            return resultCount > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 모든 신고 조회 (관리자용)
     */
    public List<CourseReport> getAllReports() {
        try {
            return courseReportMapper.selectAllReports();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * 상태별 신고 조회
     */
    public List<CourseReport> getReportsByStatus(String status) {
        try {
            return courseReportMapper.selectReportsByStatus(status);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
