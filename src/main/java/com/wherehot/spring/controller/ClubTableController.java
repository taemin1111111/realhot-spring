package com.wherehot.spring.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/clubtable")
public class ClubTableController {
    
    // 클럽 테이블 예약 페이지 (기존 JSP Include 방식 유지)
    @GetMapping("")
    public String clubTableReservation(Model model) {
        // 기존 JSP Include 방식 유지
        model.addAttribute("mainPage", "clubtable/clubtable.jsp");
        return "index";
    }
}
