package com.wherehot.spring.service.impl;

import com.wherehot.spring.service.EmailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * 이메일 서비스 구현체
 */
@Service
public class EmailServiceImpl implements EmailService {
    
    private static final Logger logger = LoggerFactory.getLogger(EmailServiceImpl.class);
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Autowired
    private RedisTemplate<String, String> redisTemplate;
    
    @Override
    public boolean sendVerificationCode(String email) {
        try {
            logger.info("Starting email verification for: {}", email);
            
            // 6자리 랜덤 인증번호 생성
            String verificationCode = String.format("%06d", new Random().nextInt(1000000));
            logger.info("Generated verification code for {}: {}", email, verificationCode);
            
            // Redis에 인증번호 저장 (10분 유효)
            String key = "email_verification:" + email;
            redisTemplate.opsForValue().set(key, verificationCode, 10, TimeUnit.MINUTES);
            logger.info("Verification code saved to Redis for: {}", email);
            
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
            String key = "email_verification:" + email;
            String storedCode = redisTemplate.opsForValue().get(key);
            
            if (storedCode != null && storedCode.equals(code)) {
                // 인증 성공 시 인증 완료 표시 (24시간 유지)
                redisTemplate.opsForValue().set("email_verified:" + email, "true", 24, TimeUnit.HOURS);
                // 인증번호 삭제
                redisTemplate.delete(key);
                
                logger.info("Email verification successful for: {}", email);
                return true;
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
            String key = "email_verified:" + email;
            return redisTemplate.hasKey(key);
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
            
            // Redis에 임시 비밀번호 저장 (30분 유효)
            String key = "temp_password:" + email;
            redisTemplate.opsForValue().set(key, tempPassword, 30, TimeUnit.MINUTES);
            
            // 이메일 발송
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("[WhereHot] 임시 비밀번호");
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
