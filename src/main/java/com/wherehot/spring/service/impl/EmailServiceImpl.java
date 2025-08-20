package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.EmailVerification;
import com.wherehot.spring.mapper.EmailVerificationMapper;
import com.wherehot.spring.service.EmailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.Random;

/**
 * 이메일 서비스 구현체
 */
@Service
public class EmailServiceImpl implements EmailService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailServiceImpl.class);
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Autowired
    private EmailVerificationMapper emailVerificationMapper;
    
    @Override
    public boolean sendVerificationCode(String email) {
        try {
            logger.info("Starting email verification for: {}", email);
            
            // 6자리 랜덤 인증번호 생성
            String verificationCode = String.format("%06d", new Random().nextInt(1000000));
            logger.info("Generated verification code for {}: {}", email, verificationCode);
            
            // 기존 인증 정보 삭제 (새 인증 요청 시)
            emailVerificationMapper.deleteByEmail(email);
            
            // DB에 인증번호 저장 (10분 유효)
            EmailVerification emailVerification = new EmailVerification(email, verificationCode, "system");
            emailVerificationMapper.insertEmailVerification(emailVerification);
            logger.info("Verification code saved to database for: {}", email);
            
            // 이메일 발송
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("chotaemin0920@gmail.com"); // model1에서 사용하는 발신자 이메일
            message.setTo(email);
            message.setSubject("[어디핫?] 이메일 인증번호");
            message.setText(createEmailContent(verificationCode));
            
            logger.info("Attempting to send email to: {}", email);
            mailSender.send(message);
            logger.info("Email successfully sent to: {}", email);
            
            return true;
            
        } catch (Exception e) {
            logger.error("Failed to send verification email to: {}", email, e);
            return false;
        }
    }
    
    @Override
    public boolean verifyCode(String email, String code) {
        try {
            // DB에서 인증번호 조회
            Optional<EmailVerification> verificationOpt = emailVerificationMapper.findByEmailAndCode(email, code);
            
            if (verificationOpt.isPresent()) {
                EmailVerification verification = verificationOpt.get();
                
                // 만료 시간 확인
                if (!verification.isExpired()) {
                    // 인증 완료 처리
                    emailVerificationMapper.markAsVerified(verification.getId());
                    logger.info("Email verification successful for: {}", email);
                    return true;
                } else {
                    logger.warn("Verification code expired for: {}", email);
                }
            } else {
                logger.warn("Invalid verification code for: {}", email);
            }
            
            return false;
            
        } catch (Exception e) {
            logger.error("Failed to verify email code for: {}", email, e);
            return false;
        }
    }
    
    @Override
    public boolean isEmailVerified(String email) {
        try {
            // 24시간 내 인증 완료 여부 확인
            return emailVerificationMapper.isEmailVerifiedRecently(email);
        } catch (Exception e) {
            logger.error("Failed to check email verification status for: {}", email, e);
            return false;
        }
    }
    
    @Override
    public boolean sendPasswordResetEmail(String email) {
        try {
            // 임시 비밀번호 생성
            String tempPassword = generateTempPassword();
            
            // 이메일 발송
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("[어디핫?] 임시 비밀번호");
            message.setText("임시 비밀번호: " + tempPassword + "\n\n로그인 후 반드시 비밀번호를 변경해주세요.");
            
            mailSender.send(message);
            
            logger.info("Password reset email sent to: {}", email);
            return true;
            
        } catch (Exception e) {
            logger.error("Failed to send password reset email to: {}", email, e);
            return false;
        }
    }
    
    private String generateTempPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
        StringBuilder sb = new StringBuilder();
        Random random = new Random();
        
        for (int i = 0; i < 12; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return sb.toString();
    }
    
    /**
     * 이메일 내용 생성 (model1과 동일한 형식)
     */
    private String createEmailContent(String verificationCode) {
        return "안녕하세요! 어디핫? 회원가입을 위한 인증번호입니다.\n\n" +
               "인증번호: " + verificationCode + "\n" +
               "만료시간: 10분 후\n\n" +
               "본인이 요청하지 않은 경우 무시하세요.\n\n" +
               "감사합니다.\n" +
               "어디핫? 팀";
    }
}
