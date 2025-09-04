package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.Md;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

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
    
    // MD 삭제 (비활성화)
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
}