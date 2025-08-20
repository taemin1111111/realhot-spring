package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.PostReport;
import com.wherehot.spring.mapper.PostReportMapper;
import com.wherehot.spring.service.PostReportService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 게시글 신고 서비스 구현체
 * Model1 Hottalk_ReportDao 기능을 Spring Service로 변환
 */
@Service
@Transactional
public class PostReportServiceImpl implements PostReportService {
    
    private static final Logger logger = LoggerFactory.getLogger(PostReportServiceImpl.class);
    
    @Autowired
    private PostReportMapper postReportMapper;
    
    @Override
    @CacheEvict(value = {"reportList", "reportCount"}, allEntries = true)
    public PostReport createReport(PostReport postReport) {
        try {
            logger.debug("게시글 신고 등록 시작: postId={}, userId={}, reason={}", 
                        postReport.getPost_id(), postReport.getUser_id(), postReport.getReason());
            
            // 중복 신고 확인
            if (hasUserReported(postReport.getPost_id(), postReport.getUser_id())) {
                throw new RuntimeException("이미 신고한 게시글입니다.");
            }
            
            postReport.setReportTime(LocalDateTime.now());
            
            int result = postReportMapper.insertReport(postReport);
            if (result > 0) {
                logger.info("게시글 신고 등록 성공: reportId={}, postId={}, userId={}", 
                          postReport.getId(), postReport.getPost_id(), postReport.getUser_id());
                return postReport;
            } else {
                throw new RuntimeException("게시글 신고 등록에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("게시글 신고 등록 중 오류 발생: postId={}, userId={}", 
                        postReport.getPost_id(), postReport.getUser_id(), e);
            throw new RuntimeException("게시글 신고 등록에 실패했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<PostReport> findReportsByPostId(int postId) {
        try {
            logger.debug("게시글별 신고 목록 조회 시작: postId={}", postId);
            List<PostReport> reports = postReportMapper.findByPostId(postId);
            logger.info("게시글별 신고 목록 조회 완료: postId={}, count={}", postId, reports.size());
            return reports;
        } catch (Exception e) {
            logger.error("게시글별 신고 목록 조회 중 오류 발생: postId={}", postId, e);
            throw new RuntimeException("신고 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Cacheable(value = "reportList", key = "'all'")
    @Transactional(readOnly = true)
    public List<PostReport> findAllReports() {
        try {
            logger.debug("전체 신고 목록 조회 시작");
            List<PostReport> reports = postReportMapper.findAll();
            logger.info("전체 신고 목록 조회 완료: count={}", reports.size());
            return reports;
        } catch (Exception e) {
            logger.error("전체 신고 목록 조회 중 오류 발생", e);
            throw new RuntimeException("신고 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Cacheable(value = "reportListWithPost", key = "'all'")
    @Transactional(readOnly = true)
    public List<PostReport> findAllReportsWithPostInfo() {
        try {
            logger.debug("전체 신고 목록 조회 시작 (게시글 정보 포함)");
            List<PostReport> reports = postReportMapper.findAllWithPostInfo();
            logger.info("전체 신고 목록 조회 완료 (게시글 정보 포함): count={}", reports.size());
            return reports;
        } catch (Exception e) {
            logger.error("전체 신고 목록 조회 중 오류 발생 (게시글 정보 포함)", e);
            throw new RuntimeException("신고 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<PostReport> findAllReportsWithPostInfoPaged(int page, int pageSize) {
        try {
            logger.debug("페이징 신고 목록 조회 시작: page={}, pageSize={}", page, pageSize);
            
            int offset = (page - 1) * pageSize;
            List<PostReport> reports = postReportMapper.findAllWithPostInfoPaged(pageSize, offset);
            
            logger.info("페이징 신고 목록 조회 완료: page={}, count={}", page, reports.size());
            return reports;
        } catch (Exception e) {
            logger.error("페이징 신고 목록 조회 중 오류 발생: page={}", page, e);
            throw new RuntimeException("신고 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<PostReport> findReportById(int id) {
        try {
            logger.debug("신고 정보 조회 시작: reportId={}", id);
            Optional<PostReport> report = postReportMapper.findById(id);
            
            if (report.isPresent()) {
                logger.info("신고 정보 조회 성공: reportId={}", id);
            } else {
                logger.warn("신고 정보를 찾을 수 없음: reportId={}", id);
            }
            
            return report;
        } catch (Exception e) {
            logger.error("신고 정보 조회 중 오류 발생: reportId={}", id, e);
            return Optional.empty();
        }
    }
    
    @Override
    @CacheEvict(value = {"reportList", "reportListWithPost", "reportCount"}, allEntries = true)
    public boolean deleteReport(int id) {
        try {
            logger.debug("신고 삭제 시작: reportId={}", id);
            
            int result = postReportMapper.deleteReport(id);
            boolean success = result > 0;
            
            if (success) {
                logger.info("신고 삭제 성공: reportId={}", id);
            } else {
                logger.warn("신고 삭제 실패: reportId={}", id);
            }
            
            return success;
        } catch (Exception e) {
            logger.error("신고 삭제 중 오류 발생: reportId={}", id, e);
            return false;
        }
    }
    
    @Override
    @Cacheable(value = "reportCount", key = "'post_' + #postId")
    @Transactional(readOnly = true)
    public int getReportCountByPostId(int postId) {
        try {
            logger.debug("게시글별 신고 개수 조회 시작: postId={}", postId);
            int count = postReportMapper.countByPostId(postId);
            logger.debug("게시글별 신고 개수: postId={}, count={}", postId, count);
            return count;
        } catch (Exception e) {
            logger.error("게시글별 신고 개수 조회 중 오류 발생: postId={}", postId, e);
            return 0;
        }
    }
    
    @Override
    @Cacheable(value = "reportExists", key = "#postId + '_' + #userId")
    @Transactional(readOnly = true)
    public boolean hasUserReported(int postId, String userId) {
        try {
            logger.debug("사용자 신고 여부 확인 시작: postId={}, userId={}", postId, userId);
            
            int count = postReportMapper.countByPostIdAndUserId(postId, userId);
            boolean hasReported = count > 0;
            
            logger.debug("사용자 신고 여부 확인 결과: postId={}, userId={}, hasReported={}", 
                        postId, userId, hasReported);
            return hasReported;
        } catch (Exception e) {
            logger.error("사용자 신고 여부 확인 중 오류 발생: postId={}, userId={}", postId, userId, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Integer> getReportedPostIds() {
        try {
            logger.debug("신고된 게시물 ID 목록 조회 시작");
            List<Integer> postIds = postReportMapper.findReportedPostIds();
            logger.info("신고된 게시물 ID 목록 조회 완료: count={}", postIds.size());
            return postIds;
        } catch (Exception e) {
            logger.error("신고된 게시물 ID 목록 조회 중 오류 발생", e);
            throw new RuntimeException("신고된 게시물 ID 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<PostReport> findReportsByUserId(String userId) {
        try {
            logger.debug("사용자별 신고 목록 조회 시작: userId={}", userId);
            List<PostReport> reports = postReportMapper.findByUserId(userId);
            logger.info("사용자별 신고 목록 조회 완료: userId={}, count={}", userId, reports.size());
            return reports;
        } catch (Exception e) {
            logger.error("사용자별 신고 목록 조회 중 오류 발생: userId={}", userId, e);
            throw new RuntimeException("신고 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @CacheEvict(value = {"reportList", "reportListWithPost"}, allEntries = true)
    public boolean updateReportStatus(int id, String status) {
        try {
            logger.debug("신고 처리 상태 업데이트 시작: reportId={}, status={}", id, status);
            
            int result = postReportMapper.updateReportStatus(id, status);
            boolean success = result > 0;
            
            if (success) {
                logger.info("신고 처리 상태 업데이트 성공: reportId={}, status={}", id, status);
            } else {
                logger.warn("신고 처리 상태 업데이트 실패: reportId={}", id);
            }
            
            return success;
        } catch (Exception e) {
            logger.error("신고 처리 상태 업데이트 중 오류 발생: reportId={}", id, e);
            return false;
        }
    }
    
    @Override
    @Cacheable(value = "reportCount", key = "'total'")
    @Transactional(readOnly = true)
    public int getTotalReportCount() {
        try {
            logger.debug("전체 신고 개수 조회 시작");
            int count = postReportMapper.countAll();
            logger.debug("전체 신고 개수: {}", count);
            return count;
        } catch (Exception e) {
            logger.error("전체 신고 개수 조회 중 오류 발생", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getTotalPages(int pageSize) {
        try {
            int totalCount = getTotalReportCount();
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            logger.debug("총 페이지 수 계산: totalCount={}, pageSize={}, totalPages={}", 
                        totalCount, pageSize, totalPages);
            return totalPages;
        } catch (Exception e) {
            logger.error("총 페이지 수 계산 중 오류 발생", e);
            return 1; // 기본값
        }
    }
}
