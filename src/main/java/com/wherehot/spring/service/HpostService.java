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
    
    @Autowired
    private ExpService expService;
    
    /**
     * 핫플썰 게시글 목록 조회 (최신순)
     */
    public List<Hpost> getLatestHpostList(int offset, int limit) {
        return hpostMapper.selectLatestHpostList(offset, limit);
    }
    
    /**
     * 핫플썰 게시글 목록 조회 (인기순)
     */
    public List<Hpost> getPopularHpostList(int offset, int limit) {
        return hpostMapper.selectPopularHpostList(offset, limit);
    }
    
    /**
     * 전체 게시글 수 조회
     */
    public int getTotalHpostCount() {
        return hpostMapper.selectTotalHpostCount();
    }
    
    /**
     * 검색 게시글 목록 조회 (최신순)
     */
    public List<Hpost> searchLatestHpostList(String searchType, String searchKeyword, int offset, int limit) {
        return hpostMapper.searchLatestHpostList(searchType, searchKeyword, offset, limit);
    }
    
    /**
     * 검색 게시글 목록 조회 (인기순)
     */
    public List<Hpost> searchPopularHpostList(String searchType, String searchKeyword, int offset, int limit) {
        return hpostMapper.searchPopularHpostList(searchType, searchKeyword, offset, limit);
    }
    
    /**
     * 검색 게시글 수 조회
     */
    public int getSearchHpostCount(String searchType, String searchKeyword) {
        return hpostMapper.selectSearchHpostCount(searchType, searchKeyword);
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
        
        // 핫플썰 작성 경험치 지급 (1개 = +10 Exp, 하루 최대 10 Exp)
        if (hpost.getUserid() != null && !hpost.getUserid().trim().isEmpty()) {
            try {
                boolean expAdded = expService.addHpostExp(hpost.getUserid(), 1);
                if (expAdded) {
                    System.out.println("Hpost exp added successfully for user: " + hpost.getUserid());
                } else {
                    System.out.println("Hpost exp not added (daily limit reached) for user: " + hpost.getUserid());
                }
            } catch (Exception e) {
                System.err.println("Error adding hpost exp for user: " + hpost.getUserid() + ", " + e.getMessage());
                // 경험치 지급 실패는 게시글 작성 자체를 실패시키지 않음
            }
        }
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
