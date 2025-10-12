package com.wherehot.spring.config;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import java.time.Duration;

/**
 * 캐시 설정 - 고성능 처리를 위한 캐싱 시스템
 * 하루 1만명 동시 접속 지원
 */
@Configuration
@EnableCaching
public class CacheConfig {

    /**
     * 기본 캐시 매니저 (메모리 기반)
     * 운영환경에서는 Redis로 교체 권장
     */
    @Bean
    @Primary
    public CacheManager cacheManager() {
        ConcurrentMapCacheManager cacheManager = new ConcurrentMapCacheManager();
        
        // 캐시 이름 미리 등록 (성능 최적화)
        cacheManager.setCacheNames(java.util.Arrays.asList(
            "communityCategories",    // 커뮤니티 카테고리 목록
            "communityCategory",      // 개별 커뮤니티 카테고리
            "popularCommunityCategories", // 인기 커뮤니티 카테고리
            "hotplaces",              // 핫플레이스 목록 (새로 추가)
            "hotplace",               // 개별 핫플레이스
            "categories",             // 일반 카테고리 (새로 추가)
            "regions",                // 지역 정보 (새로 추가)
            "genres",                 // 장르 정보 (새로 추가)
            "posts",                  // 게시글
            "comments",               // 댓글
            "memberStats",            // 회원 통계
            "voteResults"             // 투표 결과
        ));
        
        // 동적 캐시 생성 허용
        cacheManager.setAllowNullValues(false);
        
        return cacheManager;
    }
    
    /**
     * Redis 캐시 매니저 (운영환경용 - 현재 비활성화)
     * Redis 사용하려면 application.properties에서 spring.autoconfigure.exclude 제거 필요
     */
    // @Bean
    // @ConditionalOnProperty(name = "spring.cache.type", havingValue = "redis")
    // public CacheManager redisCacheManager(RedisConnectionFactory redisConnectionFactory) {
    //     RedisCacheConfiguration cacheConfig = RedisCacheConfiguration.defaultCacheConfig()
    //         .entryTtl(Duration.ofMinutes(30))  // 30분 TTL
    //         .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
    //         .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer()));
    //
    //     return RedisCacheManager.builder(redisConnectionFactory)
    //         .cacheDefaults(cacheConfig)
    //         .build();
    // }
}

