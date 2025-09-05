package com.wherehot.spring.service;

import com.wherehot.spring.entity.Md;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface MdService {
    
    // MD 목록 조회 (페이징, 검색, 정렬)
    Map<String, Object> getMdList(int page, int size, String keyword, String searchType, String sort, String userId);
    
    // MD 상세 조회
    Md getMdById(int mdId);
    
    // MD 등록
    boolean registerMd(Md md);
    
    // MD 수정
    boolean updateMd(Md md);
    
    // MD 삭제
    boolean deleteMd(int mdId);
    
    // MD 찜하기
    boolean addMdWish(int mdId, String userId);
    
    // MD 찜하기 취소
    boolean removeMdWish(int mdId, String userId);
    
    // MD 찜하기 여부 확인
    boolean isMdWished(int mdId, String userId);
    
    // 디버깅용: 모든 MD 조회
    List<Md> getAllMds(String userId);
    
    // 가게 목록 조회 (MD 추가용)
    List<Map<String, Object>> getHotplaceList();
    
    // 가게 검색 (MD 추가용)
    List<Map<String, Object>> searchHotplaces(String keyword);
    
    // 검색 자동완성
    List<Map<String, Object>> getSearchSuggestions(String keyword, String searchType);

}