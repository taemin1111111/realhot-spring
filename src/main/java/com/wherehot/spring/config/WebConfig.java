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
     * JSP 뷰 리졸버 명시적 설정 (Spring Boot 3.x + WAR 배포)
     */
    @Bean
    public InternalResourceViewResolver jspViewResolver() {
        InternalResourceViewResolver resolver = new InternalResourceViewResolver();
        resolver.setViewClass(JstlView.class);
        resolver.setPrefix("/WEB-INF/views/");
        resolver.setSuffix(".jsp");
        resolver.setOrder(1);
        return resolver;
    }

    /**
     * 정적 리소스 핸들러 설정 (WAR 배포용 - Tomcat 10)
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // CSS 파일 (1시간 캐싱)
        registry.addResourceHandler("/css/**")
                .addResourceLocations("classpath:/META-INF/resources/css/", "/css/", "/WEB-INF/classes/static/css/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        // JS 파일 (1시간 캐싱)
        registry.addResourceHandler("/js/**")
                .addResourceLocations("classpath:/META-INF/resources/js/", "/js/", "/WEB-INF/classes/static/js/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        // 로고/이미지 파일 (24시간 캐싱)
        registry.addResourceHandler("/logo/**")
                .addResourceLocations("classpath:/META-INF/resources/logo/", "/logo/", "/WEB-INF/classes/static/logo/")
                .setCacheControl(CacheControl.maxAge(Duration.ofDays(1)));
        
        // 폰트 파일 (7일 캐싱)
        registry.addResourceHandler("/fonts/**")
                .addResourceLocations("classpath:/META-INF/resources/fonts/", "/fonts/", "/WEB-INF/classes/static/fonts/")
                .setCacheControl(CacheControl.maxAge(Duration.ofDays(7)));
        
        // 업로드 파일 (1시간 캐싱) - adsave 포함 모든 업로드 파일
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:/opt/tomcat/webapps/taeminspring/uploads/", "/uploads/", "classpath:/META-INF/resources/uploads/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        // Context Path 중복 문제 해결을 위한 추가 핸들러
        registry.addResourceHandler("/taeminspring/uploads/**")
                .addResourceLocations("file:/opt/tomcat/webapps/taeminspring/uploads/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        // Nginx sub_filter로 인한 경로 문제 해결을 위한 핸들러
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:/opt/tomcat/webapps/taeminspring/uploads/")
                .setCacheControl(CacheControl.maxAge(Duration.ofHours(1)));
        
        // 기타 정적 리소스
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("classpath:/META-INF/resources/", "/resources/", "/WEB-INF/classes/static/")
                .setCacheControl(CacheControl.maxAge(Duration.ofMinutes(30)));
                
        // favicon
        registry.addResourceHandler("/favicon.ico")
                .addResourceLocations("classpath:/META-INF/resources/favicon.ico", "/favicon.ico", "file:/opt/tomcat/webapps/taeminspring/favicon.ico")
                .setCacheControl(CacheControl.maxAge(Duration.ofDays(1)));
    }

    /**
     * 간단한 뷰 컨트롤러 등록 (컨트롤러 없이 바로 뷰 반환)
     */
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 에러 페이지 등록
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
