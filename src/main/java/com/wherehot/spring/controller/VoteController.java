package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.VoteService;
import com.wherehot.spring.service.AuthService;
import com.wherehot.spring.service.SecurityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * 투표 관련 REST API 컨트롤러
 */
@RestController
@RequestMapping("/api/vote")
public class VoteController {
    
    private static final Logger logger = LoggerFactory.getLogger(VoteController.class);
    
    @Autowired
    private VoteService voteService;
    
    @Autowired
    private AuthService authService;
    
    @Autowired
    private SecurityUtils securityUtils;
    
    /**
     * 현재 핫플레이스 투표 (JWT 토큰 기반)
     */
    @PostMapping("/now-hot")
    public ResponseEntity<Map<String, Object>> voteNowHot(
            @RequestParam("hotplaceId") int hotplaceId,
            @RequestParam("crowd") String congestion,
            @RequestParam("gender") String genderRatio,
            @RequestParam("wait") String waitTime,
            @RequestHeader(value = "Authorization", required = false) String token,
            HttpServletRequest request) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            logger.info("🔥 투표 API 호출 - hotplaceId: {}, crowd: {}, gender: {}, wait: {}", 
                       hotplaceId, congestion, genderRatio, waitTime);
            
            // 1. 보안 정보 수집
            String userAgent = request.getHeader("User-Agent");
            String ipAddress = getClientIpAddress(request);
            
            // 2. 투표자 식별 (JWT 토큰 또는 IP)
            String voterId = null;
            if (token != null && token.startsWith("Bearer ")) {
                try {
                    Member member = authService.getUserFromToken(token.substring(7));
                    voterId = member.getUserid();
                    logger.info("로그인 사용자 투표: {}, IP: {}", voterId, ipAddress);
                } catch (Exception e) {
                    logger.warn("JWT 토큰 검증 실패, 익명 투표로 처리");
                }
            }
            
            if (voterId == null) {
                // 비로그인 시: 디바이스 핑거프린트로 고유 식별자 생성
                String deviceFingerprint = securityUtils.generateDeviceFingerprint(request);
                voterId = "anonymous|" + deviceFingerprint;
                logger.info("익명 사용자 투표: {}, IP: {}, DeviceFP: {}", voterId, ipAddress, deviceFingerprint);
            }
            
            // 3. User-Agent 기반 봇 감지
            if (securityUtils.isBotUserAgent(userAgent)) {
                logger.warn("봇 User-Agent 감지: IP={}, User-Agent={}", ipAddress, userAgent);
                response.put("success", false);
                response.put("message", "봇으로 의심되는 접근입니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            // 4. 보안 검증
            boolean isVpnProxy = securityUtils.isVpnOrProxy(ipAddress);
            int riskScore = securityUtils.calculateRiskScore(ipAddress, userAgent, isVpnProxy);
            
            if (isVpnProxy) {
                logger.warn("VPN/Proxy 사용자 감지: IP={}, User-Agent={}", ipAddress, userAgent);
                // VPN 사용자에 대한 추가 검증 또는 제한 로직
            }
            
            if (riskScore > 70) {
                logger.warn("높은 위험도 점수: {}, IP={}, User-Agent={}", riskScore, ipAddress, userAgent);
                response.put("success", false);
                response.put("message", "보안상의 이유로 투표가 제한되었습니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            // 4. 입력값 검증
            if (congestion == null || genderRatio == null || waitTime == null) {
                response.put("success", false);
                response.put("message", "잘못된 입력값입니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 5. 투표 처리 (보안 정보 포함)
            boolean success = ((com.wherehot.spring.service.impl.VoteServiceImpl) voteService)
                .addNowHotVoteWithSecurity(hotplaceId, voterId, congestion, genderRatio, waitTime, userAgent, ipAddress);
            
            if (success) {
                response.put("success", true);
                response.put("message", "투표가 완료되었습니다!");
                
                // 4. 업데이트된 투표 통계 반환
                Map<String, Object> voteStats = voteService.getNowHotVoteStats(hotplaceId);
                response.put("stats", voteStats);
                
                logger.info("투표 완료 - hotplaceId: {}, voterId: {}", hotplaceId, voterId);
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "이미 투표하셨습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (RuntimeException e) {
            // 비즈니스 로직 오류 (중복 투표, 제한 등)
            logger.warn("투표 제한: {}", e.getMessage());
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            logger.error("투표 처리 중 시스템 오류 발생", e);
            response.put("success", false);
            response.put("message", "투표 처리 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 클라이언트 IP 주소 추출
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty() && !"unknown".equalsIgnoreCase(xRealIp)) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    /**
     * 투표 통계 조회
     */
    @GetMapping("/stats/{hotplaceId}")
    public ResponseEntity<Map<String, Object>> getVoteStats(@PathVariable int hotplaceId) {
        try {
            Map<String, Object> stats = voteService.getNowHotVoteStats(hotplaceId);
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            logger.error("투표 통계 조회 중 오류 발생", e);
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "통계 조회 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    /**
     * 찜 상태 확인 (JWT 토큰 필수)
     */
    @GetMapping("/wish/check/{hotplaceId}")
    public ResponseEntity<Map<String, Object>> checkWish(
            @PathVariable int hotplaceId,
            @RequestHeader("Authorization") String token) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (!token.startsWith("Bearer ")) {
                response.put("result", false);
                response.put("message", "로그인이 필요합니다.");

                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            Member member = authService.getUserFromToken(token.substring(7));
            boolean isWished = voteService.isWished(hotplaceId, member.getUserid());
            
            response.put("result", isWished);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("찜 상태 확인 중 오류 발생", e);
            response.put("result", false);
            response.put("message", "확인 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * 찜하기/찜취소 (JWT 토큰 필수)
     */
    @PostMapping("/wish")
    public ResponseEntity<Map<String, Object>> toggleWish(
            @RequestParam("hotplaceId") int hotplaceId,
            @RequestHeader("Authorization") String token) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (!token.startsWith("Bearer ")) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            Member member = authService.getUserFromToken(token.substring(7));
            boolean isWished = voteService.toggleWish(hotplaceId, member.getUserid());
            
            response.put("success", true);
            response.put("isWished", isWished);
            response.put("message", isWished ? "찜 목록에 추가되었습니다." : "찜 목록에서 제거되었습니다.");
            
            // 업데이트된 찜 개수 반환
            int wishCount = voteService.getWishCount(hotplaceId);
            response.put("wishCount", wishCount);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("찜하기 처리 중 오류 발생", e);
            response.put("success", false);
            response.put("message", "처리 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
}