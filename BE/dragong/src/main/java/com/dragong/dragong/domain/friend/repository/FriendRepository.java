package com.dragong.dragong.domain.friend.repository;

import com.dragong.dragong.domain.friend.entity.Friend;
import com.dragong.dragong.domain.friend.entity.FriendPk;
import com.dragong.dragong.domain.friend.entity.FriendStatus;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FriendRepository extends JpaRepository<Friend, FriendPk> {

    // DISCONNECTED가 아닌 나의 모든 친구 상태를 불러오기
    List<Friend> findByFromMemberFriendStatusNot(UUID fromMember, FriendStatus friendStatus);

}
