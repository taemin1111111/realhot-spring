package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Member;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 회원 MyBatis Mapper (XML 방식)
 */
@Mapper
public interface MemberMapper {
    
    // ========== 기본 CRUD ==========
    
    /**
     * 회원 정보 조회 (ID로)
     */
    Optional<Member> findByUserid(@Param("userid") String userid);
    
    /**
     * 회원 정보 조회 (이메일로)
     */
    Optional<Member> findByEmail(@Param("email") String email);
    
    /**
     * 회원 정보 조회 (닉네임으로)
     */
    Optional<Member> findByNickname(@Param("nickname") String nickname);
    
    /**
     * 아이디 중복 체크
     */
    boolean existsByUserid(@Param("userid") String userid);
    
    /**
     * 이메일 중복 체크
     */
    boolean existsByEmail(@Param("email") String email);
    
    /**
     * 닉네임 중복 체크
     */
    boolean existsByNickname(@Param("nickname") String nickname);
    
    /**
     * 회원 등록
     */
    int insertMember(Member member);
    
    /**
     * 회원 정보 수정
     */
    int updateMember(Member member);
    
    /**
     * 비밀번호 변경
     */
    int updatePassword(@Param("userid") String userid, 
                      @Param("password") String password, 
                      @Param("updatedAt") Timestamp updatedAt);
    
    /**
     * 로그인 정보 업데이트 (로그인 횟수, 마지막 로그인 시간)
     */
    int updateLoginInfo(Member member);
    
    /**
     * 회원 상태 변경
     */
    int updateStatus(@Param("userid") String userid, 
                    @Param("status") String status, 
                    @Param("updatedAt") Timestamp updatedAt);
    
    /**
     * 회원 삭제 (탈퇴 처리)
     */
    int deleteMember(@Param("userid") String userid, 
                    @Param("updatedAt") Timestamp updatedAt);
    
    /**
     * 프로필 이미지 업데이트 - 해당 컬럼이 없으므로 제거
     */
    // int updateProfileImage(@Param("userid") String userid, 
    //                       @Param("profileImage") String profileImage, 
    //                       @Param("updatedAt") LocalDateTime updatedAt);
    
    // ========== 목록 조회 ==========
    
    /**
     * 전체 회원 목록 조회 (관리자용)
     */
    List<Member> findAllMembers(@Param("offset") int offset, @Param("limit") int limit);
    
    /**
     * 소셜 로그인 회원 조회
     */
    List<Member> findByProvider(@Param("provider") String provider);
    
    /**
     * 회원 검색 (동적 쿼리)
     */
    List<Member> searchMembers(@Param("keyword") String keyword,
                              @Param("provider") String provider,
                              @Param("status") String status,
                              @Param("offset") int offset, 
                              @Param("limit") int limit);
    
    /**
     * 최근 가입한 회원 조회
     */
    List<Member> findRecentMembers(@Param("limit") int limit);
    
    /**
     * 최근 로그인한 회원 조회
     */
    List<Member> findRecentLoginMembers(@Param("limit") int limit);
    
    /**
     * 휴면 회원 조회
     */
    List<Member> findDormantMembers(@Param("days") int days, 
                                   @Param("offset") int offset, 
                                   @Param("limit") int limit);
    
    /**
     * 생일인 회원 조회
     */
    List<Member> findBirthdayMembers();
    
    // ========== 통계 조회 ==========
    
    /**
     * 회원 수 조회
     */
    int countMembers();
    
    /**
     * 활성 회원 수 조회
     */
    int countActiveMembers();
    
    /**
     * 회원 검색 결과 수
     */
    int countSearchMembers(@Param("keyword") String keyword,
                          @Param("provider") String provider,
                          @Param("status") String status);
    
    /**
     * 휴면 회원 수 조회
     */
    int countDormantMembers(@Param("days") int days);
    
    /**
     * 경고 회원 수 조회
     */
    int countWarningMembers();
    
    /**
     * 정지 회원 수 조회
     */
    int countSuspendedMembers();
    
    /**
     * 탈퇴 회원 수 조회
     */
    int countWithdrawnMembers();
    
    /**
     * 상태별 회원 목록 조회
     */
    List<Member> findMembersByStatus(@Param("status") String status, @Param("offset") int offset, @Param("limit") int limit);
    
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
