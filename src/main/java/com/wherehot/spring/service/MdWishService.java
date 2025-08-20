package com.wherehot.spring.service;

import com.wherehot.spring.entity.MdWish;

import java.util.List;

/**
 * MD 찜 서비스 인터페이스
 * Model1 MdWishDao 기능을 Spring Service로 변환
 */
public interface MdWishService {
    
    /**
     * MD 찜 추가
     * Model1: addMdWish(int mdId, String userid)
     */
    MdWish addMdWish(int mdId, String userid);
    
    /**
     * MD 찜 삭제
     * Model1: removeMdWish(int mdId, String userid)
     */
    boolean removeMdWish(int mdId, String userid);
    
    /**
     * 특정 MD가 찜되었는지 확인
     * Model1: isMdWished(int mdId, String userid)
     */
    boolean isMdWished(int mdId, String userid);
    
    /**
     * 사용자의 찜한 MD 목록 조회
     * Model1: getUserMdWishes(String userid)
     */
    List<MdWish> getUserMdWishes(String userid);
    
    /**
     * 특정 MD의 찜 개수 조회
     * Model1: getMdWishCount(int mdId)
     */
    int getMdWishCount(int mdId);
    
    /**
     * 사용자의 MD 찜 개수 조회
     * Model1: getUserMdWishCount(String userid)
     */
    int getUserMdWishCount(String userid);
    
    /**
     * 사용자의 찜한 MD 목록과 MD 정보 함께 조회
     * Model1: getUserMdWishesWithInfo(String userid, int limit)
     */
    List<MdWish> getUserMdWishesWithInfo(String userid, int limit);
    
    /**
     * 모든 찜 목록과 MD 정보 함께 조회 (관리자용)
     */
    List<MdWish> getAllMdWishesWithInfo();
}
