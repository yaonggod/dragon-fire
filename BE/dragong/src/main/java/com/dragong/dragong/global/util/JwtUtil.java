package com.dragong.dragong.global.util;

import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.entity.Role;
import com.dragong.dragong.domain.member.entity.auth.RefreshToken;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.member.repository.RefreshTokenRepository;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import jakarta.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.crossstore.ChangeSetPersister.NotFoundException;
import org.springframework.stereotype.Component;

import java.util.Date;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    @Value("${spring.jwt.secret}")
    private String secret;

    @Value("${spring.jwt.header}")
    private String Authorization_header;

    @Value("${spring.jwt.refresh_expire}")
    private long refreshExpirationTime;

    @Value("${spring.jwt.access_expire}")
    private long accessExpirationTime;

    private final MemberRepository memberRepository;

    private final RefreshTokenRepository refreshTokenRepository;

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

    public boolean validateAccessToken(String token) {
        try {
            // secret 키와 일치한지 확인
            Claims claims = Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
            Date expirationDate = claims.getExpiration();

            // 현재 날짜와 만료일을 비교해서 현재 날짜보다 이전이면 만료, 현재 날짜보다 이후이면 유효
            return !expirationDate.before(new Date());
        } catch (Exception e) {
            return false;
        }
    }

    public boolean validateRefreshToken(String token) {
        try {
            // secret 키와 일치한지 확인
            Claims claims = Jwts.parser().setSigningKey(secret).parseClaimsJws(token).getBody();
            Date expirationDate = claims.getExpiration();

            refreshTokenRepository.findRefreshTokenByRefreshToken(token)
                    .orElseThrow(() -> new NotFoundException());

            // 현재 날짜와 만료일을 비교해서 현재 날짜보다 이전이면 만료, 현재 날짜보다 이후이면 유효
            return !expirationDate.before(new Date());
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

    /*
     * 리프레시 토큰이 유효하고 액세스 토큰이 만료된 경우
     * 액세스 토큰을 재발급해줌과 동시에 리프레시 토큰을 재발급해준다.
     */

    @Transactional
    public Map<String, String> refreshTokens(String refreshToken) {
        if (validateAccessToken(refreshToken)) {
            Claims refreshTokenClaims = Jwts.parser().setSigningKey(secret)
                    .parseClaimsJws(refreshToken).getBody();

            Member member = memberRepository.findMemberByRefreshToken_RefreshToken(refreshToken)
                    .orElseThrow(() ->
                            new IllegalArgumentException());

            RefreshToken refreshTokenEntity = member.getRefreshToken();

            // 새로운 액세스 토큰 생성
            String newAccessToken = generateAccessToken(member.getMemberId(), Role.USER);

            // 새로운 리프레시 토큰 생성
            String newRefreshToken = generateRefreshToken();

            // DB에 새로운 리프레시 토큰 저장
            refreshTokenEntity.updateRefreshToken(newRefreshToken);

            Map<String, String> tokens = new HashMap<>();
            tokens.put("Authorization", newAccessToken);
            tokens.put("refreshToken", newRefreshToken);
            return tokens;
        }
        return null;
    }

}