package com.dragong.dragong.domain.friend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import java.io.Serializable;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Embeddable
public class FriendPk implements Serializable {

    @EqualsAndHashCode.Include
    @Column(columnDefinition = "BINARY(16)")
    private UUID fromMember;

    @EqualsAndHashCode.Include
    @Column(columnDefinition = "BINARY(16)")
    private UUID toMember;

}
