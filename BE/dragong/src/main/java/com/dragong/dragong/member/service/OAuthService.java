package com.dragong.dragong.member.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import java.io.IOException;

public interface OAuthService {

    String getGoogleEmailInfo(String accessToken);

    String getNaverEmailInfo(String accessToken);

}
