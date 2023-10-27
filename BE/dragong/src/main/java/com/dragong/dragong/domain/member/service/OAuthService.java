package com.dragong.dragong.domain.member.service;

public interface OAuthService {

    String getGoogleEmailInfo(String accessToken);

    String getNaverEmailInfo(String accessToken);

}
