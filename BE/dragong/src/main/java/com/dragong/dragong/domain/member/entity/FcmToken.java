package com.dragong.dragong.domain.member.entity;

import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class FcmToken extends BaseTimeEntity {
    @Id
    private UUID memberId;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY)
    private Member member;

    @Column
    private String fcmToken;
}
