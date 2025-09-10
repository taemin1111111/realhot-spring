package com.wherehot.spring;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication(scanBasePackages = {"com.wherehot.spring", "DB", "hotplace_info", "Member", "hpost", "review", "Category", "Map", "wishList", "VoteNowHot", "EmailVerification", "Join", "Notice", "MD", "CCategory", "ClubGenre", "content_images", "content_info", "hottalk_comment", "hottalk_comment_vote", "hottalk_report", "hottalk_vote", "VoteHeatmap"})
@MapperScan("com.wherehot.spring.mapper")
public class TaeminspringApplication extends SpringBootServletInitializer {

	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
		return application.sources(TaeminspringApplication.class);
	}

	public static void main(String[] args) {
		SpringApplication.run(TaeminspringApplication.class, args);
	}

}
