package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Md;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface MdMapper {
    
    // MD 목록 조회 (페이징, 검색, 정렬)
    List<Md> selectMdList(@Param("offset") int offset, 
                          @Param("size") int size, 
                          @Param("keyword") String keyword, 
                          @Param("searchType") String searchType, 
                          @Param("sort") String sort,
                          @Param("userId") String userId);
    
    // 전체 MD 개수 조회
    int selectMdCount(@Param("keyword") String keyword, 
                     @Param("searchType") String searchType);
    
    // MD 상세 조회
    Md selectMdById(@Param("mdId") int mdId);
    
    // MD 등록
    int insertMd(Md md);
    
    // MD 수정
    int updateMd(Md md);
    
    // MD 삭제
    int deleteMd(@Param("mdId") int mdId);
    
    // MD 찜하기 추가
    int insertMdWish(@Param("mdId") int mdId, @Param("userId") String userId);
    
    // MD 찜하기 삭제
    int deleteMdWish(@Param("mdId") int mdId, @Param("userId") String userId);
    
    // MD 찜하기 여부 확인
    int selectMdWishCount(@Param("mdId") int mdId, @Param("userId") String userId);
    
    // MD 찜 개수 조회
    int selectMdWishTotalCount(@Param("mdId") int mdId);
    
    // 디버깅용: 모든 MD 조회
    List<Md> selectAllMds(@Param("userId") String userId);
    
    // 가게 목록 조회 (MD 추가용)
    List<Map<String, Object>> selectHotplaceList();
    
    // 가게 검색 (MD 추가용)
    List<Map<String, Object>> searchHotplaces(@Param("keyword") String keyword);
    
    // MD 찜 목록 삭제 (MD 삭제 시)
    int deleteMdWishes(@Param("mdId") int mdId);
    
    // MD명 검색 (자동완성용)
    List<Map<String, Object>> searchMdNames(@Param("keyword") String keyword);
}