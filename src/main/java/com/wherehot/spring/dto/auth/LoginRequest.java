package com.wherehot.spring.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 로그인 요청 DTO
 */
public class LoginRequest {
    
    @NotBlank(message = "아이디는 필수입니다")
    @Size(min = 1, max = 20, message = "아이디는 필수입니다")
    private String userid;
    
    @NotBlank(message = "비밀번호는 필수입니다")
    @Size(min = 1, max = 100, message = "비밀번호는 필수입니다")
    private String password;
    
    private boolean rememberMe = false;
    
    // 기본 생성자
    public LoginRequest() {}
    
    // 생성자
    public LoginRequest(String userid, String password) {
        this.userid = userid;
        this.password = password;
    }
    
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
    
    public boolean isRememberMe() {
        return rememberMe;
    }
    
    public void setRememberMe(boolean rememberMe) {
        this.rememberMe = rememberMe;
    }
    
    @Override
    public String toString() {
        return "LoginRequest{" +
                "userid='" + userid + '\'' +
                ", rememberMe=" + rememberMe +
                '}';
    }
}
