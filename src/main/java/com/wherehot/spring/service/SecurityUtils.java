package com.wherehot.spring.service;

import org.springframework.stereotype.Service;
import org.apache.commons.codec.digest.DigestUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import jakarta.servlet.http.HttpServletRequest;

/**
 * 보안 관련 유틸리티 서비스
 */
@Service
public class SecurityUtils {
    
    private static final Logger logger = LoggerFactory.getLogger(SecurityUtils.class);
    
    // 알려진 VPN/프록시 IP 대역 (예시)
    private static final List<String> VPN_IP_RANGES = Arrays.asList(
        "104.16.0.0/12",  // Cloudflare
        "172.16.0.0/12",  // Private range
        "10.0.0.0/8"      // Private range
    );
    
    /**
     * User-Agent 해시 생성
     */
    public String generateUserAgentHash(String userAgent) {
        if (userAgent == null || userAgent.trim().isEmpty()) {
            return "no-user-agent"; // null 대신 기본값으로 봇 감지
        }
        
        try {
            // User-Agent를 해시화하여 저장
            return DigestUtils.sha256Hex(userAgent);
        } catch (Exception e) {
            logger.error("User-Agent 해시 생성 실패: {}", e.getMessage());
            return "hash-error";
        }
    }
    
    /**
     * VPN/프록시 여부 판단
     */
    public boolean isVpnOrProxy(String ipAddress) {
        if (ipAddress == null || ipAddress.trim().isEmpty()) {
            return false;
        }
        
        try {
            // 1. 알려진 VPN IP 대역 체크
            if (isKnownVpnIp(ipAddress)) {
                logger.warn("알려진 VPN IP 감지: {}", ipAddress);
                return true;
            }
            
            // 2. 프라이빗 IP 대역 체크
            if (isPrivateIp(ipAddress)) {
                logger.warn("프라이빗 IP 감지: {}", ipAddress);
                return true;
            }
            
            // 3. 추가 VPN 감지 로직 (필요시 외부 API 호출)
            // return checkVpnService(ipAddress);
            
            return false;
            
        } catch (Exception e) {
            logger.error("VPN 감지 중 오류 발생: {}", e.getMessage());
            return false;
        }
    }
    
    /**
     * 위험도 점수 계산
     */
    public int calculateRiskScore(String ipAddress, String userAgent, boolean isVpnProxy) {
        int riskScore = 0;
        
        // 1. VPN/프록시 사용 시 +30점
        if (isVpnProxy) {
            riskScore += 30;
        }
        
        // 2. User-Agent가 없거나 비정상적인 경우 +20점
        if (userAgent == null || userAgent.trim().isEmpty()) {
            riskScore += 20;
        } else if (isSuspiciousUserAgent(userAgent)) {
            riskScore += 15;
        }
        
        // 3. IP 주소가 비정상적인 경우 +25점
        if (ipAddress == null || ipAddress.trim().isEmpty()) {
            riskScore += 25;
        } else if (isSuspiciousIp(ipAddress)) {
            riskScore += 20;
        }
        
        return Math.min(riskScore, 100); // 최대 100점
    }
    
    /**
     * 알려진 VPN IP 대역 체크
     */
    private boolean isKnownVpnIp(String ipAddress) {
        // 간단한 구현 (실제로는 더 정교한 IP 대역 체크 필요)
        return ipAddress.startsWith("104.16.") || 
               ipAddress.startsWith("172.16.") || 
               ipAddress.startsWith("10.");
    }
    
