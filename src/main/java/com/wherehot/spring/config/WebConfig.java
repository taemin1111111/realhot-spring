package com.wherehot.spring.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.CacheControl;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

import java.time.Duration;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    /**
     * JSP 뷰 리졸버 명시적 설정 (Spring Boot 3.x 호환성)
     */
    @Bean
    public InternalResourceViewResolver jspViewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setViewClass(JstlView.class);
        resolver.setPrefix("/WEB-INF/views/");
        resolver.setSuffix(".jsp");
        resolver.setOrder(1);
        resolver.setExposeContextBeansAsAttributes(true);
        resolver.setExposedContextBeanNames("*");
        return resolver;
    }

    /**
     * 정적 리소스 핸들러 설정 (성능 최적화)
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // CSS, JS 파일 (1시간 캐싱)
        registry.addResourceHandler("/css/**")
                .addResourceLocations("classpath:/static/css/", "/css/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        registry.addResourceHandler("/js/**")
                .addResourceLocations("classpath:/static/js/", "/js/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        // 이미지 파일 (24시간 캐싱)
        registry.addResourceHandler("/logo/**")
                .addResourceLocations("/logo/")
                .setCacheControl(CacheControl.maxAge(Duration.ofDays(1)));
        
        // 업로드 파일 (1시간 캐싱)
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("/uploads/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        // 기타 정적 리소스
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("classpath:/static/", "/")
                .setCacheControl(CacheControl.maxAge(Duration.ofMinutes(30)));
                
        // favicon 및 기타 파일들
        registry.addResourceHandler("/favicon.ico")
                .addResourceLocations("/favicon.ico")
                .setCacheControl(CacheControl.maxAge(Duration.ofDays(1)));
    }

    /**
     * 간단한 뷰 컨트롤러 등록 (컨트롤러 없이 바로 뷰 반환)
     */
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 에러 페이지 등록 - 통합 에러 페이지 사용
        registry.addViewController("/error").setViewName("error");
    }

    /**
     * 인터셉터 등록 (로깅, 인증 등)
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 추후 로깅 인터셉터나 인증 인터셉터 추가 예정
        // registry.addInterceptor(new LoggingInterceptor());
    }
}
