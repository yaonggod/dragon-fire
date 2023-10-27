package com.dragong.dragong.domain.member.entity.auth;

import com.dragong.dragong.domain.member.entity.Member;
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
public class NaverAuth {

    @Id
    private UUID memberId;

    @MapsId
    @OneToOne(fetch = FetchType.LAZY)
    private Member member;

    @Column
    private String email;

    @Builder
    public NaverAuth(Member member, String email) {
        this.member = member;
        this.email = email;
    }
}
