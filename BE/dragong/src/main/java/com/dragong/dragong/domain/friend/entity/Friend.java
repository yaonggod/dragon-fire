package com.dragong.dragong.domain.friend.entity;

import com.dragong.dragong.global.common.BaseTimeEntity;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor
public class Friend extends BaseTimeEntity {
//    @Id
//    @Column(columnDefinition = "BINARY(16)")
//    private UUID fromMember;
//
//    @Id
//    @Column(columnDefinition = "BINARY(16)")
//    private UUID toMember;

    @EmbeddedId
    private FriendPk friendPk;

    @Column
    @Enumerated(EnumType.STRING)
    private FriendStatus friendStatus;

    @Column
    private int win = 0;

    @Column
    private int lose = 0;

    @Builder
    public Friend(FriendPk friendPk, FriendStatus friendStatus) {
        this.friendPk = friendPk;
        this.friendStatus = friendStatus;
    }

    public void updateFriendStatus(FriendStatus friendStatus) {
        this.friendStatus = friendStatus;
    }

    public void updateWin() {
        this.win++;
    }

    public void updateLose() {
        this.lose++;
    }

}
