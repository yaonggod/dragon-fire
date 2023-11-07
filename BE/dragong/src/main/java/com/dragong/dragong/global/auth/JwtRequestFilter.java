package com.dragong.dragong.global.auth;

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

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        final String authorizationHeader = request.getHeader("Authorization");
        final String refreshTokenHeader = request.getHeader("refreshToken");
        UUID memberId = null;
        String accessToken = null;
        String refreshToken = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")
                && refreshTokenHeader != null && refreshTokenHeader.startsWith("Bearer ")) {
            accessToken = authorizationHeader.substring(7);
            refreshToken = refreshTokenHeader.substring(7);
            memberId = jwtUtil.extractMemberId(accessToken);
        }

        if (memberId != null && SecurityContextHolder.getContext().getAuthentication() == null) {

            // 액세스, 리프레시 토큰이 모두 유효한 경우
            if (jwtUtil.validateAccessToken(accessToken) && jwtUtil.validateRefreshToken(
                    refreshToken)) {
                UsernamePasswordAuthenticationToken token = new UsernamePasswordAuthenticationToken(
                        memberId, null, new ArrayList<>());
                token.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(token);

                // 액세스 토큰만 만료된 경우
            } else if (!jwtUtil.validateAccessToken(accessToken) && jwtUtil.validateRefreshToken(
                    refreshToken)) {
                Map<String, String> newTokens = jwtUtil.refreshTokens(refreshToken);
                response.setHeader("Authorization", "Bearer " + newTokens.get("Authorization"));
                response.setHeader("refreshToken", "Bearer " + newTokens.get("refreshToken"));

                // 액세스, 리프레시 모두 만료된 경우
            } else if (!jwtUtil.validateAccessToken(accessToken) && !jwtUtil.validateRefreshToken(
                    refreshToken)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("토큰 유효하지 않음");
            }
        }
        filterChain.doFilter(request, response);
    }
}