package com.wherehot.spring.dto.auth;

/**
 * JWT 응답 DTO
 */
public class JwtResponse {
    
    private String token;
    private String type = "Bearer";
    private String userid;
    private String nickname;
    private String provider;
    private String email;
    
    // 기본 생성자
    public JwtResponse() {}
    
    // 생성자
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
