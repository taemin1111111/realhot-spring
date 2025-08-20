package com.wherehot.spring.service;

import com.wherehot.spring.entity.Member;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 회원 서비스 인터페이스
 */
public interface MemberService {
    
    /**
     * 회원 정보 조회 (ID로) - Optional 반환
     */
    Optional<Member> findByUseridOptional(String userid);
    
    /**
     * 회원 정보 조회 (ID로) - null 허용
     */
    Member findByUserid(String userid);
    
    /**
     * 회원 정보 조회 (이메일로)
     */
    Optional<Member> findByEmail(String email);
    
    /**
     * 회원 정보 조회 (닉네임으로)
     */
    Optional<Member> findByNickname(String nickname);
    
    /**
     * 회원 등록
     */
    Member saveMember(Member member);
    
    /**
     * 회원 정보 수정
     */
    Member updateMember(Member member);
    
    /**
     * 비밀번호 변경
     */
    boolean updatePassword(String userid, String oldPassword, String newPassword);
    
    /**
     * 비밀번호 재설정 (관리자용)
     */
    boolean resetPassword(String userid, String newPassword);
    
    /**
     * 회원 상태 변경
     */
    boolean updateMemberStatus(String userid, String status);
    
    /**
     * 회원 탈퇴
     */
    boolean deleteMember(String userid);
    
    /**
     * 로그인 정보 업데이트
     */
    void updateLoginInfo(String userid);
    
    /**
     * 전체 회원 목록 조회 (페이징)
     */
    List<Member> findAllMembers(int page, int size);
    
    /**
     * 회원 수 조회
     */
    int countMembers();
    
    /**
     * 활성 회원 수 조회
     */
    int countActiveMembers();
    
    /**
     * 소셜 로그인 회원 목록 조회
     */
    List<Member> findByProvider(String provider);
    
    /**
     * 회원 검색 (닉네임, 이메일로)
     */
    List<Member> searchMembers(String keyword, String provider, String status, int page, int size);
    
    /**
     * 회원 검색 결과 수
     */
    int countSearchMembers(String keyword, String provider, String status);
    
    /**
     * 프로필 이미지 업데이트 (현재 비활성화 - 해당 컬럼이 없음)
     */
    boolean updateProfileImage(String userid, String profileImageUrl);
    
    /**
     * 최근 가입한 회원 조회
     */
    List<Member> findRecentMembers(int limit);
    
    /**
     * 최근 로그인한 회원 조회
     */
    List<Member> findRecentLoginMembers(int limit);
    
    /**
     * 휴면 회원 조회
     */
    List<Member> findDormantMembers(int days, int page, int size);
    
    /**
     * 휴면 회원 수 조회
     */
    int countDormantMembers(int days);
    
    /**
     * 생일인 회원 조회
     */
    List<Member> findBirthdayMembers();
    
    /**
     * 회원 통계 조회
     */
    Map<String, Object> getMemberStatistics();
    
    /**
     * 월별 가입자 수 통계
     */
    List<Map<String, Object>> getMemberStatsByMonth();
    
    /**
     * 제공자별 회원 수 통계
     */
    List<Map<String, Object>> getMemberStatsByProvider();
    
    /**
     * 성별 통계
     */
    List<Map<String, Object>> getMemberStatsByGender();
    
    /**
     * 연령대별 통계
     */
    List<Map<String, Object>> getMemberStatsByAge();
}
