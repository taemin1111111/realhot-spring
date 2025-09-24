package com.wherehot.spring.service;

import com.wherehot.spring.entity.ContentInfo;

import java.util.List;

/**
 * 콘텐츠 정보 서비스 인터페이스
 */
public interface ContentInfoService {
    
    /**
     * 특정 핫플레이스의 콘텐츠 정보 조회
     */
    ContentInfo getContentInfoByHotplaceId(int hotplaceId);
    
    /**
     * 콘텐츠 정보 저장 또는 수정
     */
    boolean saveOrUpdateContentInfo(int hotplaceId, String contentText);
    
    /**
     * 콘텐츠 정보 삭제
     */
    boolean deleteContentInfo(int hotplaceId);
    
    /**
     * 모든 콘텐츠 정보 조회 (관리자용)
     */
    List<ContentInfo> getAllContentInfos();
}
