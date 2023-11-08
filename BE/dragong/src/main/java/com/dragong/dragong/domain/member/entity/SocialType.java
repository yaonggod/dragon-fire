package com.dragong.dragong.domain.member.entity;

public enum SocialType {

    GOOGLE("GOOGLE"),
    NAVER("NAVER"),
    APPLE("APPLE");

    private final String socialType;

    SocialType(String socialType) {
        this.socialType = socialType;
    }

    public String getSocialType() {
        return socialType;
    }

}
