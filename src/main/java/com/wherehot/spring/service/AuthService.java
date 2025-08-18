package com.wherehot.spring.service;

import com.wherehot.spring.dto.auth.JwtResponse;
import com.wherehot.spring.dto.auth.LoginRequest;
import com.wherehot.spring.dto.auth.SignupRequest;
import com.wherehot.spring.entity.Member;

/**
 * 인증 서비스 인터페이스
 */
public interface AuthService {
    
    /**
     * 로그인 처리
     */
    JwtResponse authenticateUser(LoginRequest loginRequest);
    
    /**
     * 회원가입 처리
     */
    Member registerUser(SignupRequest signupRequest);
    
    /**
     * 네이버 회원가입 처리
     */
    Member registerNaverUser(SignupRequest signupRequest, String naverId);
    
    /**
     * 아이디 중복 체크
     */
    boolean isUseridExists(String userid);
    
    /**
     * 이메일 중복 체크
     */
    boolean isEmailExists(String email);
    
    /**
     * 닉네임 중복 체크
     */
    boolean isNicknameExists(String nickname);
    
    /**
     * 이메일 인증코드 발송
     */
    boolean sendEmailVerificationCode(String email);
    
    /**
     * 이메일 인증코드 확인
     */
    boolean verifyEmailCode(String email, String code);
    
    /**
     * JWT 토큰에서 사용자 정보 추출
     */
    Member getUserFromToken(String token);
    
    /**
     * 리프레시 토큰으로 새 액세스 토큰 발급
     */
    String refreshAccessToken(String refreshToken);
    
    /**
     * 로그아웃 처리 (토큰 블랙리스트 등록)
     */
    void logout(String token);
}
