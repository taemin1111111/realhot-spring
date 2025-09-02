package com.wherehot.spring.service;

import com.wherehot.spring.entity.Hpost;
import com.wherehot.spring.mapper.HpostMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HpostService {
    
    @Autowired
    private HpostMapper hpostMapper;
    
    /**
     * 핫플썰 게시글 목록 조회 (최신순)
     */
    public List<Hpost> getLatestHpostList(int offset) {
        return hpostMapper.selectLatestHpostList(offset);
    }
    
    /**
     * 핫플썰 게시글 목록 조회 (인기순)
     */
    public List<Hpost> getPopularHpostList(int offset) {
        return hpostMapper.selectPopularHpostList(offset);
    }
    
    /**
     * 전체 게시글 수 조회
     */
    public int getTotalHpostCount() {
        return hpostMapper.selectTotalHpostCount();
    }
    
    /**
     * 게시글 상세 조회 (조회수 증가 없음)
     */
    public Hpost getHpostByIdWithoutIncrement(int id) {
        return hpostMapper.selectHpostById(id);
    }
    
    /**
     * 게시글 상세 조회 (조회수 증가)
     */
    public Hpost getHpostById(int id) {
        hpostMapper.incrementViewCount(id);
        return hpostMapper.selectHpostById(id);
    }
    
    /**
     * 게시글 저장
     */
    public void saveHpost(Hpost hpost) {
        hpostMapper.insertHpost(hpost);
    }
    
    /**
     * 좋아요/싫어요 수 업데이트
     */
    public void updateVoteCounts(int postId, int likes, int dislikes) {
        hpostMapper.updateVoteCounts(postId, likes, dislikes);
    }
    
    /**
     * 게시글과 연관된 모든 데이터 삭제
     */
    public boolean deleteHpostWithAllData(int postId) {
        try {
            // 1. 게시글 삭제 (연관된 데이터는 CASCADE로 자동 삭제)
            int result = hpostMapper.deleteHpost(postId);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
