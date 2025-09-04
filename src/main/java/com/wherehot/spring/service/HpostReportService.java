package com.wherehot.spring.service;

import com.wherehot.spring.entity.HpostReport;
import com.wherehot.spring.mapper.HpostReportMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HpostReportService {
    
    @Autowired
    private HpostReportMapper hpostReportMapper;
    
    /**
     * 신고 저장
     */
    public boolean saveReport(HpostReport report) {
        try {
            int result = hpostReportMapper.insertReport(report);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 게시글별 신고 목록 조회
     */
    public List<HpostReport> getReportsByPostId(Integer postId) {
        return hpostReportMapper.selectReportsByPostId(postId);
    }
    
    /**
     * 사용자별 신고 목록 조회
     */
    public List<HpostReport> getReportsByUserId(String userId) {
        return hpostReportMapper.selectReportsByUserId(userId);
    }
    
    /**
     * 전체 신고 목록 조회 (관리자용)
     */
    public List<HpostReport> getAllReports() {
        return hpostReportMapper.selectAllReports();
    }
    
    /**
     * 신고 상세 조회
     */
    public HpostReport getReportById(Integer id) {
        return hpostReportMapper.selectReportById(id);
    }
}
