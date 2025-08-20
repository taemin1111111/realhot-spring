package com.wherehot.spring.entity;

import java.time.LocalDateTime;

/**
 * 위시리스트 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class WishList {
    
    private int id;             // 찜 고유 번호
    private String userid;      // 유저 ID (member.userid 참조)
    private int place_id;       // 핫플레이스 ID (hotplace_info.id 참조)
    private LocalDateTime wishDate; // 찜한 날짜
    private String personal_note; // 개인 메모

    // 생성자
    public WishList() {}

    public WishList(int id, String userid, int place_id, LocalDateTime wishDate) {
        this.id = id;
        this.userid = userid;
        this.place_id = place_id;
        this.wishDate = wishDate;
    }

    public WishList(int id, String userid, int place_id, LocalDateTime wishDate, String personal_note) {
        this.id = id;
        this.userid = userid;
        this.place_id = place_id;
        this.wishDate = wishDate;
        this.personal_note = personal_note;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public int getPlace_id() {
        return place_id;
    }

    public void setPlace_id(int place_id) {
        this.place_id = place_id;
    }

    public LocalDateTime getWishDate() {
        return wishDate;
    }

    public void setWishDate(LocalDateTime wishDate) {
        this.wishDate = wishDate;
    }

    public String getPersonal_note() {
        return personal_note;
    }

    public void setPersonal_note(String personal_note) {
        this.personal_note = personal_note;
    }
}
