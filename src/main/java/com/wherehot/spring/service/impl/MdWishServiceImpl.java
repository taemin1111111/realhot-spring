package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.MdWish;
import com.wherehot.spring.mapper.MdWishMapper;
import com.wherehot.spring.service.MdWishService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * MD 찜 서비스 구현체
 * Model1 MdWishDao 기능을 Spring Service로 변환
 */
@Service
@Transactional
public class MdWishServiceImpl implements MdWishService {
    
    private static final Logger logger = LoggerFactory.getLogger(MdWishServiceImpl.class);
    
    @Autowired
    private MdWishMapper mdWishMapper;
    
    @Override
    public MdWish addMdWish(int mdId, String userid) {
        try {
            logger.debug("MD 찜 추가 시작: mdId={}, userid={}", mdId, userid);
            
            // 이미 찜되어 있는지 확인
            if (isMdWished(mdId, userid)) {
                throw new RuntimeException("이미 찜한 MD입니다.");
            }
            
            MdWish mdWish = new MdWish(mdId, userid);
            mdWish.setCreatedAt(LocalDateTime.now());
            
            
            int result = mdWishMapper.insertMdWish(mdWish);
            if (result > 0) {
                logger.info("MD 찜 추가 성공: wishId={}, mdId={}, userid={}", 
                          mdWish.getWishId(), mdId, userid);
                return mdWish;
            } else {
                throw new RuntimeException("MD 찜 추가에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("MD 찜 추가 중 오류 발생: mdId={}, userid={}", mdId, userid, e);
            throw new RuntimeException("MD 찜 추가에 실패했습니다.", e);
        }
    }
    
    @Override
    public boolean removeMdWish(int mdId, String userid) {
        try {
            logger.debug("MD 찜 삭제 시작: mdId={}, userid={}", mdId, userid);
            
            int result = mdWishMapper.deleteMdWish(mdId, userid);
            boolean success = result > 0;
            
            if (success) {
                logger.info("MD 찜 삭제 성공: mdId={}, userid={}", mdId, userid);
            } else {
                logger.warn("MD 찜 삭제 실패 (찜이 존재하지 않음): mdId={}, userid={}", mdId, userid);
            }
            
            return success;
        } catch (Exception e) {
            logger.error("MD 찜 삭제 중 오류 발생: mdId={}, userid={}", mdId, userid, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean isMdWished(int mdId, String userid) {
        try {
            logger.debug("MD 찜 확인 시작: mdId={}, userid={}", mdId, userid);
            
            int count = mdWishMapper.countMdWish(mdId, userid);
            boolean isWished = count > 0;
            
            logger.debug("MD 찜 확인 결과: mdId={}, userid={}, isWished={}", mdId, userid, isWished);
            return isWished;
        } catch (Exception e) {
            logger.error("MD 찜 확인 중 오류 발생: mdId={}, userid={}", mdId, userid, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MdWish> getUserMdWishes(String userid) {
        try {
            logger.debug("사용자 MD 찜 목록 조회 시작: userid={}", userid);
            
            List<MdWish> wishList = mdWishMapper.findByUserid(userid);
            logger.info("사용자 MD 찜 목록 조회 완료: userid={}, count={}", userid, wishList.size());
            
            return wishList;
        } catch (Exception e) {
            logger.error("사용자 MD 찜 목록 조회 중 오류 발생: userid={}", userid, e);
            throw new RuntimeException("MD 찜 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getMdWishCount(int mdId) {
        try {
            logger.debug("MD 찜 개수 조회 시작: mdId={}", mdId);
            
            int count = mdWishMapper.countByMdId(mdId);
            logger.debug("MD 찜 개수 조회 완료: mdId={}, count={}", mdId, count);
            
            return count;
        } catch (Exception e) {
            logger.error("MD 찜 개수 조회 중 오류 발생: mdId={}", mdId, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getUserMdWishCount(String userid) {
        try {
            logger.debug("사용자 MD 찜 개수 조회 시작: userid={}", userid);
            
            int count = mdWishMapper.countByUserid(userid);
            logger.debug("사용자 MD 찜 개수 조회 완료: userid={}, count={}", userid, count);
            
            return count;
        } catch (Exception e) {
            logger.error("사용자 MD 찜 개수 조회 중 오류 발생: userid={}", userid, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MdWish> getUserMdWishesWithInfo(String userid, int limit) {
        try {
            logger.debug("사용자 MD 찜 목록과 정보 조회 시작: userid={}, limit={}", userid, limit);
            
            List<MdWish> wishList = mdWishMapper.findByUseridWithInfo(userid, limit);
            logger.info("사용자 MD 찜 목록과 정보 조회 완료: userid={}, count={}", userid, wishList.size());
            
            return wishList;
        } catch (Exception e) {
            logger.error("사용자 MD 찜 목록과 정보 조회 중 오류 발생: userid={}", userid, e);
            throw new RuntimeException("MD 찜 목록 조회에 실패했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<MdWish> getAllMdWishesWithInfo() {
        try {
            logger.debug("전체 MD 찜 목록과 정보 조회 시작 (관리자용)");
            
            List<MdWish> wishList = mdWishMapper.findAllWithInfo();
            logger.info("전체 MD 찜 목록과 정보 조회 완료: count={}", wishList.size());
            
            return wishList;
        } catch (Exception e) {
            logger.error("전체 MD 찜 목록과 정보 조회 중 오류 발생", e);
            throw new RuntimeException("MD 찜 목록 조회에 실패했습니다.", e);
        }
    }
}
