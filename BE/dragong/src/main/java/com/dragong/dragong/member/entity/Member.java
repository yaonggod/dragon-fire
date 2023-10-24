package com.dragong.dragong.member.entity;

import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
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

    // member 먼저 생성 후 memberInfo를 생성해야하므로 builder와 따로
    public void addMemberInfo(MemberInfo memberInfo){
        this.memberInfo = memberInfo;
    }

    @Builder
    public Member(UUID memberId, Role role, SocialType socialType, boolean quitFlag) {
        this.memberId = memberId;
        this.role = role;
        this.socialType = socialType;
        this.quitFlag = quitFlag;
    }
}
