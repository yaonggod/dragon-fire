package com.dragong.dragong.domain.friend.repository;

import com.dragong.dragong.domain.friend.entity.Friend;
import com.dragong.dragong.domain.friend.entity.FriendPk;
import com.dragong.dragong.domain.friend.entity.FriendStatus;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FriendRepository extends JpaRepository<Friend, FriendPk> {

    // STATUS가 list에 있는 STATUS인 경우
    // 칭구 == FRIEND
    // 메시지 == REQUESTCHECK, ACCEPTCHECK
    // WAITING은 검색했을 때 대기중... 이런 식으로 뜬다
    List<Friend> findByFromMemberAndFriendStatusInOrderByCreatedTime(UUID fromMember, List<FriendStatus> friendStatusList);

    // 나와 너의 친구 사이를 찾아주기
    Optional<Friend> findByFromMemberAndToMember(UUID fromMember, UUID toMember);



}
