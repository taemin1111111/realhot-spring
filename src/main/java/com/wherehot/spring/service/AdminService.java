package com.wherehot.spring.service;

import com.wherehot.spring.mapper.AdminMapper;
import com.wherehot.spring.mapper.HpostMapper;
import com.wherehot.spring.mapper.HcommentMapper;
import com.wherehot.spring.mapper.HpostVoteMapper;
import com.wherehot.spring.mapper.HpostReportMapper;
import com.wherehot.spring.mapper.CourseMapper;
import com.wherehot.spring.mapper.CourseStepMapper;
import com.wherehot.spring.mapper.CourseCommentMapper;
import com.wherehot.spring.mapper.CourseCommentReactionMapper;
import com.wherehot.spring.mapper.CourseReactionMapper;
import com.wherehot.spring.mapper.CourseReportMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * 관리자 기능을 위한 서비스
 */
@Service
public class AdminService {
    
    @Autowired
    private AdminMapper adminMapper;
    
    @Autowired
    private HpostMapper hpostMapper;
    
    @Autowired
    private HcommentMapper hcommentMapper;
    
    @Autowired
    private HpostVoteMapper hpostVoteMapper;
    
    @Autowired
    private HpostReportMapper hpostReportMapper;
    
    @Autowired
    private CourseMapper courseMapper;
    
    @Autowired
    private CourseStepMapper courseStepMapper;
    
    @Autowired
    private CourseCommentMapper courseCommentMapper;
    
    @Autowired
    private CourseCommentReactionMapper courseCommentReactionMapper;
    
    @Autowired
    private CourseReactionMapper courseReactionMapper;
    
    @Autowired
    private CourseReportMapper courseReportMapper;
    
    /**
     * 신고된 게시물 목록 조회 (신고 개수 순)
     */
    public List<Map<String, Object>> getReportedPostsByReportCount() {
        return adminMapper.getReportedPostsByReportCount();
    }
    
    /**
     * 신고된 게시물 목록 조회 (최신 신고 순)
     */
    public List<Map<String, Object>> getReportedPostsByLatestReport() {
        return adminMapper.getReportedPostsByLatestReport();
    }
    
    /**
     * 특정 게시물의 신고 상세 정보 조회
     */
    public List<Map<String, Object>> getReportDetailsByPostId(int postId) {
        return adminMapper.getReportDetailsByPostId(postId);
    }
    
    /**
     * 게시물별 신고 개수 조회
     */
    public int getReportCountByPostId(int postId) {
        return adminMapper.getReportCountByPostId(postId);
    }
    
    /**
     * 관리자용 게시물 완전 삭제 (연관된 모든 데이터 포함)
     */
    @Transactional
    public boolean deleteHpostWithAllRelatedData(int postId) {
        try {
            // 1. 댓글 삭제
            hcommentMapper.deleteCommentsByPostId(postId);
            
            // 2. 투표 삭제
            hpostVoteMapper.deleteVotesByPostId(postId);
            
            // 3. 게시물 삭제
            int result = hpostMapper.deleteHpost(postId);
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 신고 데이터 삭제 (알림 전송 후 별도로 실행)
     */
    @Transactional
    public void deleteReportsByPostId(int postId) {
        hpostReportMapper.deleteReportsByPostId(postId);
    }
    
    // ========== 코스 관련 관리자 기능 ==========
    
    /**
     * 신고된 코스 목록 조회 (신고 개수 순)
     */
    public List<Map<String, Object>> getReportedCoursesByReportCount() {
        return adminMapper.getReportedCoursesByReportCount();
    }
    
    /**
     * 신고된 코스 목록 조회 (최신 신고 순)
     */
    public List<Map<String, Object>> getReportedCoursesByLatestReport() {
        return adminMapper.getReportedCoursesByLatestReport();
    }
    
    /**
     * 특정 코스의 신고 상세 정보 조회
     */
    public List<Map<String, Object>> getCourseReportDetailsByCourseId(int courseId) {
        return adminMapper.getCourseReportDetailsByCourseId(courseId);
    }
    
    /**
     * 코스별 신고 개수 조회
     */
    public int getCourseReportCountByCourseId(int courseId) {
        return adminMapper.getCourseReportCountByCourseId(courseId);
    }
    
    /**
     * 관리자용 코스 완전 삭제 (연관된 모든 데이터 포함)
     */
    @Transactional
    public boolean deleteCourseWithAllRelatedData(int courseId) {
        try {
            // 1. 코스 댓글 삭제
            courseCommentMapper.deleteAllCommentsByCourseId(courseId);
            
            // 2. 코스 반응 삭제
            courseReactionMapper.deleteAllReactionsByCourseId(courseId);
            
            // 3. 코스 스텝 삭제
            courseStepMapper.deleteAllCourseStepsByCourseId(courseId);
            
            // 4. 코스 삭제
            int result = courseMapper.deleteCourse(courseId);
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 코스 신고 데이터 삭제 (알림 전송 후 별도로 실행)
     */
    @Transactional
    public void deleteCourseReportsByCourseId(int courseId) {
        courseReportMapper.deleteReportsByCourseId(courseId);
    }
}
