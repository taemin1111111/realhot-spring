package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Md;
import com.wherehot.spring.mapper.MdMapper;
import com.wherehot.spring.service.MdService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

@Service
public class MdServiceImpl implements MdService {
    
    @Autowired
    private MdMapper mdMapper;
    
    @Override
    public Map<String, Object> getMdList(int page, int size, String keyword, String searchType, String sort, String userId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            int offset = page * size;
            
            // MD 목록 조회 (userId 포함하여 찜 상태도 함께 조회)
            List<Md> mdList = mdMapper.selectMdList(offset, size, keyword, searchType, sort, userId);
            
            // 전체 개수 조회
            int totalCount = mdMapper.selectMdCount(keyword, searchType);
            
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            result.put("success", true);
            result.put("mds", mdList);
            result.put("currentPage", page);
            result.put("totalPages", totalPages);
            result.put("totalElements", totalCount);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "MD 목록을 불러오는데 실패했습니다: " + e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }
    
    @Override
    public List<Md> getAllMds(String userId) {
        try {
            return mdMapper.selectAllMds(userId);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    @Override
    public Md getMdById(int mdId) {
        try {
            return mdMapper.selectMdById(mdId);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    @Override
    public boolean registerMd(Md md) {
        try {
            int result = mdMapper.insertMd(md);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public boolean updateMd(Md md) {
        try {
            int result = mdMapper.updateMd(md);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public boolean deleteMd(int mdId) {
        try {
            int result = mdMapper.deleteMd(mdId);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public boolean addMdWish(int mdId, String userId) {
        try {
            System.out.println("=== MdServiceImpl.addMdWish ===");
            System.out.println("mdId: " + mdId + ", userId: " + userId);
            
            // 이미 찜한 상태인지 확인
            boolean isWished = isMdWished(mdId, userId);
            System.out.println("현재 찜 상태: " + isWished);
            
            if (isWished) {
                // 이미 찜한 상태라면 찜을 제거 (토글 방식)
                System.out.println("이미 찜한 상태 - 찜 제거 시도");
                boolean removeResult = removeMdWish(mdId, userId);
                System.out.println("찜 제거 결과: " + removeResult);
                return removeResult;
            }
            
            // 찜하지 않은 상태라면 찜 추가
            System.out.println("찜하지 않은 상태 - 찜 추가 시도");
            int result = mdMapper.insertMdWish(mdId, userId);
            System.out.println("찜 추가 결과: " + result);
            return result > 0;
        } catch (Exception e) {
            System.out.println("addMdWish 오류: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public boolean removeMdWish(int mdId, String userId) {
        try {
            System.out.println("=== MdServiceImpl.removeMdWish ===");
            System.out.println("mdId: " + mdId + ", userId: " + userId);
            
            int result = mdMapper.deleteMdWish(mdId, userId);
            System.out.println("찜 제거 결과: " + result);
            return result > 0;
        } catch (Exception e) {
            System.out.println("removeMdWish 오류: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    @Override
    public boolean isMdWished(int mdId, String userId) {
        try {
            System.out.println("=== MdServiceImpl.isMdWished ===");
            System.out.println("mdId: " + mdId + ", userId: " + userId);
            
            int count = mdMapper.selectMdWishCount(mdId, userId);
            System.out.println("찜 개수: " + count);
            boolean result = count > 0;
            System.out.println("찜 상태: " + result);
            return result;
        } catch (Exception e) {
            System.out.println("isMdWished 오류: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}