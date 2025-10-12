package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Level;
import com.wherehot.spring.entity.DailyExpLog;
import com.wherehot.spring.entity.LevelLog;
import com.wherehot.spring.service.LevelService;
import com.wherehot.spring.service.ExpService;
import com.wherehot.spring.service.MemberService;
import com.wherehot.spring.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 레벨 및 경험치 관련 컨트롤러
 */
@RestController
@RequestMapping("/api/level")
public class LevelController {
    
    @Autowired
    private LevelService levelService;
    
    @Autowired
    private ExpService expService;
    
    @Autowired
    private MemberService memberService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    /**
     * 사용자의 레벨 정보 조회
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getUserLevelInfo(HttpServletRequest request) {
        try {
            String userId = getUserIdFromRequest(request);
            if (userId == null) {
                return ResponseEntity.status(401).body(Map.of("error", "로그인이 필요합니다."));
            }
            
            // 익명 사용자는 레벨 정보를 볼 수 없음
            if (userId.startsWith("anonymous|")) {
                return ResponseEntity.status(401).body(Map.of("error", "로그인이 필요합니다."));
            }
            
            // 사용자 정보 조회
            var memberOpt = memberService.findByUseridOptional(userId);
            if (memberOpt.isEmpty()) {
                return ResponseEntity.status(404).body(Map.of("error", "사용자를 찾을 수 없습니다."));
            }
            
            var member = memberOpt.get();
            int currentExp = member.getExp();
            
            // 레벨 정보 조회
            LevelService.LevelInfo levelInfo = levelService.getUserLevelInfo(currentExp);
            
            // 오늘 경험치 로그 조회
            DailyExpLog todayLog = expService.getTodayExpLog(userId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("currentLevel", levelInfo.getCurrentLevel());
            response.put("nextLevel", levelInfo.getNextLevel());
            response.put("currentExp", currentExp);
            response.put("expToNext", levelInfo.getExpToNext());
            response.put("progressPercentage", levelInfo.getProgressPercentage());
            response.put("todayExpLog", todayLog);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace(); // 스택 트레이스 출력
            return ResponseEntity.status(500).body(Map.of("error", "레벨 정보 조회 중 오류가 발생했습니다: " + e.getMessage()));
        }
    }
    
    /**
     * 모든 레벨 목록 조회
     */
    @GetMapping("/list")
    public ResponseEntity<List<Level>> getAllLevels() {
        try {
            List<Level> levels = levelService.getAllLevels();
            return ResponseEntity.ok(levels);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(List.of());
        }
    }
    
    /**
     * 데이터베이스 연결 테스트
     */
    @GetMapping("/test")
    public ResponseEntity<Map<String, Object>> testDatabase() {
        Map<String, Object> result = new HashMap<>();
        try {
            // 레벨 테이블 테스트
            List<Level> levels = levelService.getAllLevels();
            result.put("levelTable", "OK - " + levels.size() + " levels found");
            
            // 멤버 테이블 테스트 (level_id, exp 컬럼 확인)
            result.put("memberTable", "OK - level_id, exp columns should exist");
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("error", e.getMessage());
            result.put("stackTrace", e.getStackTrace());
            return ResponseEntity.status(500).body(result);
        }
    }
    
    /**
     * 사용자의 경험치 로그 조회
     */
    @GetMapping("/exp-logs")
    public ResponseEntity<List<DailyExpLog>> getUserExpLogs(
            HttpServletRequest request,
            @RequestParam(defaultValue = "7") int limit) {
        try {
            String userId = getUserIdFromRequest(request);
            if (userId == null || userId.startsWith("anonymous|")) {
                return ResponseEntity.status(401).body(List.of());
            }
            
            List<DailyExpLog> logs = expService.getRecentExpLogs(userId, limit);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(List.of());
        }
    }
    
    /**
     * 사용자의 레벨 변경 로그 조회
     */
    @GetMapping("/level-logs")
    public ResponseEntity<List<LevelLog>> getUserLevelLogs(
            HttpServletRequest request,
            @RequestParam(defaultValue = "10") int limit) {
        try {
            String userId = getUserIdFromRequest(request);
            if (userId == null || userId.startsWith("anonymous|")) {
                return ResponseEntity.status(401).body(List.of());
            }
            
            List<LevelLog> logs = expService.getRecentLevelLogs(userId, limit);
            return ResponseEntity.ok(logs);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(List.of());
        }
    }
    
    /**
     * 오늘 경험치 추가 가능 여부 확인
     */
    @GetMapping("/can-add-exp")
    public ResponseEntity<Map<String, Object>> canAddExpToday(
            HttpServletRequest request,
            @RequestParam String expType,
            @RequestParam(defaultValue = "1") int amount) {
        try {
            String userId = getUserIdFromRequest(request);
            if (userId == null || userId.startsWith("anonymous|")) {
                return ResponseEntity.status(401).body(Map.of("error", "로그인이 필요합니다."));
            }
            
            boolean canAdd = expService.canAddExpToday(userId, expType, amount);
            boolean canAddTotal = expService.canAddTotalExpToday(userId, amount);
            int todayTotal = expService.getTodayTotalExp(userId);
            int todayByType = expService.getTodayExpByType(userId, expType);
            
            Map<String, Object> response = new HashMap<>();
            response.put("canAdd", canAdd);
            response.put("canAddTotal", canAddTotal);
            response.put("todayTotal", todayTotal);
            response.put("todayByType", todayByType);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "경험치 확인 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * 경험치 추가 (테스트용)
     */
    @PostMapping("/add-exp")
    public ResponseEntity<Map<String, Object>> addExp(
            HttpServletRequest request,
            @RequestParam String expType,
            @RequestParam(defaultValue = "1") int amount) {
        try {
            String userId = getUserIdFromRequest(request);
            if (userId == null || userId.startsWith("anonymous|")) {
                return ResponseEntity.status(401).body(Map.of("error", "로그인이 필요합니다."));
            }
            
            boolean success = false;
            switch (expType) {
                case "vote":
                    success = expService.addVoteExp(userId, amount);
                    break;
                case "course":
                    success = expService.addCourseExp(userId, amount);
                    break;
                case "hpost":
                    success = expService.addHpostExp(userId, amount);
                    break;
                case "comment":
                    success = expService.addCommentExp(userId, amount);
                    break;
                case "like":
                    success = expService.addLikeExp(userId, amount);
                    break;
                case "wish":
                    success = expService.addWishExp(userId, amount);
                    break;
                default:
                    return ResponseEntity.badRequest().body(Map.of("error", "잘못된 경험치 타입입니다."));
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", success);
            if (success) {
                response.put("message", "경험치가 추가되었습니다.");
            } else {
                response.put("message", "오늘 경험치 한도에 도달했습니다.");
            }
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "경험치 추가 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * JWT 토큰에서 사용자 ID 추출
     */
    private String getUserIdFromRequest(HttpServletRequest request) {
        try {
            String token = jwtUtils.getTokenFromRequest(request);
            if (token != null && jwtUtils.validateToken(token)) {
                return jwtUtils.getUserIdFromToken(token);
            }
        } catch (Exception e) {
            // 토큰 파싱 실패 시 무시
        }
        return null;
    }
}
