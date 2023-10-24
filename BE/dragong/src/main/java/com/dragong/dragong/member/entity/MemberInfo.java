package com.dragong.dragong.member.entity;

import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import java.util.UUID;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class MemberInfo extends BaseTimeEntity {

    @Id
    private UUID memberId;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY)
    private Member member;

    @Column(unique = true) // 닉네임 중복 불가
    private String nickname;

    @Builder
    public MemberInfo(Member member, String nickname){
        this.member = member;
        this.nickname = nickname;
    }
}
