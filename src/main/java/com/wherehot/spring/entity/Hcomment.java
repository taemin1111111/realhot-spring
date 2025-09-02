package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 댓글 엔티티
 * hottalk_comment 테이블과 매핑
 */
public class Hcomment {
    
    private Integer id;
    private Integer postId;
    private String nickname;
    private String passwd;
    private String idAddress;
    private String content;
    private String ipAddress;
    private Integer likes = 0;
    private Integer dislikes = 0;
    private LocalDateTime createdAt;
    
    // 프론트엔드에서 사용할 사용자 리액션 상태 (DB에 저장되지 않음)
    private String userReaction;
    
    // 생성자
    public Hcomment() {
        this.createdAt = LocalDateTime.now();
        this.likes = 0;
        this.dislikes = 0;
    }
    
    // Getter & Setter
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public Integer getPostId() {
        return postId;
    }
    
    public void setPostId(Integer postId) {
        this.postId = postId;
    }
    
    public String getNickname() {
        return nickname;
    }
    
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getPasswd() {
        return passwd;
    }
    
    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }
    
    public String getIdAddress() {
        return idAddress;
    }
    
    public void setIdAddress(String idAddress) {
        this.idAddress = idAddress;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getIpAddress() {
        return ipAddress;
    }
    
    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }
    
    public Integer getLikes() {
        return likes;
    }
    
    public void setLikes(Integer likes) {
        this.likes = likes;
    }
    
    public Integer getDislikes() {
        return dislikes;
    }
    
    public void setDislikes(Integer dislikes) {
        this.dislikes = dislikes;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getUserReaction() {
        return userReaction;
    }
    
    public void setUserReaction(String userReaction) {
        this.userReaction = userReaction;
    }
}