    /**
     * 프라이빗 IP 대역 체크
     */
    private boolean isPrivateIp(String ipAddress) {
        if (ipAddress == null) return false;
        
        return ipAddress.startsWith("192.168.") || 
               ipAddress.startsWith("10.") || 
               ipAddress.startsWith("172.16.") ||
               ipAddress.startsWith("172.17.") ||
               ipAddress.startsWith("172.18.") ||
               ipAddress.startsWith("172.19.") ||
               ipAddress.startsWith("172.20.") ||
               ipAddress.startsWith("172.21.") ||
               ipAddress.startsWith("172.22.") ||
               ipAddress.startsWith("172.23.") ||
               ipAddress.startsWith("172.24.") ||
               ipAddress.startsWith("172.25.") ||
               ipAddress.startsWith("172.26.") ||
               ipAddress.startsWith("172.27.") ||
               ipAddress.startsWith("172.28.") ||
               ipAddress.startsWith("172.29.") ||
               ipAddress.startsWith("172.30.") ||
               ipAddress.startsWith("172.31.");
    }
    
    /**
     * 의심스러운 User-Agent 체크
     */
    private boolean isSuspiciousUserAgent(String userAgent) {
        if (userAgent == null) return true;
        
        String lowerUserAgent = userAgent.toLowerCase();
        
        // 봇이나 스크립트로 의심되는 User-Agent
        return lowerUserAgent.contains("bot") ||
               lowerUserAgent.contains("crawler") ||
               lowerUserAgent.contains("spider") ||
               lowerUserAgent.contains("scraper") ||
               lowerUserAgent.contains("curl") ||
               lowerUserAgent.contains("wget") ||
               lowerUserAgent.contains("python") ||
               lowerUserAgent.contains("java") ||
               lowerUserAgent.contains("postman");
    }
    
    /**
     * 의심스러운 IP 체크
     */
    private boolean isSuspiciousIp(String ipAddress) {
        if (ipAddress == null) return true;
        
        // localhost나 비정상적인 IP
        return ipAddress.equals("127.0.0.1") ||
               ipAddress.equals("0.0.0.0") ||
               ipAddress.equals("::1") ||
               ipAddress.contains("localhost");
    }

    /**
     * User-Agent 해시 기반 봇 감지
     * @param userAgentHash User-Agent 해시값
     * @return 봇 의심 여부
     */
    public boolean isSuspiciousUserAgentHash(String userAgentHash) {
        if (userAgentHash == null) {
            return true; // User-Agent가 없으면 봇 의심
        }
        
        // 알려진 봇/스크립트 User-Agent 해시들
        Set<String> knownBotHashes = new HashSet<>(Arrays.asList(
            "no-user-agent", // User-Agent가 없는 경우
            "hash-error"     // 해시 생성 실패
            // 실제 봇 User-Agent들의 해시값들을 여기에 추가
            // 예: curl, python-requests, java-httpclient 등
        ));
        
        return knownBotHashes.contains(userAgentHash);
    }

    /**
     * 디바이스 핑거프린트 생성
     * @param request HTTP 요청 객체
     * @return 디바이스 핑거프린트 문자열
     */
    public String generateDeviceFingerprint(HttpServletRequest request) {
        StringBuilder fingerprint = new StringBuilder();
        
        // 1. IP 주소
        String ipAddress = getClientIpAddress(request);
        fingerprint.append(ipAddress).append("|");
        
        // 2. User-Agent
        String userAgent = request.getHeader("User-Agent");
        fingerprint.append(generateUserAgentHash(userAgent)).append("|");
        
        // 3. Accept-Language
        String acceptLanguage = request.getHeader("Accept-Language");
        if (acceptLanguage != null) {
            fingerprint.append(DigestUtils.sha256Hex(acceptLanguage)).append("|");
        } else {
            fingerprint.append("no-lang|");
        }
        
        // 4. Accept-Encoding
        String acceptEncoding = request.getHeader("Accept-Encoding");
        if (acceptEncoding != null) {
            fingerprint.append(DigestUtils.sha256Hex(acceptEncoding)).append("|");
        } else {
            fingerprint.append("no-encoding|");
        }
        
        // 5. Connection
        String connection = request.getHeader("Connection");
        if (connection != null) {
            fingerprint.append(connection).append("|");
        } else {
            fingerprint.append("no-connection|");
        }
        
        // 6. 시간대 (시간대별로 다른 핑거프린트)
        String timeSlot = getTimeSlot();
        fingerprint.append(timeSlot);
        
        return DigestUtils.sha256Hex(fingerprint.toString());
    }
    
