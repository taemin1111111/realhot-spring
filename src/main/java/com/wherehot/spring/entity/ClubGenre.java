package com.wherehot.spring.entity;

/**
 * 클럽 장르 엔티티 - 실제 DB 테이블 구조에 맞춤
 */
public class ClubGenre {
    
    private int genre_id;
    private String genre_name;
    
    // 기본 생성자
    public ClubGenre() {}
    
    // 생성자
    public ClubGenre(int genre_id, String genre_name) {
        this.genre_id = genre_id;
        this.genre_name = genre_name;
    }
    
    // Getters and Setters
    public int getGenre_id() {
        return genre_id;
    }
    
    public void setGenre_id(int genre_id) {
        this.genre_id = genre_id;
    }
    
    public String getGenre_name() {
        return genre_name;
    }
    
    public void setGenre_name(String genre_name) {
        this.genre_name = genre_name;
    }
    
    @Override
    public String toString() {
        return "ClubGenre{" +
                "genre_id=" + genre_id +
                ", genre_name='" + genre_name + '\'' +
                '}';
    }
}
