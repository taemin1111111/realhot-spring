package com.wherehot.spring.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

/**
 * Spring Security 설정 - JWT 기반 무상태 인증 (대용량 트래픽 대응)
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    @Autowired
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    
    @Autowired
    private CustomOAuth2UserService customOAuth2UserService;
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        // BCrypt 강도 조정: 성능 최적화를 위해 8로 설정
        // 하루 1만명 처리를 위한 성능 최적화 (10 -> 8)
        // 강도 8: ~25ms (보안과 성능의 최적 균형점)
        return new BCryptPasswordEncoder(8);
    }
    
    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter();
    }
    
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // CSRF 비활성화 (JWT 사용)
            .csrf(csrf -> csrf.disable())
            
            // CORS 설정
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            
            // 세션 비활성화 (JWT 기반 무상태 인증)
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // 인증 예외 처리
            .exceptionHandling(exception -> exception
                .authenticationEntryPoint(jwtAuthenticationEntryPoint))
            
            // 경로별 인증 설정 (Model1 호환성 - 대부분 페이지 로그인 없이 접근 가능)
            .authorizeHttpRequests(auth -> auth
                // 정적 리소스는 인증 불필요
                .requestMatchers("/css/**", "/js/**", "/images/**", "/logo/**", "/uploads/**", "/favicon.ico").permitAll()
                
                // == 로그인 없이 접근 가능한 모든 페이지들 (Model1 호환성) ==
                .requestMatchers("/", "/main/**").permitAll()                     // 메인 페이지
                .requestMatchers("/review/**").permitAll()                        // 리뷰 페이지
                .requestMatchers("/clubmd/**", "/clubtable/**").permitAll()       // 클럽 관련
                .requestMatchers("/notice/**").permitAll()                        // 공지사항
                .requestMatchers("/login/**").permitAll()                         // 로그인/회원가입
                .requestMatchers("/hpost/**").permitAll()                         // 핫플썰 게시판 관련 모든 경로 허용 (JWT 필터는 작동)
                
                // == API 경로들 ==
                .requestMatchers("/api/auth/**").permitAll()                      // 인증 API
                .requestMatchers("/oauth2/**", "/login/oauth2/**").permitAll()    // OAuth2
                .requestMatchers("/api/main/**").permitAll()                      // 메인 페이지 API (투표, 이미지 등)
                .requestMatchers("/api/review/**").permitAll()                    // 리뷰 API
                .requestMatchers("/api/community/**").permitAll()                 // 커뮤니티 API (로그인 체크는 서비스에서)
                .requestMatchers("/api/club/**").permitAll()                      // 클럽 관련 API
                .requestMatchers("/api/md/**").permitAll()                        // MD API (찜 기능 포함)
                .requestMatchers("/api/notice/**").permitAll()                    // 공지사항 API
                
                // == 관리자 전용 ==
                .requestMatchers("/adminpage/**").hasAuthority("ROLE_ADMIN")      // 관리자 페이지
                .requestMatchers("/api/admin/**").hasAuthority("ROLE_ADMIN")      // 관리자 API
                
                // == 로그인 필요한 페이지 ==
                .requestMatchers("/mypage/**").authenticated()                    // 마이페이지
                
                // == 나머지 모든 요청 허용 ==
                .anyRequest().permitAll())
            
            // 기본 로그인 폼 비활성화
            .formLogin(form -> form.disable())
            
            // HTTP Basic 비활성화  
            .httpBasic(basic -> basic.disable())
            
            // OAuth2 로그인 설정 (네이버, 구글 등)
            .oauth2Login(oauth2 -> oauth2
                .loginPage("/")
                .defaultSuccessUrl("/", true)
                .userInfoEndpoint(userInfo -> userInfo
                    .userService(customOAuth2UserService))
                .successHandler(new OAuth2AuthenticationSuccessHandler())
                .failureHandler(new OAuth2AuthenticationFailureHandler()))
            
            // JWT 인증 필터 추가
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // 허용할 오리진 설정
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        
        // 허용할 HTTP 메서드
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        
        // 허용할 헤더
        configuration.setAllowedHeaders(Arrays.asList("*"));
        
        // 인증 정보 허용
        configuration.setAllowCredentials(true);
        
        // 노출할 헤더
        configuration.setExposedHeaders(Arrays.asList("Authorization"));
        
        // 캐시 시간 설정
        configuration.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        source.registerCorsConfiguration("/oauth2/**", configuration);
        source.registerCorsConfiguration("/hpost/**", configuration);
        source.registerCorsConfiguration("/**", configuration); // 모든 경로에 CORS 설정 적용
        
        return source;
    }
}