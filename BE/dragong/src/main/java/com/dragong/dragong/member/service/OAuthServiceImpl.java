package com.dragong.dragong.member.service;

import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

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
}
