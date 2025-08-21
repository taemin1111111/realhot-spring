package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.MemberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class AdminController {
    
    @Autowired
    private MemberService memberService;
    
    // 관리자 메인 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/admin")
    public String adminMain(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "adminpage/admin.jsp");
        return "index";
    }
    
    // 회원 관리 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/admin/members")
    public String adminMembers(@RequestParam(defaultValue = "1") int page,
                             Model model) {
        
        List<Member> memberList = memberService.findAllMembers(page, 10);
        int totalCount = memberService.countMembers();
        
        model.addAttribute("memberList", memberList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalCount", totalCount);
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "adminpage/member.jsp");
        return "index";
    }
    
    // 신고 관리 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/admin/reports")
    public String adminReports(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "adminpage/report.jsp");
        return "index";
    }
}
