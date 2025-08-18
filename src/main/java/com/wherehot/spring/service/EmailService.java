package com.wherehot.spring.service;

/**
 * 이메일 서비스 인터페이스
 */
public interface EmailService {
    
    /**
     * 이메일 인증코드 발송
     */
    boolean sendVerificationCode(String email);
    
    /**
     * 이메일 인증코드 확인
     */
    boolean verifyCode(String email, String code);
    
    /**
     * 이메일이 인증되었는지 확인
     */
    boolean isEmailVerified(String email);
    
    /**
     * 비밀번호 재설정 이메일 발송
     */
    boolean sendPasswordResetEmail(String email);
}
