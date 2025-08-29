package com.wherehot.spring.service;

import com.wherehot.spring.entity.CourseComment;
import com.wherehot.spring.mapper.CourseCommentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.util.List;

@Service
public class CourseCommentService {
    
    @Autowired
    private CourseCommentMapper courseCommentMapper;
    
    /**
     * 코스의 모든 댓글 조회 (계층 구조)
     */
    public List<CourseComment> getCommentsByCourseId(int courseId) {
        return courseCommentMapper.getCommentsByCourseId(courseId);
    }
    
    /**
     * 코스의 부모 댓글만 조회
     */
    public List<CourseComment> getParentCommentsByCourseId(int courseId) {
        return courseCommentMapper.getParentCommentsByCourseId(courseId);
    }
    
    /**
     * 코스의 부모 댓글만 조회 (현재 사용자의 리액션 상태 포함)
     */
    public List<CourseComment> getParentCommentsByCourseIdWithUserReaction(int courseId, String userKey) {
        return courseCommentMapper.getParentCommentsByCourseIdWithUserReaction(courseId, userKey);
    }
    
    /**
     * 댓글 등록
     */
    @Transactional
    public int createComment(CourseComment courseComment) {
        // 컨트롤러에서 이미 해시화된 비밀번호를 받으므로 추가 해시화하지 않음
        return courseCommentMapper.insertCourseComment(courseComment);
    }
    
    /**
     * 댓글 수정
     */
    @Transactional
    public int updateComment(CourseComment courseComment) {
        return courseCommentMapper.updateCourseComment(courseComment);
    }
    
    /**
     * 댓글 삭제 (soft delete)
     */
    @Transactional
    public int deleteComment(int id) {
        return courseCommentMapper.deleteCourseComment(id);
    }
    
    /**
     * 특정 댓글 조회
     */
    public CourseComment getCommentById(int id) {
        return courseCommentMapper.getCourseCommentById(id);
    }
    
    /**
     * 코스의 댓글 개수 조회
     */
    public int getCommentCountByCourseId(int courseId) {
        return courseCommentMapper.getCommentCountByCourseId(courseId);
    }
    
    /**
     * 부모 댓글의 대댓글 개수 조회
     */
    public int getReplyCountByParentId(int parentId) {
        return courseCommentMapper.getReplyCountByParentId(parentId);
    }
    
    /**
     * 부모 댓글의 대댓글 목록 조회
     */
    public List<CourseComment> getRepliesByParentId(int parentId) {
        return courseCommentMapper.getRepliesByParentId(parentId);
    }
    
    /**
     * 부모 댓글의 대댓글 목록 조회 (현재 사용자의 리액션 상태 포함)
     */
    public List<CourseComment> getRepliesByParentIdWithUserReaction(int parentId, String userKey) {
        return courseCommentMapper.getRepliesByParentIdWithUserReaction(parentId, userKey);
    }
    

    
    /**
     * 댓글과 관련된 모든 데이터 삭제 (댓글, 대댓글, 리액션)
     */
    @Transactional
    public boolean deleteCommentWithAllData(int commentId) {
        try {
            // 1. 해당 댓글의 모든 대댓글 삭제
            courseCommentMapper.deleteRepliesByParentId(commentId);
            
            // 2. 해당 댓글과 관련된 모든 리액션 삭제
            courseCommentMapper.deleteReactionsByCommentId(commentId);
            
            // 3. 해당 댓글 삭제
            int result = courseCommentMapper.deleteCourseComment(commentId);
            
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
