package com.dragong.dragong.member.entity;

public enum SocialType {

    GOOGLE("Goolge"),
    NAVER("Naver"),
    KAKAO("Kakao");

    private final String socialType;

    SocialType(String socialType){
        this.socialType = socialType;
    }

    public String getSocialType(){
        return socialType;
    }

}
