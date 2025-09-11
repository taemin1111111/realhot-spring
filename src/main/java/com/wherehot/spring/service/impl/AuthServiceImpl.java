package com.wherehot.spring.service.impl;

import com.wherehot.spring.dto.auth.JwtResponse;
import com.wherehot.spring.dto.auth.LoginRequest;
import com.wherehot.spring.dto.auth.SignupRequest;
import com.wherehot.spring.entity.Member;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.security.JwtUtils;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.service.EmailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * 인증 서비스 구현체
 */
@Service
@Transactional
public class AuthServiceImpl implements AuthService {
    
    private static final Logger logger = LoggerFactory.getLogger(AuthServiceImpl.class);
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    @Autowired
    private EmailService emailService;
    
    @Override
    public JwtResponse authenticateUser(LoginRequest loginRequest) {
        try {
            logger.info("Login attempt for userid: {}", loginRequest.getUserid());
            
            // 사용자 조회
            Optional<Member> memberOpt = memberMapper.findByUserid(loginRequest.getUserid());
            if (memberOpt.isEmpty()) {
                logger.error("User not found: {}", loginRequest.getUserid());
                throw new BadCredentialsException("존재하지 않는 아이디입니다.");
            }
            
            Member member = memberOpt.get();
            logger.info("User found: {}, provider: {}, status: {}", member.getUserid(), member.getProvider(), member.getStatus());
            
            // 계정 상태 확인
            String status = member.getStatus();
            if ("C".equals(status)) {
                throw new BadCredentialsException("정지된 회원입니다.");
            } else if ("W".equals(status)) {
                throw new BadCredentialsException("삭제된 회원입니다.");
            } else if (!"A".equals(status) && !"B".equals(status)) {
                throw new BadCredentialsException("정지된 계정입니다. 관리자에게 문의하세요.");
            }
            
            // 비밀번호 확인 (암호화된 비밀번호만 지원)
            boolean passwordMatch = false;
            logger.info("Password verification for user: {}", member.getUserid());
            
            if (member.getPasswd() != null && member.getPasswd().startsWith("$2")) {
                logger.info("Using encrypted password verification");
                passwordMatch = passwordEncoder.matches(loginRequest.getPassword(), member.getPasswd());
                logger.info("Encrypted password verification result: {}", passwordMatch);
            } else {
                logger.error("Invalid password format for user: {}. All passwords must be encrypted.", member.getUserid());
                throw new BadCredentialsException("비밀번호 형식이 올바르지 않습니다. 관리자에게 문의하세요.");
            }
            
            if (!passwordMatch) {
                logger.error("Password mismatch for user: {}", member.getUserid());
                throw new BadCredentialsException("비밀번호가 일치하지 않습니다.");
            }
            
            // 로그인 정보 업데이트
            member.updateLoginInfo();
            memberMapper.updateLoginInfo(member);
            
            // JWT 토큰 생성
            String accessToken = jwtUtils.generateAccessToken(member);
            String refreshToken = jwtUtils.generateRefreshToken(member);
            
            logger.info("Login successful for user: {}", member.getUserid());
            
            return new JwtResponse(accessToken, refreshToken, member.getUserid(), member.getNickname(), 
                                 member.getProvider(), member.getEmail());
                                 
        } catch (AuthenticationException e) {
            logger.error("Authentication failed for user: {}", loginRequest.getUserid());
            throw e;
        } catch (Exception e) {
            logger.error("Unexpected error during authentication: ", e);
            throw new RuntimeException("로그인 처리 중 오류가 발생했습니다.");
        }
    }
    
    @Override
    public Member registerUser(SignupRequest signupRequest) {
        // 비밀번호 확인
        if (!signupRequest.isPasswordMatched()) {
            throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
        }
        
        // 중복 체크
        if (memberMapper.existsByUserid(signupRequest.getUserid())) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }
        
        if (memberMapper.existsByEmail(signupRequest.getEmail())) {
            throw new IllegalArgumentException("이미 사용 중인 이메일입니다.");
        }
        
        if (memberMapper.existsByNickname(signupRequest.getNickname())) {
            throw new IllegalArgumentException("이미 사용 중인 닉네임입니다.");
        }
        
        // 이메일 인증 확인
        if (!emailService.isEmailVerified(signupRequest.getEmail())) {
            throw new IllegalArgumentException("이메일 인증을 완료해주세요.");
        }
        
