package com.wherehot.spring.service;

import com.wherehot.spring.entity.CourseComment;
import com.wherehot.spring.mapper.CourseCommentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
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
        // 비밀번호 해시화 (비로그인 사용자의 경우)
        if (courseComment.getPasswdHash() != null && !courseComment.getPasswdHash().isEmpty()) {
            courseComment.setPasswdHash(hashPassword(courseComment.getPasswdHash()));
        }
        
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
     * 비밀번호 해시화 (SHA-256)
     */
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 알고리즘을 찾을 수 없습니다.", e);
        }
    }
    
    /**
     * 비밀번호 검증 (비로그인 사용자용)
     */
    public boolean verifyPassword(int commentId, String password) {
        CourseComment comment = getCommentById(commentId);
        if (comment == null) {
            return false;
        }
        
        String hashedPassword = hashPassword(password);
        return hashedPassword.equals(comment.getPasswdHash());
    }
}
