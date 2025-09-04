package com.wherehot.spring.service;

import java.util.Map;

/**
 * 마이페이지 관련 서비스 인터페이스
 */
public interface MypageService {
    
    /**
     * 사용자 위시리스트 조회
     */
    Map<String, Object> getUserWishlist(String userid, int page, int size);
    
    /**
     * 사용자가 작성한 게시글 조회 (전체)
     */
    Map<String, Object> getUserPosts(String userid, int page, int size);
    
    /**
     * 사용자가 작성한 course 게시글 조회
     */
    Map<String, Object> getUserCoursePosts(String userid, int page, int size);
    
    /**
     * 사용자가 작성한 hottalk 게시글 조회
     */
    Map<String, Object> getUserHottalkPosts(String userid, int page, int size);
    
    /**
     * 사용자가 작성한 댓글 조회
     */
    Map<String, Object> getUserComments(String userid, int page, int size);
    
    /**
     * 사용자 통계 정보 조회
     */
    Map<String, Object> getUserStats(String userid);
    
    /**
     * 사용자 정보 조회
     */
    com.wherehot.spring.entity.Member getUserInfo(String userid);
    
    /**
     * 사용자가 작성한 course 게시글 개수 조회
     */
    int getUserCourseCount(String userid);
    
    /**
     * 사용자가 작성한 hpost 게시글 개수 조회
     */
    int getUserHpostCount(String userid);
    
    /**
     * 사용자 프로필 정보 수정
     */
    boolean updateProfile(String userid, String nickname, String email);
    
    /**
     * 사용자 비밀번호 변경
     */
    boolean changePassword(String userid, String currentPassword, String newPassword);
    
    /**
     * 회원 탈퇴
     */
    boolean withdrawMember(String userid, String password);
    
    /**
     * 현재 비밀번호 확인
     */
    boolean verifyPassword(String userid, String password);
    
    /**
     * 찜 해제
     */
    boolean removeWish(String userid, Long wishId);
    
    /**
     * 사용자 MD 찜 목록 조회
     */
    Map<String, Object> getMdWishList(String userid, int page, int size);
    
    /**
     * MD 찜 해제
     */
    boolean removeMdWish(String userid, int wishId);
}
