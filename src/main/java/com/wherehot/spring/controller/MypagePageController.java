package com.wherehot.spring.controller;

import com.wherehot.spring.entity.Member;
import com.wherehot.spring.service.MemberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

@Controller
public class MypagePageController {
    
    @Autowired
    private MemberService memberService;
    
    // 마이페이지 메인 (기존 JSP Include 방식 유지)
    @GetMapping("/mypage")
    public String mypageMain(Model model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication != null && authentication.isAuthenticated() && 
            !authentication.getName().equals("anonymousUser")) {
            
            String username = authentication.getName();
            Member member = memberService.findByUserid(username);
            model.addAttribute("member", member);
        }
        
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "mypage/mypageMain.jsp");
        return "index";
    }
    
    // 마이페이지 위시리스트 (기존 JSP Include 방식 유지)
    @GetMapping("/mypage/wishlist")
    public String mypageWishlist(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "mypage/mywishlist.jsp");
        return "index";
    }
    
    // 마이페이지 MD 리스트 (기존 JSP Include 방식 유지)
    @GetMapping("/mypage/mdlist")
    public String mypageMdList(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "mypage/mymdlist.jsp");
        return "index";
    }
}