    /**
     * 클라이언트 IP 주소 추출
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    /**
     * 시간대별 슬롯 계산 (1시간 단위)
     */
    private String getTimeSlot() {
        return String.valueOf(System.currentTimeMillis() / (1000 * 60 * 60)); // 1시간 단위
    }
    
    /**
     * IP별 동적 투표 제한 계산
     * @param ipAddress IP 주소
     * @param userAgentHash User-Agent 해시
     * @return 최대 허용 투표 수
     */
    public int calculateMaxVotesByIp(String ipAddress, String userAgentHash) {
        int baseLimit = 4; // 기본 제한
        
        // 1. 프라이빗 IP인 경우 더 관대하게
        if (isPrivateIp(ipAddress)) {
            baseLimit = 8; // 가정/사무실 환경 고려
        }
        
        // 2. VPN/프록시인 경우 더 엄격하게
        if (isVpnOrProxy(ipAddress)) {
            baseLimit = 2; // VPN 사용자 제한
        }
        
        // 3. 의심스러운 User-Agent인 경우 제한
        if (isSuspiciousUserAgentHash(userAgentHash)) {
            baseLimit = Math.min(baseLimit, 2);
        }
        
        // 4. 시간대별 조정 (심야 시간 더 엄격)
        int hour = java.time.LocalTime.now().getHour();
        if (hour >= 2 && hour <= 6) { // 새벽 2시-6시
            baseLimit = Math.min(baseLimit, 2);
        }
        
        return Math.max(baseLimit, 1); // 최소 1개는 허용
    }
    

    /**
     * User-Agent 패턴 기반 봇 감지
     * @param userAgent 원본 User-Agent 문자열
     * @return 봇 의심 여부
     */
    public boolean isBotUserAgent(String userAgent) {
        if (userAgent == null || userAgent.trim().isEmpty()) {
            return true;
        }
        
        String lowerUserAgent = userAgent.toLowerCase();
        
        // 봇/스크립트 패턴들
        String[] botPatterns = {
            "bot", "spider", "crawler", "scraper",
            "curl", "wget", "python-requests", "java-httpclient",
            "postman", "insomnia", "httpie", "apache-httpclient",
            "okhttp", "urllib", "requests", "httpx"
        };
        
        for (String pattern : botPatterns) {
            if (lowerUserAgent.contains(pattern)) {
                logger.warn("봇 User-Agent 감지: {}", userAgent);
                return true;
            }
        }
        
        // 화이트리스트 패턴 (정상적인 앱/브라우저)
        String[] whitelistPatterns = {
            "naver", "kakaotalk", "line", "instagram", "facebook", "twitter",
            "whatsapp", "telegram", "discord", "slack"
        };
        
        // 화이트리스트에 포함된 경우 정상 처리
        for (String pattern : whitelistPatterns) {
            if (lowerUserAgent.contains(pattern)) {
                logger.debug("화이트리스트 User-Agent 감지: {}", userAgent);
                return false;
            }
        }
        
        // 일반적인 브라우저 패턴이 없으면 의심
        String[] browserPatterns = {
            "mozilla", "chrome", "safari", "firefox", "edge", "opera", "webkit"
        };
        
        boolean hasBrowserPattern = false;
        for (String pattern : browserPatterns) {
            if (lowerUserAgent.contains(pattern)) {
                hasBrowserPattern = true;
                break;
            }
        }
        
        if (!hasBrowserPattern) {
            logger.warn("브라우저 패턴이 없는 User-Agent: {}", userAgent);
            return true;
        }
        
        return false;
    }
}
