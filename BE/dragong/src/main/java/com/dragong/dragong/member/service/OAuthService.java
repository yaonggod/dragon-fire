package com.dragong.dragong.member.service;

public interface OAuthService {

    String getGoogleEmailInfo(String accessToken);

    String getNaverEmailInfo(String accessToken);

}
