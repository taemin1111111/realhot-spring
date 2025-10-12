package com.wherehot.spring.dto.auth;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

/**
 * 회원가입 요청 DTO
 */
public class SignupRequest {
    
    @NotBlank(message = "아이디는 필수입니다")
    @Size(min = 4, max = 20, message = "아이디는 4-20자 사이여야 합니다")
    @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "아이디는 영문, 숫자, 언더스코어만 사용 가능합니다")
    private String userid;
    
    @NotBlank(message = "비밀번호는 필수입니다")
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$", 
             message = "비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다")
    private String password;
    
    @NotBlank(message = "비밀번호 확인은 필수입니다")
    private String passwordConfirm;
    
    @NotBlank(message = "이름은 필수입니다")
    @Size(min = 2, max = 10, message = "이름은 2-10자 사이여야 합니다")
    private String name;
    
    @NotBlank(message = "닉네임은 필수입니다")
    @Size(min = 2, max = 5, message = "닉네임은 2-5자 사이여야 합니다")
    private String nickname;
    
    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    private String email;
    
    @NotBlank(message = "이메일 인증코드는 필수입니다")
    @Pattern(regexp = "^\\d{6}$", message = "인증코드는 6자리 숫자여야 합니다")
    private String emailVerificationCode;
    
    private LocalDate birth;
    
    @Pattern(regexp = "^[MF]$", message = "성별은 M 또는 F여야 합니다")
    private String gender;
    
    private String phone;
    
    @NotBlank(message = "가입 경로는 필수입니다")
    @Pattern(regexp = "^(site|naver)$", message = "가입 경로는 site 또는 naver여야 합니다")
    private String provider = "site";
    
    // 기본 생성자
    public SignupRequest() {}
    
    // Getters and Setters
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getPasswordConfirm() {
        return passwordConfirm;
    }
    
    public void setPasswordConfirm(String passwordConfirm) {
        this.passwordConfirm = passwordConfirm;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getNickname() {
        return nickname;
    }
    
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getEmailVerificationCode() {
        return emailVerificationCode;
    }
    
    public void setEmailVerificationCode(String emailVerificationCode) {
        this.emailVerificationCode = emailVerificationCode;
    }
    
    public LocalDate getBirth() {
        return birth;
    }
    
    public void setBirth(LocalDate birth) {
        this.birth = birth;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getProvider() {
        return provider;
    }
    
    public void setProvider(String provider) {
        this.provider = provider;
    }
    
    /**
     * 비밀번호 확인 검증
     */
    public boolean isPasswordMatched() {
        return password != null && password.equals(passwordConfirm);
    }
    
    @Override
    public String toString() {
        return "SignupRequest{" +
                "userid='" + userid + '\'' +
                ", name='" + name + '\'' +
                ", nickname='" + nickname + '\'' +
                ", email='" + email + '\'' +
                ", birth=" + birth +
                ", gender='" + gender + '\'' +
                ", provider='" + provider + '\'' +
                '}';
    }
}
