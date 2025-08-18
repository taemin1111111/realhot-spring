package Member;

import java.sql.Date;

/**
 * 회원 DTO (기존 시스템 호환용)
 */
public class MemberDTO {
    
    private String userid;
    private String passwd;
    private String name;
    private String nickname;
    private String email;
    private String phone;
    private Date birth;
    private String gender;
    private String provider;
    private String status;
    
    // 기본 생성자
    public MemberDTO() {}
    
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
    
    public Date getBirth() {
        return birth;
    }
    
    public void setBirth(Date birth) {
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
}
