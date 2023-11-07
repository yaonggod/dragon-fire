package com.dragong.dragong.global.auth;

import com.dragong.dragong.domain.member.repository.RefreshTokenRepository;
import com.dragong.dragong.global.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
@RequiredArgsConstructor
public class JwtRequestFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final RefreshTokenRepository refreshTokenRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        // 토큰이 없어도 되는 uri인 경우에는 filter 로직을 생략
        if (uriWithNoTokens(request.getRequestURI())) {
            filterChain.doFilter(request, response);
            return;
        }
        final String authorizationHeader = request.getHeader("Authorization");
        final String refreshTokenHeader = request.getHeader("refreshToken");
        UUID memberId = null;
        String accessToken = null;
        String refreshToken = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")
                && refreshTokenHeader != null && refreshTokenHeader.startsWith("Bearer ")) {
            accessToken = authorizationHeader.substring(7);
            refreshToken = refreshTokenHeader.substring(7);
        }

        if (SecurityContextHolder.getContext().getAuthentication() == null) {

            // DB에 리프레시 토큰이 존재하는지 여부 확인
            if (refreshTokenRepository.findRefreshTokenByRefreshToken(refreshToken).isPresent()
                    && refreshTokenRepository.findRefreshTokenByRefreshToken(refreshToken).get()
                    .getRefreshToken().equals(refreshToken)) {
                // 액세스, 리프레시 토큰이 모두 유효한 경우
                if (jwtUtil.validateAccessToken(accessToken) && jwtUtil.validateRefreshToken(
                        refreshToken)) {
                    Map<String, String> newTokens = jwtUtil.refreshTokens(refreshToken);
                    memberId = jwtUtil.extractMemberId(accessToken);
                    UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(
                            memberId, null, new ArrayList<>());
                    token.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(token);
                    response.setHeader("Authorization", "Bearer " + newTokens.get("Authorization"));
                    response.setHeader("refreshToken", "Bearer " + newTokens.get("refreshToken"));
                    // 액세스 토큰만 만료된 경우
                } else if (!jwtUtil.validateAccessToken(accessToken)
                        && jwtUtil.validateRefreshToken(
                        refreshToken)) {
                    Map<String, String> newTokens = jwtUtil.refreshTokens(refreshToken);
                    memberId = jwtUtil.extractMemberId(newTokens.get("Authorization"));
                    UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(
                            memberId, null, new ArrayList<>());
                    token.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(token);
                    response.setHeader("Authorization", "Bearer " + newTokens.get("Authorization"));
                    response.setHeader("refreshToken", "Bearer " + newTokens.get("refreshToken"));

                    // 액세스, 리프레시 모두 만료된 경우
                } else if (!jwtUtil.validateAccessToken(accessToken)
                        && !jwtUtil.validateRefreshToken(
                        refreshToken)) {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "토큰 유효하지 않음");
                }

                // DB에 리프레시 토큰이 존재하지 않으면
            } else {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "토큰 유효하지 않음");
            }
        }
        filterChain.doFilter(request, response);
    }

    private boolean uriWithNoTokens(String uri) {
        return uri.startsWith("/oauth/login")
                || uri.startsWith("/oauth/GOOGLE")
                || uri.startsWith("/oauth/NAVER")
                || uri.startsWith("/member/nickname-duplicate")
                || uri.startsWith("/ws");
    }
}