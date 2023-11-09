package com.dragong.dragong.domain.member.entity;

import com.dragong.dragong.domain.member.entity.auth.AppleAuth;
import com.dragong.dragong.domain.member.entity.auth.GoogleAuth;
import com.dragong.dragong.domain.member.entity.auth.NaverAuth;
import com.dragong.dragong.domain.member.entity.auth.RefreshToken;
import com.dragong.dragong.domain.playLog.entity.PlayLog;
import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Member extends BaseTimeEntity {

    @Id
    @Column(columnDefinition = "BINARY(16)")
    private UUID memberId;

    @Column
    @Enumerated(EnumType.STRING)
    private Role role;

    @Column
    @Enumerated(EnumType.STRING)
    private SocialType socialType;

    @Column(columnDefinition = "boolean default false")
    private boolean quitFlag;

    @OneToOne(mappedBy = "member",
            fetch = FetchType.LAZY,
            optional = false)
    private MemberInfo memberInfo;

    @OneToOne(mappedBy = "member",
            fetch = FetchType.LAZY)
    private GoogleAuth googleAuth;

    @OneToOne(mappedBy = "member",
            fetch = FetchType.LAZY)
    private NaverAuth naverAuth;

    @OneToOne(mappedBy = "member",
            fetch = FetchType.LAZY)
    private AppleAuth appleAuth;

    @OneToOne(mappedBy = "member",
            fetch = FetchType.LAZY)
    private RefreshToken refreshToken;


    // member 먼저 생성 후 memberInfo를 생성해야하므로 builder와 따로
    public void addMemberInfo(MemberInfo memberInfo) {
        this.memberInfo = memberInfo;
    }

    public void addGoogleAuth(GoogleAuth googleAuth) {
        this.googleAuth = googleAuth;
    }

    public void addNaverAuth(NaverAuth naverAuth) {
        this.naverAuth = naverAuth;
    }

    public void addAppleAuth(AppleAuth appleAuth) {
        this.appleAuth = appleAuth;
    }

    public void addRefreshToken(RefreshToken refreshToken) {
        this.refreshToken = refreshToken;
    }


    // FCM Token
    @OneToOne(mappedBy = "member",
            fetch = FetchType.LAZY)
    private FcmToken fcmToken;

    public void addFcmToken(FcmToken fcmToken) { this.fcmToken = fcmToken; }

    public void deleteMember() {
        this.quitFlag = true;
    }

    @Builder
    public Member(UUID memberId, Role role, SocialType socialType, boolean quitFlag) {
        this.memberId = memberId;
        this.role = role;
        this.socialType = socialType;
        this.quitFlag = quitFlag;
    }
}
