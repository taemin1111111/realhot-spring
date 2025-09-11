package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 이메일 인증 엔티티 (기존 Model1 DB 구조 사용)
 * email_verification 테이블: id, email, verification_code, created_at, expires_at, is_verified, ip_address
 */
public class EmailVerification {
    
    private int id;
    private String email;
    private String verificationCode;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private boolean isVerified;  // false: 미인증, true: 인증완료
    private String ipAddress;
    
    // 기본 생성자
    public EmailVerification() {}
    
    // 생성자
    public EmailVerification(String email, String verificationCode, String ipAddress) {
        this.email = email;
        this.verificationCode = verificationCode;
        this.ipAddress = ipAddress;
        this.createdAt = LocalDateTime.now();
        this.expiresAt = LocalDateTime.now().plusMinutes(10); // 10분 후 만료
        this.isVerified = false; // 기본값: 미인증
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getVerificationCode() {
        return verificationCode;
    }
    
    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }
    
    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }
    
    public boolean getIsVerified() {
        return isVerified;
    }
    
    public boolean isVerified() {
        return isVerified;
    }
    
    public void setIsVerified(boolean isVerified) {
        this.isVerified = isVerified;
    }
    
    public String getIpAddress() {
        return ipAddress;
    }
    
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
    
    // 편의 메서드
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiresAt);
    }
    
    public void markAsVerified() {
        this.isVerified = true;
    }
    
    @Override
    public String toString() {
        return "EmailVerification{" +
                "id=" + id +
                ", email='" + email + '\'' +
                ", verificationCode='" + verificationCode + '\'' +
                ", createdAt=" + createdAt +
                ", expiresAt=" + expiresAt +
                ", isVerified=" + isVerified +
                ", ipAddress='" + ipAddress + '\'' +
                '}';
    }
}