        // Member 객체 생성
        Member member = new Member();
        member.setUserid(signupRequest.getUserid());
        // 신규 가입자는 암호화된 비밀번호 사용
        member.setPasswd(passwordEncoder.encode(signupRequest.getPassword()));
        member.setName(signupRequest.getName());
        member.setNickname(signupRequest.getNickname());
        member.setEmail(signupRequest.getEmail());
        member.setPhone(signupRequest.getPhone());
        member.setBirth(signupRequest.getBirth());
        member.setGender(signupRequest.getGender());
        member.setProvider(signupRequest.getProvider());
        member.setStatus("A"); // Model1 호환성: 'A'(정상)
        member.setRegdate(LocalDateTime.now());
        member.setUpdateDate(LocalDateTime.now());
        
        // DB 저장
        int result = memberMapper.insertMember(member);
        if (result == 0) {
            throw new RuntimeException("회원가입 처리 중 오류가 발생했습니다.");
        }
        
        logger.info("New user registered: {}", member.getUserid());
        return member;
    }
    
    @Override
    public Member registerNaverUser(SignupRequest signupRequest, String naverId) {
        // 네이버 사용자의 경우 비밀번호는 null
        signupRequest.setPassword(null);
        signupRequest.setPasswordConfirm(null);
        signupRequest.setProvider("naver");
        signupRequest.setUserid(naverId);
        
        // 닉네임 중복 체크만 수행
        if (memberMapper.existsByNickname(signupRequest.getNickname())) {
            throw new IllegalArgumentException("이미 사용 중인 닉네임입니다.");
        }
        
        // Member 객체 생성 (비밀번호 제외)
        Member member = new Member();
        member.setUserid(signupRequest.getUserid());
        member.setPasswd(null); // 네이버 로그인은 비밀번호 없음
        member.setName(signupRequest.getName());
        member.setNickname(signupRequest.getNickname());
        member.setEmail(signupRequest.getEmail());
        member.setBirth(signupRequest.getBirth());
        member.setGender(signupRequest.getGender());
        member.setProvider("naver");
        member.setStatus("A"); // Model1 호환성: 'A'(정상)
        member.setRegdate(LocalDateTime.now());
        member.setUpdateDate(LocalDateTime.now());
        
        // DB 저장
        int result = memberMapper.insertMember(member);
        if (result == 0) {
            throw new RuntimeException("네이버 회원가입 처리 중 오류가 발생했습니다.");
        }
        
        logger.info("New Naver user registered: {}", member.getUserid());
        return member;
    }
    
    @Override
    public boolean isUseridExists(String userid) {
        return memberMapper.existsByUserid(userid);
    }
    
    @Override
    public boolean isEmailExists(String email) {
        return memberMapper.existsByEmail(email);
    }
    
    @Override
    public boolean isNicknameExists(String nickname) {
        return memberMapper.existsByNickname(nickname);
    }
    
    @Override
    public boolean sendEmailVerificationCode(String email) {
        return emailService.sendVerificationCode(email);
    }
    
    @Override
    public boolean verifyEmailCode(String email, String code) {
        return emailService.verifyCode(email, code);
    }
    
    @Override
    public boolean isEmailVerified(String email) {
        return emailService.isEmailVerified(email);
    }
    
    @Override
    public Member getUserFromToken(String token) {
        if (!jwtUtils.validateToken(token)) {
            return null;
        }
        return jwtUtils.getMemberFromToken(token);
    }
    
    @Override
    public String refreshAccessToken(String refreshToken) {
        try {
            if (!jwtUtils.validateToken(refreshToken)) {
                throw new IllegalArgumentException("유효하지 않은 리프레시 토큰입니다.");
            }
            
            String userid = jwtUtils.getUseridFromToken(refreshToken);
            
            logger.info("Refresh token validation: JWT validation only");
            
            // 사용자 정보 조회
            Optional<Member> memberOpt = memberMapper.findByUserid(userid);
            if (memberOpt.isEmpty()) {
                throw new IllegalArgumentException("사용자를 찾을 수 없습니다.");
            }
            
            Member member = memberOpt.get();
            String status = member.getStatus();
            if ("C".equals(status)) {
                throw new IllegalArgumentException("정지된 회원입니다.");
            } else if ("W".equals(status)) {
                throw new IllegalArgumentException("삭제된 회원입니다.");
            } else if (!"A".equals(status) && !"B".equals(status)) {
                throw new IllegalArgumentException("비활성 상태입니다.");
            }
            
            // 새 액세스 토큰 생성
            return jwtUtils.generateAccessToken(memberOpt.get());
            
        } catch (Exception e) {
            logger.error("Error refreshing access token: ", e);
            throw new IllegalArgumentException("토큰 갱신 중 오류가 발생했습니다.");
        }
    }
    
    @Override
    public void logout(String token) {
        try {
            String userid = jwtUtils.getUseridFromToken(token);
            logger.info("User logged out successfully: {}", userid);
            
        } catch (Exception e) {
            logger.error("Error during logout: ", e);
        }
    }
}