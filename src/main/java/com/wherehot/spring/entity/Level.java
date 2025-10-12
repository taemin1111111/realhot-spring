package com.wherehot.spring.entity;

/**
 * 레벨 엔티티
 */
public class Level {
    
    private int levelId;
    private String name;
    private int expRequired;
    private String benefits;
    
    // 기본 생성자
    public Level() {}
    
    // 생성자
    public Level(int levelId, String name, int expRequired) {
        this.levelId = levelId;
        this.name = name;
        this.expRequired = expRequired;
    }
    
    public Level(int levelId, String name, int expRequired, String benefits) {
        this.levelId = levelId;
        this.name = name;
        this.expRequired = expRequired;
        this.benefits = benefits;
    }
    
    // Getters and Setters
    public int getLevelId() {
        return levelId;
    }
    
    public void setLevelId(int levelId) {
        this.levelId = levelId;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public int getExpRequired() {
        return expRequired;
    }
    
    public void setExpRequired(int expRequired) {
        this.expRequired = expRequired;
    }
    
    public String getBenefits() {
        return benefits;
    }
    
    public void setBenefits(String benefits) {
        this.benefits = benefits;
    }
    
    @Override
    public String toString() {
        return "Level{" +
                "levelId=" + levelId +
                ", name='" + name + '\'' +
                ", expRequired=" + expRequired +
                ", benefits='" + benefits + '\'' +
                '}';
    }
}
