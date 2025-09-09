package com.wherehot.spring.entity;

import java.time.LocalDateTime;
import java.time.LocalDate;

/**
 * 회원 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class Member {
    
    private String userid;
    private String passwd;
    private String name;
    private String nickname;
    private String email;
    private String phone;
    private LocalDate birth;
    private String gender;
    private String provider;  // site, naver, admin
    private String status;    // 정상, C(정지)
    private LocalDateTime regdate;
    private LocalDateTime updateDate;
    // 해당 컬럼들이 데이터베이스에 없으므로 제거
    // private LocalDateTime lastLoginAt;
    // private int loginCount;
    // private String profileImage;
    
    // 기본 생성자
    public Member() {}
    
    // 생성자
    public Member(String userid, String passwd, String name, String nickname, String email) {
        this.userid = userid;
        this.passwd = passwd;
        this.name = name;
        this.nickname = nickname;
        this.email = email;
        this.provider = "site";
        this.status = "A"; // Model1 호환성: 'A'(정상)
        this.regdate = LocalDateTime.now();
        this.updateDate = LocalDateTime.now();
    }
    
    // Getters and Setters
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public String getPasswd() {
        return passwd;
    }
    
    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }
    
    // Spring Security와의 호환성을 위한 password getter/setter
    public String getPassword() {
        return passwd;
    }
    
    public void setPassword(String password) {
        this.passwd = password;
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
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
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
    
    public String getProvider() {
        return provider;
    }
    
    public void setProvider(String provider) {
        this.provider = provider;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public LocalDateTime getRegdate() {
        return regdate;
    }
    
    public void setRegdate(LocalDateTime regdate) {
        this.regdate = regdate;
    }
    
    public LocalDateTime getUpdateDate() {
        return updateDate;
    }
    
    public void setUpdateDate(LocalDateTime updateDate) {
        this.updateDate = updateDate;
    }
    
    // Spring Security와의 호환성을 위한 getter/setter들
    public LocalDateTime getCreatedAt() {
        return regdate;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.regdate = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updateDate;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updateDate = updatedAt;
    }
    
    // 해당 컬럼들이 데이터베이스에 없으므로 제거
    // public LocalDateTime getLastLoginAt() {
    //     return lastLoginAt;
    // }
    
    // public void setLastLoginAt(LocalDateTime lastLoginAt) {
    //     this.lastLoginAt = lastLoginAt;
    // }
    
    // public int getLoginCount() {
    //     return loginCount;
    // }
    
    // public void setLoginCount(int loginCount) {
    //     this.loginCount = loginCount;
    // }
    
    // public String getProfileImage() {
    //     return profileImage;
    // }
    
    // public void setProfileImage(String profileImage) {
    //     this.profileImage = profileImage;
    // }
    
    /**
     * 계정이 활성화 상태인지 확인
     * Model1 호환성: 'A'(정상), 'B'(경고), 'C'(정지), 'W'(탈퇴)
     */
    public boolean isActive() {
        return "A".equals(status) || "B".equals(status) || "정상".equals(status);
    }
    
    /**
     * 소셜 로그인 계정인지 확인
     */
    public boolean isSocialAccount() {
        return "naver".equals(provider);
    }
    
    /**
     * 관리자 계정인지 확인
     */
    public boolean isAdmin() {
        return "admin".equals(provider);
    }
    
    /**
     * 로그인 정보 업데이트 (해당 컬럼들이 없으므로 업데이트 시간만)
     */
    public void updateLoginInfo() {
        this.updateDate = LocalDateTime.now();
    }
    
    @Override
    public String toString() {
        return "Member{" +
                "userid='" + userid + '\'' +
                ", name='" + name + '\'' +
                ", nickname='" + nickname + '\'' +
                ", email='" + email + '\'' +
                ", provider='" + provider + '\'' +
                ", status='" + status + '\'' +
                ", regdate=" + regdate +
                ", updateDate=" + updateDate +
                '}';
    }
}
