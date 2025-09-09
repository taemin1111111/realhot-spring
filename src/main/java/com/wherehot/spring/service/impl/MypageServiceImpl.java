package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.mapper.MypageMapper;
import com.wherehot.spring.service.MypageService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 마이페이지 서비스 구현체
 */
@Service
@Transactional
public class MypageServiceImpl implements MypageService {
    
    private static final Logger logger = LoggerFactory.getLogger(MypageServiceImpl.class);
    
    @Autowired
    private MypageMapper mypageMapper;
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserWishlist(String userid, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> wishlist = mypageMapper.getUserWishlist(userid, offset, size);
            int totalCount = mypageMapper.getUserWishlistCount(userid);
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            Map<String, Object> result = new HashMap<>();
            result.put("wishlist", wishlist);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("totalPages", totalPages);
            result.put("size", size);
            
            return result;
        } catch (Exception e) {
            logger.error("Error getting user wishlist for userid: {}", userid, e);
            Map<String, Object> result = new HashMap<>();
            result.put("wishlist", new java.util.ArrayList<>());
            result.put("totalCount", 0);
            result.put("currentPage", page);
            result.put("totalPages", 0);
            result.put("size", size);
            return result;
        }
    }
    
    /**
     * 찜 목록 조회 (컨트롤러용)
     */
    public Map<String, Object> getWishlist(String userid, int page, int size) {
        return getUserWishlist(userid, page, size);
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserPosts(String userid, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> posts = mypageMapper.getUserPosts(userid, offset, size);
            int totalCount = mypageMapper.getUserPostsCount(userid);
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            Map<String, Object> result = new HashMap<>();
            result.put("posts", posts);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("totalPages", totalPages);
            result.put("size", size);
            
            return result;
        } catch (Exception e) {
            logger.error("Error getting user posts for userid: {}", userid, e);
            Map<String, Object> result = new HashMap<>();
            result.put("posts", new java.util.ArrayList<>());
            result.put("totalCount", 0);
            result.put("currentPage", page);
            result.put("totalPages", 0);
            result.put("size", size);
            return result;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserCoursePosts(String userid, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> posts = mypageMapper.getUserCoursePosts(userid, offset, size);
            int totalCount = mypageMapper.getUserCourseCount(userid);
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            Map<String, Object> result = new HashMap<>();
            result.put("posts", posts);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("totalPages", totalPages);
            result.put("size", size);
            
            return result;
        } catch (Exception e) {
            logger.error("Error getting user course posts for userid: {}", userid, e);
            Map<String, Object> result = new HashMap<>();
            result.put("posts", new java.util.ArrayList<>());
            result.put("totalCount", 0);
            result.put("currentPage", page);
            result.put("totalPages", 0);
            result.put("size", size);
            return result;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserHottalkPosts(String userid, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> posts = mypageMapper.getUserHottalkPosts(userid, offset, size);
            int totalCount = mypageMapper.getUserHpostCount(userid);
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            Map<String, Object> result = new HashMap<>();
            result.put("posts", posts);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("totalPages", totalPages);
            result.put("size", size);
            
            return result;
        } catch (Exception e) {
            logger.error("Error getting user hottalk posts for userid: {}", userid, e);
            Map<String, Object> result = new HashMap<>();
            result.put("posts", new java.util.ArrayList<>());
            result.put("totalCount", 0);
            result.put("totalPages", 0);
            result.put("size", size);
            return result;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserComments(String userid, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> comments = mypageMapper.getUserComments(userid, offset, size);
            int totalCount = mypageMapper.getUserCommentsCount(userid);
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            Map<String, Object> result = new HashMap<>();
            result.put("comments", comments);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("totalPages", totalPages);
            result.put("size", size);
            
            return result;
        } catch (Exception e) {
            logger.error("Error getting user comments for userid: {}", userid, e);
            Map<String, Object> result = new HashMap<>();
            result.put("comments", new java.util.ArrayList<>());
            result.put("totalCount", 0);
            result.put("currentPage", page);
            result.put("totalPages", 0);
            result.put("size", size);
            return result;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Member getUserInfo(String userid) {
        try {
            logger.info("Calling mypageMapper.getUserInfo for userid: {}", userid);
            Member member = mypageMapper.getUserInfo(userid);
            if (member != null) {
                logger.info("Retrieved member from mapper - userid: {}, nickname: {}, regdate: {}", 
                    member.getUserid(), member.getNickname(), member.getRegdate());
            } else {
                logger.warn("getUserInfo returned null from mapper for userid: {}", userid);
            }
            return member;
        } catch (Exception e) {
            logger.error("Error getting user info for userid: {}", userid, e);
            return null;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getUserStats(String userid) {
        try {
            Map<String, Object> stats = new HashMap<>();
            
            // course 게시글 수
            int courseCount = mypageMapper.getUserCourseCount(userid);
            stats.put("courseCount", courseCount);
            
            // hpost 게시글 수
            int hpostCount = mypageMapper.getUserHpostCount(userid);
            stats.put("hpostCount", hpostCount);
            
            // 총 게시글 수
            int totalPostCount = courseCount + hpostCount;
            stats.put("postCount", totalPostCount);
            
            // 댓글 수
            int commentCount = mypageMapper.getUserCommentsCount(userid);
            stats.put("commentCount", commentCount);
            
            // 위시리스트 수
            int wishCount = mypageMapper.getUserWishlistCount(userid);
            stats.put("wishCount", wishCount);
            
            // 총 활동 수
            int totalActivity = totalPostCount + commentCount + wishCount;
            stats.put("totalActivity", totalActivity);
            
            return stats;
        } catch (Exception e) {
            logger.error("Error getting user stats for userid: {}", userid, e);
            Map<String, Object> stats = new HashMap<>();
            stats.put("courseCount", 0);
            stats.put("hpostCount", 0);
            stats.put("postCount", 0);
            stats.put("commentCount", 0);
            stats.put("wishCount", 0);
            stats.put("totalActivity", 0);
            return stats;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getUserCourseCount(String userid) {
        try {
            return mypageMapper.getUserCourseCount(userid);
        } catch (Exception e) {
            logger.error("Error getting user course count for userid: {}", userid, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int getUserHpostCount(String userid) {
        try {
            return mypageMapper.getUserHpostCount(userid);
        } catch (Exception e) {
            logger.error("Error getting user hpost count for userid: {}", userid, e);
            return 0;
        }
    }
    
    @Override
    @Transactional
    public boolean updateProfile(String userid, String nickname, String email) {
        try {
            // 기존 회원 정보 조회
            Member member = memberMapper.findByUserid(userid).orElse(null);
            if (member == null) {
                logger.error("Member not found for userid: {}", userid);
                return false;
            }
            
            // 닉네임 중복 확인 (자신 제외)
            if (!nickname.equals(member.getNickname())) {
                var existingMember = memberMapper.findByNickname(nickname);
                if (existingMember.isPresent()) {
                    logger.error("Nickname already exists: {}", nickname);
                    return false;
                }
            }
            
            // 정보 업데이트 (닉네임만)
            member.setNickname(nickname);
            
            int result = mypageMapper.updateProfile(member);
            return result > 0;
            
        } catch (Exception e) {
            logger.error("Error updating profile for userid: {}", userid, e);
            return false;
        }
    }
    
    @Override
    @Transactional
    public boolean changePassword(String userid, String currentPassword, String newPassword) {
        try {
            // 기존 회원 정보 조회
            Member member = memberMapper.findByUserid(userid).orElse(null);
            if (member == null) {
                logger.error("Member not found for userid: {}", userid);
                return false;
            }
            
            // 현재 비밀번호 확인
            if (!passwordEncoder.matches(currentPassword, member.getPassword())) {
                logger.error("Current password does not match for userid: {}", userid);
                return false;
            }
            
            // 새 비밀번호 암호화
            String encodedNewPassword = passwordEncoder.encode(newPassword);
            
            // 비밀번호 업데이트
            int result = mypageMapper.updatePassword(userid, encodedNewPassword);
            return result > 0;
            
        } catch (Exception e) {
            logger.error("Error changing password for userid: {}", userid, e);
            return false;
        }
    }
    
    @Override
    @Transactional
    public boolean withdrawMember(String userid, String password) {
        try {
            // 기존 회원 정보 조회
            Member member = memberMapper.findByUserid(userid).orElse(null);
            if (member == null) {
                logger.error("Member not found for userid: {}", userid);
                return false;
            }
            
            // 네이버 로그인 사용자가 아닌 경우에만 비밀번호 확인
            if (!"naver".equals(member.getProvider())) {
                if (password == null || password.trim().isEmpty()) {
                    logger.error("Password is required for non-Naver users: {}", userid);
                    return false;
                }
                
                // 비밀번호 확인
                if (!passwordEncoder.matches(password, member.getPassword())) {
                    logger.error("Password does not match for userid: {}", userid);
                    return false;
                }
            }
            
            // 탈퇴 시 관련 데이터 삭제 처리
            deleteUserRelatedData(userid);
            
            // 회원 탈퇴 처리 (상태를 'W'로 변경 - Withdrawn)
            int result = mypageMapper.updateMemberStatus(userid, "W");
            
            if (result > 0) {
                logger.info("Member withdrawal completed successfully: {}", userid);
                return true;
            } else {
                logger.error("Failed to update member status for userid: {}", userid);
                return false;
            }
            
        } catch (Exception e) {
            logger.error("Error withdrawing member for userid: {}", userid, e);
            return false;
        }
    }
    
    /**
     * 탈퇴 시 사용자 관련 데이터 삭제
     */
    private void deleteUserRelatedData(String userid) {
        try {
            logger.info("Deleting related data for user: {}", userid);
            
            // 1. 찜 목록 삭제
            mypageMapper.deleteAllWishlistByUserid(userid);
            
            // 2. MD 찜 목록 삭제
            mypageMapper.deleteAllMdWishlistByUserid(userid);
            
            // 3. 게시글 삭제
            mypageMapper.deleteAllCoursePostsByUserid(userid);
            mypageMapper.deleteAllHottalkPostsByUserid(userid);
            
            // 4. 댓글 삭제
            mypageMapper.deleteAllHottalkCommentsByUserid(userid);
            mypageMapper.deleteAllCourseCommentsByUserid(userid);
            
            // 5. 투표 기록 삭제
            mypageMapper.deleteAllHottalkVotesByUserid(userid);
            mypageMapper.deleteAllHottalkCommentVotesByUserid(userid);
            mypageMapper.deleteAllCourseReactionsByUserid(userid);
            mypageMapper.deleteAllCourseCommentReactionsByUserid(userid);
            
            // 6. 신고 기록 삭제
            mypageMapper.deleteAllHottalkReportsByUserid(userid);
            mypageMapper.deleteAllCourseReportsByUserid(userid);
            
            logger.info("Related data deletion completed for user: {}", userid);
            
        } catch (Exception e) {
            logger.error("Error deleting related data for user: {}", userid, e);
            // 데이터 삭제 실패해도 탈퇴는 진행 (로깅만)
        }
    }
    
    @Override
    public boolean verifyPassword(String userid, String password) {
        try {
            Member member = memberMapper.findByUserid(userid).orElse(null);
            if (member == null) {
                logger.error("Member not found for userid: {}", userid);
                return false;
            }
            
            // 비밀번호 확인 (해시화된 비밀번호와 비교)
            return passwordEncoder.matches(password, member.getPassword());
            
        } catch (Exception e) {
            logger.error("Error verifying password for userid: {}", userid, e);
            return false;
        }
    }
    
    /**
     * 찜 해제
     */
    @Transactional
    public boolean removeWish(String userid, Long wishId) {
        try {
            // 찜 해제 처리
            int result = mypageMapper.removeWish(userid, wishId);
            return result > 0;
            
        } catch (Exception e) {
            logger.error("Error removing wish for userid: {}, wishId: {}", userid, wishId, e);
            return false;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getMdWishList(String userid, int page, int size) {
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> mdWishList = mypageMapper.getMdWishList(userid, offset, size);
            int totalCount = mypageMapper.getMdWishListCount(userid);
            int totalPages = (int) Math.ceil((double) totalCount / size);
            
            Map<String, Object> result = new HashMap<>();
            result.put("mdWishList", mdWishList);
            result.put("totalCount", totalCount);
            result.put("currentPage", page);
            result.put("totalPages", totalPages);
            result.put("size", size);
            
            return result;
        } catch (Exception e) {
            logger.error("Error getting MD wish list for userid: {}", userid, e);
            Map<String, Object> result = new HashMap<>();
            result.put("mdWishList", new java.util.ArrayList<>());
            result.put("totalCount", 0);
            result.put("currentPage", page);
            result.put("totalPages", 0);
            result.put("size", size);
            return result;
        }
    }
    
    @Override
    @Transactional
    public boolean removeMdWish(String userid, int wishId) {
        try {
            // MD 찜 해제 처리
            int result = mypageMapper.removeMdWish(userid, wishId);
            return result > 0;
            
        } catch (Exception e) {
            logger.error("Error removing MD wish for userid: {}, wishId: {}", userid, wishId, e);
            return false;
        }
    }
}
