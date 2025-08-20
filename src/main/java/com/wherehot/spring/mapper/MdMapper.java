package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Md;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface MdMapper {
    
    // MD 등록
    int insertMd(Md md);
    
    // MD 목록 조회 (페이징, 검색)
    List<Map<String, Object>> selectMdListWithPlace(
        @Param("offset") int offset,
        @Param("size") int size,
        @Param("keyword") String keyword,
        @Param("sort") String sort,
        @Param("loginId") String loginId,
        @Param("searchType") String searchType
    );
    
    // MD 전체 개수
    int selectMdCount(@Param("keyword") String keyword, @Param("searchType") String searchType);
    
    // MD 상세 조회
    Map<String, Object> selectMdDetail(@Param("mdId") Integer mdId, @Param("loginId") String loginId);
    
    // 검색 자동완성 제안
    List<Map<String, Object>> selectSearchSuggestions(
        @Param("keyword") String keyword,
        @Param("searchType") String searchType, 
        @Param("limit") int limit
    );

}