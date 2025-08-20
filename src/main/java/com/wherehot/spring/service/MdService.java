package com.wherehot.spring.service;

import com.wherehot.spring.entity.Md;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface MdService {
    
    /**
     * MD 등록
     */
    void registerMd(Md md, MultipartFile photo) throws Exception;
    
    /**
     * MD 목록 조회 (페이징)
     */
    Page<Map<String, Object>> getMdListWithPlace(Pageable pageable, String keyword, String sort, String searchType);
    
    /**
     * MD 상세 조회
     */
    Map<String, Object> getMdDetail(Integer mdId);
    
    /**
     * 검색 자동완성 제안
     */
    List<Map<String, Object>> getSearchSuggestions(String keyword, String searchType, int limit);
}