package com.wherehot.spring.dto.auth;

/**
 * JWT 응답 DTO
 */
public class JwtResponse {
    
    private String token;
    private String refreshToken;
    private String type = "Bearer";
    private String userid;
    private String nickname;
    private String provider;
    private String email;
    
    // 기본 생성자
    public JwtResponse() {}
    
    // 생성자 (refresh token 포함)
    public JwtResponse(String token, String refreshToken, String userid, String nickname, String provider, String email) {
        this.token = token;
        this.refreshToken = refreshToken;
        this.userid = userid;
        this.nickname = nickname;
        this.provider = provider;
        this.email = email;
    }
    
    // 기존 생성자 (호환성 유지)
    public JwtResponse(String token, String userid, String nickname, String provider, String email) {
        this.token = token;
        this.userid = userid;
        this.nickname = nickname;
        this.provider = provider;
        this.email = email;
    }
    
    // Getters and Setters
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    public String getRefreshToken() {
        return refreshToken;
    }
    
    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public String getNickname() {
        return nickname;
    }
    
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getProvider() {
        return provider;
    }
    
    public void setProvider(String provider) {
        this.provider = provider;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
}
