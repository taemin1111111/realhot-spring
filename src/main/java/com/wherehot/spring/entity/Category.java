package com.wherehot.spring.entity;

/**
 * 카테고리 엔티티 - Model1 구조에 맞게 간소화
 */
public class Category {
    
    private int id;
    private String name;
    
    // 기본 생성자
    public Category() {}
    
    // 생성자
    public Category(String name) {
        this.name = name;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    @Override
    public String toString() {
        return "Category{" +
                "id=" + id +
                ", name='" + name + '\'' +
                '}';
    }
}
