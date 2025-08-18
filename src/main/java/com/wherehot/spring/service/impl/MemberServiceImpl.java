package com.wherehot.spring.service.impl;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.mapper.MemberMapper;
import com.wherehot.spring.service.MemberService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * 회원 서비스 구현체
 */
@Service
@Transactional
public class MemberServiceImpl implements MemberService {
    
    private static final Logger logger = LoggerFactory.getLogger(MemberServiceImpl.class);
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Member> findByUserid(String userid) {
        try {
            return memberMapper.findByUserid(userid);
        } catch (Exception e) {
            logger.error("Error finding member by userid: {}", userid, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Member> findByEmail(String email) {
        try {
            return memberMapper.findByEmail(email);
        } catch (Exception e) {
            logger.error("Error finding member by email: {}", email, e);
            return Optional.empty();
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Optional<Member> findByNickname(String nickname) {
        try {
            return memberMapper.findByNickname(nickname);
        } catch (Exception e) {
            logger.error("Error finding member by nickname: {}", nickname, e);
            return Optional.empty();
        }
    }
    
    @Override
    public Member saveMember(Member member) {
        try {
            // 생성 시간 설정
            if (member.getRegdate() == null) {
                member.setRegdate(LocalDateTime.now());
            }
            member.setUpdateDate(LocalDateTime.now());
            
            // 비밀번호 암호화 (이미 암호화되어 있지 않다면)
            if (member.getPasswd() != null && !member.getPasswd().startsWith("$2a$")) {
                member.setPasswd(passwordEncoder.encode(member.getPasswd()));
            }
            
            int result = memberMapper.insertMember(member);
            if (result > 0) {
                logger.info("Member saved successfully: {}", member.getUserid());
                return member;
            } else {
                throw new RuntimeException("회원 저장에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error saving member: {}", member.getUserid(), e);
            throw new RuntimeException("회원 저장 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public Member updateMember(Member member) {
        try {
            member.setUpdateDate(LocalDateTime.now());
            
            int result = memberMapper.updateMember(member);
            if (result > 0) {
                logger.info("Member updated successfully: {}", member.getUserid());
                return member;
            } else {
                throw new RuntimeException("회원 정보 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            logger.error("Error updating member: {}", member.getUserid(), e);
            throw new RuntimeException("회원 정보 수정 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean updatePassword(String userid, String oldPassword, String newPassword) {
        try {
            // 기존 회원 정보 조회
            Optional<Member> memberOpt = memberMapper.findByUserid(userid);
            if (memberOpt.isEmpty()) {
                throw new IllegalArgumentException("존재하지 않는 회원입니다.");
            }
            
            Member member = memberOpt.get();
            
            // 기존 비밀번호 확인
            if (!passwordEncoder.matches(oldPassword, member.getPasswd())) {
                throw new IllegalArgumentException("기존 비밀번호가 일치하지 않습니다.");
            }
            
            // 새 비밀번호 암호화 및 업데이트
            String encodedNewPassword = passwordEncoder.encode(newPassword);
            int result = memberMapper.updatePassword(userid, encodedNewPassword, LocalDateTime.now());
            
            if (result > 0) {
                logger.info("Password updated successfully for user: {}", userid);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error updating password for user: {}", userid, e);
            throw new RuntimeException("비밀번호 변경 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    public boolean resetPassword(String userid, String newPassword) {
        try {
            String encodedPassword = passwordEncoder.encode(newPassword);
            int result = memberMapper.updatePassword(userid, encodedPassword, LocalDateTime.now());
            
            if (result > 0) {
                logger.info("Password reset successfully for user: {}", userid);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error resetting password for user: {}", userid, e);
            return false;
        }
    }
    
    @Override
    public boolean updateMemberStatus(String userid, String status) {
        try {
            int result = memberMapper.updateStatus(userid, status, LocalDateTime.now());
            
            if (result > 0) {
                logger.info("Member status updated: {} -> {}", userid, status);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error updating member status: {} -> {}", userid, status, e);
            return false;
        }
    }
    
    @Override
    public boolean deleteMember(String userid) {
        try {
            int result = memberMapper.deleteMember(userid, LocalDateTime.now());
            
            if (result > 0) {
                logger.info("Member deleted (withdrew): {}", userid);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            logger.error("Error deleting member: {}", userid, e);
            return false;
        }
    }
    
    @Override
    public void updateLoginInfo(String userid) {
        try {
            Optional<Member> memberOpt = memberMapper.findByUserid(userid);
            if (memberOpt.isPresent()) {
                Member member = memberOpt.get();
                member.updateLoginInfo();
                memberMapper.updateLoginInfo(member);
                logger.debug("Login info updated for user: {}", userid);
            }
        } catch (Exception e) {
            logger.error("Error updating login info for user: {}", userid, e);
            // 로그인 정보 업데이트 실패는 치명적이지 않으므로 예외를 던지지 않음
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Member> findAllMembers(int page, int size) {
        try {
            int offset = page * size;
            return memberMapper.findAllMembers(offset, size);
        } catch (Exception e) {
            logger.error("Error finding all members: page={}, size={}", page, size, e);
            throw new RuntimeException("회원 목록 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int countMembers() {
        try {
            return memberMapper.countMembers();
        } catch (Exception e) {
            logger.error("Error counting members", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int countActiveMembers() {
        try {
            return memberMapper.countActiveMembers();
        } catch (Exception e) {
            logger.error("Error counting active members", e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Member> findByProvider(String provider) {
        try {
            return memberMapper.findByProvider(provider);
        } catch (Exception e) {
            logger.error("Error finding members by provider: {}", provider, e);
            throw new RuntimeException("소셜 로그인 회원 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Member> searchMembers(String keyword, String provider, String status, int page, int size) {
        try {
            int offset = page * size;
            return memberMapper.searchMembers(keyword, provider, status, offset, size);
        } catch (Exception e) {
            logger.error("Error searching members: keyword={}, provider={}, status={}", keyword, provider, status, e);
            throw new RuntimeException("회원 검색 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int countSearchMembers(String keyword, String provider, String status) {
        try {
            return memberMapper.countSearchMembers(keyword, provider, status);
        } catch (Exception e) {
            logger.error("Error counting search members: keyword={}, provider={}, status={}", keyword, provider, status, e);
            return 0;
        }
    }
    
    @Override
    public boolean updateProfileImage(String userid, String profileImageUrl) {
        // 프로필 이미지 컬럼이 없으므로 기능 비활성화
        logger.warn("Profile image update is disabled - column does not exist in database");
        return false;
        
        // try {
        //     int result = memberMapper.updateProfileImage(userid, profileImageUrl, LocalDateTime.now());
        //     
        //     if (result > 0) {
        //         logger.info("Profile image updated for user: {}", userid);
        //         return true;
        //     } else {
        //         return false;
        //     }
        // } catch (Exception e) {
        //     logger.error("Error updating profile image for user: {}", userid, e);
        //     return false;
        // }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Member> findRecentMembers(int limit) {
        try {
            return memberMapper.findRecentMembers(limit);
        } catch (Exception e) {
            logger.error("Error finding recent members: limit={}", limit, e);
            throw new RuntimeException("최근 가입 회원 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Member> findRecentLoginMembers(int limit) {
        try {
            return memberMapper.findRecentLoginMembers(limit);
        } catch (Exception e) {
            logger.error("Error finding recent login members: limit={}", limit, e);
            throw new RuntimeException("최근 로그인 회원 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Member> findDormantMembers(int days, int page, int size) {
        try {
            int offset = page * size;
            return memberMapper.findDormantMembers(days, offset, size);
        } catch (Exception e) {
            logger.error("Error finding dormant members: days={}, page={}, size={}", days, page, size, e);
            throw new RuntimeException("휴면 회원 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public int countDormantMembers(int days) {
        try {
            return memberMapper.countDormantMembers(days);
        } catch (Exception e) {
            logger.error("Error counting dormant members: days={}", days, e);
            return 0;
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public List<Member> findBirthdayMembers() {
        try {
            return memberMapper.findBirthdayMembers();
        } catch (Exception e) {
            logger.error("Error finding birthday members", e);
            throw new RuntimeException("생일 회원 조회 중 오류가 발생했습니다.", e);
        }
    }
    
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getMemberStatistics() {
        try {
            Map<String, Object> statistics = new HashMap<>();
            
            // 기본 통계
            statistics.put("totalMembers", memberMapper.countMembers());
            statistics.put("activeMembers", memberMapper.countActiveMembers());
            statistics.put("dormantMembers", memberMapper.countDormantMembers(90)); // 90일 이상 미접속
            
            // 월별 가입자 수
            statistics.put("monthlyStats", memberMapper.getMemberStatsByMonth());
            
            // 제공자별 통계
            statistics.put("providerStats", memberMapper.getMemberStatsByProvider());
            
            // 성별 통계
            statistics.put("genderStats", memberMapper.getMemberStatsByGender());
            
            // 연령대별 통계
            statistics.put("ageStats", memberMapper.getMemberStatsByAge());
            
            return statistics;
            
        } catch (Exception e) {
            logger.error("Error getting member statistics", e);
            throw new RuntimeException("회원 통계 조회 중 오류가 발생했습니다.", e);
        }
    }
}
