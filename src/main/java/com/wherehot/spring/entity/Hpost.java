package com.wherehot.spring.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 핫토크 게시글 엔티티
 * hottalk_post 테이블과 매핑
 * MyBatis와 함께 사용하는 방식
 */
public class Hpost {
    
    private Integer id;                    // 게시글 번호 (PK, AI)
    private String userid;                 // 사용자 ID (VARCHAR(50))
    private String userip;                 // IP 주소 (VARCHAR(100))
    private String nickname;               // 닉네임 (VARCHAR(100))
    private String passwd;                 // 비밀번호 (VARCHAR(100))
    private String title;                  // 제목 (VARCHAR(200), NN)
    private String content;                // 내용 (TEXT, NN)
    private Integer views = 0;             // 조회수 (INT, default '0')
    private String photo1;                 // 사진1 (VARCHAR(255))
    private String photo2;                 // 사진2 (VARCHAR(255))
    private String photo3;                 // 사진3 (VARCHAR(255))
    private Integer likes = 0;             // 좋아요 (INT, default '0')
    private Integer dislikes = 0;          // 싫어요 (INT, default '0')
    private Integer reports = 0;           // 신고수 (INT, default '0')
    private LocalDateTime createdAt;       // 생성시간 (DATETIME, default CURRENT_TIMESTAMP)
    private String formattedTime;          // 포맷팅된 시간 (몇분전, 몇시간전 등)
    private Integer commentCount = 0;      // 댓글 수 (인기순 정렬용)
    
    // 연관관계 (MyBatis에서 별도 조회)
    private List<Hcomment> comments = new ArrayList<>();
   
    
    // 생성자
    public Hpost() {
        this.createdAt = LocalDateTime.now();
        this.views = 0;
        this.likes = 0;
        this.dislikes = 0;
        this.reports = 0;
    }
    
    // Getter & Setter
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public String getUserip() {
        return userip;
    }
    
    public void setUserip(String userip) {
        this.userip = userip;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getPhoto1() {
        return photo1;
    }
    
    public void setPhoto1(String photo1) {
        this.photo1 = photo1;
    }
    
    public String getPhoto2() {
        return photo2;
    }
    
    public void setPhoto2(String photo2) {
        this.photo2 = photo2;
    }
    
    public String getPhoto3() {
        return photo3;
    }
    
    public void setPhoto3(String photo3) {
        this.photo3 = photo3;
    }
    
    public Integer getViews() {
        return views;
    }
    
    public void setViews(Integer views) {
        this.views = views;
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
    
    public Integer getReports() {
        return reports;
    }
    
    public void setReports(Integer reports) {
        this.reports = reports;
    }
    
    public String getFormattedTime() {
        return formattedTime;
    }
    
    public void setFormattedTime(String formattedTime) {
        this.formattedTime = formattedTime;
    }
    
    public List<Hcomment> getComments() {
        return comments;
    }
    
    public void setComments(List<Hcomment> comments) {
        this.comments = comments;
    }
    
    public Integer getCommentCount() {
        return commentCount;
    }
    
    public void setCommentCount(Integer commentCount) {
        this.commentCount = commentCount;
    }
}
