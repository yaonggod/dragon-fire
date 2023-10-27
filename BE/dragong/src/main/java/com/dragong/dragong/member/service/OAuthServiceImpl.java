package com.dragong.dragong.member.service;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.http.HttpHeaders;

@Service
@RequiredArgsConstructor
public class OAuthServiceImpl implements OAuthService {

    private WebClient webClient;

    // 구글에 userInfo(email) 요청 (외부 api 요청)
    @Override
    public String getGoogleEmailInfo(String accessToken) {

        webClient = WebClient.create("https://www.googleapis.com/oauth2/v2/userinfo");

        Map<String, Object> response =
                webClient
                        .get()
                        .uri(uriBuilder ->
                                uriBuilder
                                        .queryParam("access_token", accessToken)
                                        .build())
                        .retrieve()
                        .bodyToMono(Map.class)
                        .block();

        String email = response.get("email").toString();

        return email;
    }

    // 네이버 인증 서버에 AccessToken 보내서 정보 받아오기
    @Override
    public String getNaverEmailInfo(String accessToken) {

        // 해더에 AT 넣기
        webClient = WebClient.builder().
                baseUrl("https://openapi.naver.com/v1/nid/me").
                defaultHeader(HttpHeaders.AUTHORIZATION, String.format("Bearer %s", accessToken)).build();

        // response를 map 형태로 받아오기
        Map<String, Object> response = webClient.get().uri("").retrieve().bodyToMono(Map.class).block();

        // response 안에 response 객체가 한 번 더 들어있음
        String res = response.get("response").toString();

        // 객체에서 이메일 뽑아내기
        String email = res.split(", ")[1].split("=")[1].trim();

        return email;

    }
}
