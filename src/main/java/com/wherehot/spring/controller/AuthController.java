package com.wherehot.spring.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
public class AuthController {
    
    // 로그인 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/login")
    public String loginForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "login/loginModal.jsp");
        return "index";
    }
    
    // 회원가입 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/signup")
    public String signupForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "login/join.jsp");
        return "index";
    }
    
    // 네이버 회원가입 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("/signup/naver")
    public String naverSignupForm(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "login/naverJoin.jsp");
        return "index";
    }
}
