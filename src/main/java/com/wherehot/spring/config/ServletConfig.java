package com.wherehot.spring.config;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.web.filter.HiddenHttpMethodFilter;
import org.springframework.web.multipart.support.MultipartFilter;



@Configuration
public class ServletConfig {

    
    /**
     * 파일 업로드를 위한 Multipart 필터
     */
    @Bean
    public FilterRegistrationBean<MultipartFilter> multipartFilter() {
        FilterRegistrationBean<MultipartFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new MultipartFilter());
        registrationBean.addUrlPatterns("/*");
        registrationBean.setOrder(2);
        return registrationBean;
    }

    /**
     * HTTP Method Override 필터 (PUT, DELETE 등을 POST로 처리)
     */
    @Bean
    public FilterRegistrationBean<HiddenHttpMethodFilter> hiddenHttpMethodFilter() {
        FilterRegistrationBean<HiddenHttpMethodFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new HiddenHttpMethodFilter());
        registrationBean.addUrlPatterns("/*");
        registrationBean.setOrder(3);
        return registrationBean;
    }

}
