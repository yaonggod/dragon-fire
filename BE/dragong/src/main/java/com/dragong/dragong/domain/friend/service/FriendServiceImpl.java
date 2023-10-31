package com.dragong.dragong.domain.friend.service;

import com.dragong.dragong.domain.friend.dto.request.FriendRequestDto;
import com.dragong.dragong.domain.friend.dto.response.FriendListDto;
import com.dragong.dragong.domain.friend.dto.response.FriendStatusResponseDto;
import com.dragong.dragong.domain.friend.dto.response.MessageListDto;
import com.dragong.dragong.domain.friend.entity.Friend;
import com.dragong.dragong.domain.friend.entity.FriendStatus;
import com.dragong.dragong.domain.friend.repository.FriendRepository;
import com.dragong.dragong.domain.member.entity.FcmToken;
import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.member.repository.FcmTokenRepository;
import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;
import com.dragong.dragong.domain.playResult.repository.PlayResultRepository;
import com.dragong.dragong.domain.playResult.service.PlayResultService;
import com.dragong.dragong.global.util.JwtUtil;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class FriendServiceImpl implements FriendService {

    private final FriendRepository friendRepository;
    private final MemberRepository memberRepository;
    private final MemberInfoRepository memberInfoRepository;
    private final FcmTokenRepository fcmTokenRepository;
    private final PlayResultRepository playResultRepository;

    private final PlayResultService playResultService;

    private final JwtUtil jwtUtil;

    @Override
    public FriendStatusResponseDto getFriendStatus(String accessToken, String refreshToken,
            String toNickname) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        // 상대방 검색하기
        MemberInfo toMemberInfo = memberInfoRepository.findMemberInfoByNicknameQuitFlagIsFalse(toNickname)
                .orElseThrow(() -> new NoSuchElementException());
        UUID toMember = toMemberInfo.getMemberId();
        FcmToken fcmToken = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember).get()
                .getFcmToken();

        // 나와 상대방의 관계 빌드하기
        FriendStatusResponseDto friendStatusResponseDto = FriendStatusResponseDto.builder()
                .toMember(toMember).toNickname(toMemberInfo.getNickname()).fcmToken(
                        fcmToken.getFcmToken()).build();

        // 관계 찾기
        Optional<Friend> friendResult = friendRepository.findByFromMemberAndToMember(fromMember, toMember);
        if (friendResult.isEmpty()) {
            friendStatusResponseDto.setFriendStatus(FriendStatus.NONE);
        } else {
            friendStatusResponseDto.setFriendStatus(friendResult.get().getFriendStatus());
        }

        return friendStatusResponseDto;
    }

    @Override
    public void requestFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        // 상대방
        UUID toMember = friendRequestDto.getToMember();

        // 관계 찾기 (나 - 상대) == 나는 상대가 수락하기를 기다리고 있어요
        Friend fromFriend = friendRepository.findByFromMemberAndToMember(fromMember, toMember)
            .orElseThrow(() -> new NoSuchElementException());
        fromFriend.updateFriendStatus(FriendStatus.WAITING);

        // 관계 찾기 (상대 - 나) == 상대가 요청을 읽기를 기다리고 있어요
        Friend toFriend = friendRepository.findByFromMemberAndToMember(toMember, fromMember)
                .orElseThrow(() -> new NoSuchElementException());
        toFriend.updateFriendStatus(FriendStatus.REQUESTCHECK);

        friendRepository.save(fromFriend);
        friendRepository.save(toFriend);

    }

    @Override
    public void acceptFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        // 상대방
        UUID toMember = friendRequestDto.getToMember();

        // 관계 찾기 (나 - 상대) == 나는 상대의 요청을 수락할거에요
        Friend fromFriend = friendRepository.findByFromMemberAndToMember(fromMember, toMember)
                .orElseThrow(() -> new NoSuchElementException());
        fromFriend.updateFriendStatus(FriendStatus.FRIEND);

        // 관계 찾기 (상대 - 나) == 상대가 수락한 거를 확인하기를 기다리고 있어요
        Friend toFriend = friendRepository.findByFromMemberAndToMember(toMember, fromMember)
                .orElseThrow(() -> new NoSuchElementException());
        toFriend.updateFriendStatus(FriendStatus.ACCEPTCHECK);

        friendRepository.save(fromFriend);
        friendRepository.save(toFriend);

    }

    @Override
    public void rejectFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        // 상대방
        UUID toMember = friendRequestDto.getToMember();

        // 관계 찾기 (나 - 상대) == 나는 상대의 요청을 거절할거에요
        Friend fromFriend = friendRepository.findByFromMemberAndToMember(fromMember, toMember)
                .orElseThrow(() -> new NoSuchElementException());
        fromFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

        // 관계 찾기 (상대 - 나) == 우리는 친구가 될 수 없어요
        Friend toFriend = friendRepository.findByFromMemberAndToMember(toMember, fromMember)
                .orElseThrow(() -> new NoSuchElementException());
        toFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

        friendRepository.save(fromFriend);
        friendRepository.save(toFriend);

    }

    @Override
    public void checkFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        // 상대방
        UUID toMember = friendRequestDto.getToMember();

        // 관계 찾기 (나 - 상대) == 나는 상대가 요청을 수락한거를 봤어요
        Friend fromFriend = friendRepository.findByFromMemberAndToMember(fromMember, toMember)
                .orElseThrow(() -> new NoSuchElementException());
        fromFriend.updateFriendStatus(FriendStatus.FRIEND);

        friendRepository.save(fromFriend);

    }

    @Override
    public void disconnectFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        // 상대방
        UUID toMember = friendRequestDto.getToMember();

        // 관계 찾기 (나 - 상대) == 우리는 이제부터 친구가 아닙니다.
        Friend fromFriend = friendRepository.findByFromMemberAndToMember(fromMember, toMember)
                .orElseThrow(() -> new NoSuchElementException());
        fromFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

        // 관계 찾기 (상대 - 나) == 우리는 이제부터 친구가 아닙니다.
        Friend toFriend = friendRepository.findByFromMemberAndToMember(toMember, fromMember)
                .orElseThrow(() -> new NoSuchElementException());
        toFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

        friendRepository.save(fromFriend);
        friendRepository.save(toFriend);

    }

    @Override
    public List<FriendListDto> getFriends(String accessToken, String refreshToken) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        int season = playResultService.getSeason();

        // 내 친구들 불러모아~
        List<FriendStatus> friendStatusList = new ArrayList<>();
        friendStatusList.add(FriendStatus.FRIEND);
        List<Friend> friendList = friendRepository.findByFromMemberAndFriendStatusInOrderByCreatedTime(fromMember, friendStatusList);

        // 친구들을 ResponseDto로 만들기
        List<FriendListDto> friendListDtoList = new ArrayList<>();
        for (Friend f : friendList) {

            // 친구 UUID
            UUID toMember = f.getFriendPk().getToMember();
            Optional<Member> to = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember);

            // 친구 전적
            Optional<PlayResult> playResult = playResultRepository.findById(new PlayResultEmpId(season, to.get()));
            int score = 0;
            int win = 0;
            int lose = 0;
            if (playResult.isPresent()) {
                score = playResult.get().getScore();
                win = playResult.get().getWin();
                lose = playResult.get().getLose();
            }

            FriendListDto friendListDto = FriendListDto.builder()
                    .toMember(toMember)
                    .toNickname(memberInfoRepository.findMemberInfoByMemberId(toMember).get().getNickname())
                    .score(score).win(win).lose(lose)
                    .build();
            friendListDtoList.add(friendListDto);
        }

        return friendListDtoList;
    }

    @Override
    public List<MessageListDto> getMessages(String accessToken, String refreshToken) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new NoSuchElementException());

        // 내 친구 후보들 불러모아~
        List<FriendStatus> friendStatusList = new ArrayList<>();
        friendStatusList.add(FriendStatus.REQUESTCHECK);
        friendStatusList.add(FriendStatus.ACCEPTCHECK);
        List<Friend> friendList = friendRepository.findByFromMemberAndFriendStatusInOrderByCreatedTime(fromMember, friendStatusList);

        int season = playResultService.getSeason();

        // 친구들을 ResponseDto로 만들기
        List<MessageListDto> messageListDtoList = new ArrayList<>();
        for (Friend f : friendList) {

            // 친구 UUID
            UUID toMember = f.getFriendPk().getToMember();
            Optional<Member> to = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember);

            // 친구 전적
            Optional<PlayResult> playResult = playResultRepository.findById(new PlayResultEmpId(season, to.get()));
            int score = 0;
            int win = 0;
            int lose = 0;
            if (playResult.isPresent()) {
                score = playResult.get().getScore();
                win = playResult.get().getWin();
                lose = playResult.get().getLose();
            }
            MessageListDto messageListDto = MessageListDto.builder()
                    .toMember(toMember)
                    .toNickname(memberInfoRepository.findMemberInfoByMemberId(toMember).get().getNickname())
                    .friendStatus(f.getFriendStatus())
                    .fcmToken(memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember).get().getFcmToken().getFcmToken())
                    .score(score).win(win).lose(lose)
                    .build();

            messageListDtoList.add(messageListDto);
        }
        return messageListDtoList;
    }
}
