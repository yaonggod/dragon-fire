package com.dragong.dragong.global.util;

import com.dragong.dragong.member.entity.Role;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtUtil {

    @Value("${spring.jwt.secret}")
    private String secret;

    @Value("${spring.jwt.header}")
    private String Authorization_header;

    @Value("${spring.jwt.refresh_expire}")
    private long refreshExpirationTime;

    @Value("${spring.jwt.access_expire}")
    private long accessExpirationTime;


    public String generateAccessToken(UUID memberId, Role role) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("member", memberId.toString());
        claims.put("role", role.getRole());
        claims.put("sub", "access_token");

        Date curTime = new Date(System.currentTimeMillis());
        String token = Jwts.builder()
                .setHeaderParam("typ", "JWT")
                .setClaims(claims)
                .setIssuedAt(curTime)
                .setExpiration(new Date(curTime.getTime() + accessExpirationTime))
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
        return token;
    }

    public String generateRefreshToken() {
        Date curTime = new Date(System.currentTimeMillis());
        return Jwts.builder()
                .setHeaderParam("typ", "JWT")
                .setSubject("refresh_token")
                .setIssuedAt(curTime)
                .setExpiration(new Date(curTime.getTime() + refreshExpirationTime))
                .signWith(SignatureAlgorithm.HS512, secret)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(secret).parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public UUID extractMemberId(String token) {
        Claims claims = Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
        return UUID.fromString(claims.get("member", String.class));
    }

    public String extractRole(String token) {
        Claims claims = Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
        return claims.get("role", String.class);
    }


    public void setHeaderAccessToken(HttpServletResponse response, String accessToken) {
        response.setHeader(Authorization_header, "Bearer " + accessToken);
    }

    public void setHeaderRefreshToken(HttpServletResponse response, String refreshToken) {
        response.setHeader("refreshtoken", "Bearer " + refreshToken);
    }

}