package com.wherehot.spring.mapper;

import com.wherehot.spring.entity.ContentInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 콘텐츠 정보 매퍼 인터페이스
 */
@Mapper
public interface ContentInfoMapper {
    
    /**
     * 특정 핫플레이스의 콘텐츠 정보 조회
     */
    ContentInfo getContentInfoByHotplaceId(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 콘텐츠 정보 저장
     */
    int insertContentInfo(ContentInfo contentInfo);
    
    /**
     * 콘텐츠 정보 수정
     */
    int updateContentInfo(ContentInfo contentInfo);
    
    /**
     * 콘텐츠 정보 삭제
     */
    int deleteContentInfo(@Param("hotplaceId") int hotplaceId);
    
    /**
     * 모든 콘텐츠 정보 조회 (관리자용)
     */
    List<ContentInfo> getAllContentInfos();
}
