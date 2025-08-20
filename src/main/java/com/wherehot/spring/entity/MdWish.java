package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * MD 위시 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class MdWish {
    private int wishId;
    private int mdId;
    private String userid;
    private LocalDateTime createdAt;
    
    // 기본 생성자
    public MdWish() {}
    
    // 2개 파라미터 생성자 (새 위시 생성용)
    public MdWish(int mdId, String userid) {
        this.mdId = mdId;
        this.userid = userid;
    }
    
    // 전체 파라미터 생성자
    public MdWish(int wishId, int mdId, String userid, LocalDateTime createdAt) {
        this.wishId = wishId;
        this.mdId = mdId;
        this.userid = userid;
        this.createdAt = createdAt;
    }
    
    // Getter와 Setter
    public int getWishId() {
        return wishId;
    }
    
    public void setWishId(int wishId) {
        this.wishId = wishId;
    }
    
    public int getMdId() {
        return mdId;
    }
    
    public void setMdId(int mdId) {
        this.mdId = mdId;
    }
    
    public String getUserid() {
        return userid;
    }
    
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}