package com.wherehot.spring.entity;

/**
 * 투표 히트맵 엔티티 - Model1 DTO와 일치하도록 수정
 */
public class VoteHeatmap {
    
    private String sido;
    private String sigungu;
    private int voteCount;
    
    // 기본 생성자
    public VoteHeatmap() {}
    
    public String getSido() {
        return sido;
    }

    public void setSido(String sido) {
        this.sido = sido;
    }

    public String getSigungu() {
        return sigungu;
    }

    public void setSigungu(String sigungu) {
        this.sigungu = sigungu;
    }

    public int getVoteCount() {
        return voteCount;
    }

    public void setVoteCount(int voteCount) {
        this.voteCount = voteCount;
    }
}
