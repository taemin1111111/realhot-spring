package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.EmailVerification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Optional;

/**
 * 이메일 인증 관련 Mapper
 */
@Mapper
public interface EmailVerificationMapper {
    
    /**
     * 이메일 인증 정보 저장
     */
    int insertEmailVerification(EmailVerification emailVerification);
    
    /**
     * 이메일과 인증번호로 조회
     */
    Optional<EmailVerification> findByEmailAndCode(@Param("email") String email, @Param("code") String code);
    
    /**
     * 이메일로 최신 인증 정보 조회
     */
    Optional<EmailVerification> findLatestByEmail(@Param("email") String email);
    
    /**
     * 인증 완료 처리
     */
    int markAsVerified(@Param("id") int id);
    
    /**
     * 만료된 인증 정보 삭제
     */
    int deleteExpiredVerifications();
    
    /**
     * 특정 이메일의 모든 인증 정보 삭제 (새 인증 요청 시)
     */
    int deleteByEmail(@Param("email") String email);
    
    /**
     * 이메일 인증 완료 여부 확인 (24시간 내)
     */
    boolean isEmailVerifiedRecently(@Param("email") String email);
    
    /**
     * 오늘 아이디 찾기를 이미 했는지 확인
     */
    boolean hasIdSearchToday(@Param("email") String email);
    
    /**
     * 오늘 비밀번호 찾기를 이미 했는지 확인
     */
    boolean hasPasswordResetToday(@Param("email") String email);
    
    /**
     * 최근 N분 이내에 인증된 비밀번호 리셋 레코드 조회
     */
    Optional<EmailVerification> findRecentVerifiedByEmail(@Param("email") String email, @Param("minutesWindow") int minutesWindow);
}
