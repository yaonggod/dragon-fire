package com.dragong.dragong.domain.friend.service;

import com.dragong.dragong.domain.friend.dto.request.FriendRequestDto;
import com.dragong.dragong.domain.friend.dto.response.FriendListDto;
import com.dragong.dragong.domain.friend.dto.response.FriendStatusResponseDto;
import com.dragong.dragong.domain.friend.dto.response.MessageListDto;
import com.dragong.dragong.domain.friend.entity.Friend;
import com.dragong.dragong.domain.friend.entity.FriendPk;
import com.dragong.dragong.domain.friend.entity.FriendStatus;
import com.dragong.dragong.domain.friend.repository.FriendRepository;
import com.dragong.dragong.domain.member.entity.FcmToken;
import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.entity.PlayResultEmpId;
import com.dragong.dragong.domain.playResult.repository.PlayResultRepository;
import com.dragong.dragong.domain.playResult.service.PlayResultService;
import com.dragong.dragong.global.util.JwtUtil;

import com.google.auth.oauth2.GoogleCredentials;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class FriendServiceImpl implements FriendService {

    private final FriendRepository friendRepository;
    private final MemberRepository memberRepository;
    private final MemberInfoRepository memberInfoRepository;
    private final PlayResultRepository playResultRepository;

    private final PlayResultService playResultService;

    private final JwtUtil jwtUtil;

    @Override
    public FriendStatusResponseDto getFriendStatus(String accessToken, String refreshToken,
            String toNickname) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 상대방 검색하기
        MemberInfo toMemberInfo = memberInfoRepository.findMemberInfoByNicknameAndMember_QuitFlagIsFalse(toNickname)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        UUID toMember = toMemberInfo.getMemberId();

        // 만약에 상대랑 나랑 똑같으면 에러 띄우기
        if (fromMember.equals(toMember)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }

        FcmToken fcmToken = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember).get()
                .getFcmToken();

        // 나와 상대방의 관계 빌드하기
        FriendStatusResponseDto friendStatusResponseDto = FriendStatusResponseDto.builder()
                .toMember(toMember).toNickname(toMemberInfo.getNickname()).build();
        // FCM token은 있을수도 없을수도 있음
        if (fcmToken != null) {
            friendStatusResponseDto.setFcmToken(fcmToken.getFcmToken());
        }

        int season = playResultService.getSeason();
        Optional<Member> to = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember);
        Optional<PlayResult> playResult = playResultRepository.findById(new PlayResultEmpId(season, to.get()));

        int score = 0;
        int win = 0;
        int lose = 0;
        if (playResult.isPresent()) {
            score = playResult.get().getScore();
            win = playResult.get().getWin();
            lose = playResult.get().getLose();
        }

        // 이사람의 전적
        friendStatusResponseDto.setWin(win);
        friendStatusResponseDto.setLose(lose);
        friendStatusResponseDto.setScore(score);


        // 관계 찾기
        Optional<Friend> friendResult = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(fromMember, toMember);
        if (friendResult.isEmpty()) {
            // 엔티티가 없어요
            friendStatusResponseDto.setFriendStatus(FriendStatus.NONE);
            friendStatusResponseDto.setFriendWin(0);
            friendStatusResponseDto.setFriendLose(0);
        } else {
            // 기존의 관계가 존재해요
            friendStatusResponseDto.setFriendStatus(friendResult.get().getFriendStatus());
            // 상대 전적
            friendStatusResponseDto.setFriendWin(friendResult.get().getWin());
            friendStatusResponseDto.setFriendLose(friendResult.get().getLose());
        }
        return friendStatusResponseDto;
    }

    @Override
    public void requestFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto, HttpServletResponse httpServletResponse) {

        // firebase AT를 헤더에 보내서 기기보고 스토리지에 등록하라고 하기
        try {
            httpServletResponse.setHeader("firebase", "Bearer " + getFirebaseAccessToken());
        } catch (Exception e) {
        }

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 상대방
        UUID toMember = friendRequestDto.getToMember();
        MemberInfo toMemberInfo = memberInfoRepository.findMemberInfoByMemberId(toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 만약에 상대랑 나랑 똑같으면 에러 띄우기
        if (fromMember.equals(toMember)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }

        // 관계 찾기 (나 - 상대) == 나는 상대가 수락하기를 기다리고 있어요
        Optional<Friend> fromFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(fromMember, toMember);
        // 관계 찾기 (상대 - 나) == 상대가 요청을 읽기를 기다리고 있어요
        Optional<Friend> toFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(toMember, fromMember);

        // 상태가 없으면
        if (fromFriend.isEmpty()) {
            // 서로 관계를 새로 빌드합니다
            // 나는 수락하기를 기다리고
            Friend newFromFriend = Friend.builder()
                    .friendPk(new FriendPk(fromMember, toMember))
                    .friendStatus(FriendStatus.WAITING)
                    .build();
            // 상대는 확인해야할 요청이 생깁니다
            Friend newToFriend = Friend.builder()
                    .friendPk(new FriendPk(toMember, fromMember))
                    .friendStatus(FriendStatus.REQUESTCHECK)
                    .build();
            friendRepository.save(newFromFriend);
            friendRepository.save(newToFriend);



        } else {
            if (fromFriend.get().getFriendStatus().equals(FriendStatus.DISCONNECTED) && toFriend.get().getFriendStatus().equals(FriendStatus.DISCONNECTED)) {
                // 아니면 그냥 존재하는 관계의 상태만 바꿔주기
                fromFriend.get().updateFriendStatus(FriendStatus.WAITING);
                toFriend.get().updateFriendStatus(FriendStatus.REQUESTCHECK);
                friendRepository.save(fromFriend.get());
                friendRepository.save(toFriend.get());
            }
            else {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
            }
        }
    }

    @Override
    public void acceptFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto, HttpServletResponse httpServletResponse) {

        // firebase AT를 헤더에 보내서 기기보고 스토리지에 등록하라고 하기
        try {
            httpServletResponse.setHeader("firebase", "Bearer " + getFirebaseAccessToken());
        } catch (Exception e) {
        }

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 상대방
        UUID toMember = friendRequestDto.getToMember();
        MemberInfo toMemberInfo = memberInfoRepository.findMemberInfoByMemberId(toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 만약에 상대랑 나랑 똑같으면 에러 띄우기
        if (fromMember.equals(toMember)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }

        // 관계 찾기 (나 - 상대) == 나는 상대의 요청을 수락할거에요
        Friend fromFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(fromMember, toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 관계 찾기 (상대 - 나) == 상대가 수락한 거를 확인하기를 기다리고 있어요
        Friend toFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(toMember, fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        if (fromFriend.getFriendStatus().equals(FriendStatus.REQUESTCHECK) && toFriend.getFriendStatus().equals(FriendStatus.WAITING)) {
            fromFriend.updateFriendStatus(FriendStatus.FRIEND);
            toFriend.updateFriendStatus(FriendStatus.ACCEPTCHECK);

            friendRepository.save(fromFriend);
            friendRepository.save(toFriend);


        }
        else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }
    }

    @Override
    public void rejectFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 상대방
        UUID toMember = friendRequestDto.getToMember();
        MemberInfo toMemberInfo = memberInfoRepository.findMemberInfoByMemberId(toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 만약에 상대랑 나랑 똑같으면 에러 띄우기
        if (fromMember.equals(toMember)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }

        // 관계 찾기 (나 - 상대) == 나는 상대의 요청을 거절할거에요
        Friend fromFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(fromMember, toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 관계 찾기 (상대 - 나) == 우리는 친구가 될 수 없어요
        Friend toFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(toMember, fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        if (fromFriend.getFriendStatus().equals(FriendStatus.REQUESTCHECK) && toFriend.getFriendStatus().equals(FriendStatus.WAITING)) {
            fromFriend.updateFriendStatus(FriendStatus.DISCONNECTED);
            toFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

            friendRepository.save(fromFriend);
            friendRepository.save(toFriend);
        }
        else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }
    }

    @Override
    public void checkFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 상대방
        UUID toMember = friendRequestDto.getToMember();
        MemberInfo toMemberInfo = memberInfoRepository.findMemberInfoByMemberId(toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 만약에 상대랑 나랑 똑같으면 에러 띄우기
        if (fromMember.equals(toMember)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }

        // 관계 찾기 (나 - 상대) == 나는 상대가 요청을 수락한거를 봤어요
        Friend fromFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(fromMember, toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        if (fromFriend.getFriendStatus().equals(FriendStatus.ACCEPTCHECK)) {
            fromFriend.updateFriendStatus(FriendStatus.FRIEND);

            friendRepository.save(fromFriend);
        }
        else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }
    }

    @Override
    public void disconnectFriend(String accessToken, String refreshToken,
            FriendRequestDto friendRequestDto) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 상대방
        UUID toMember = friendRequestDto.getToMember();

        // 만약에 상대랑 나랑 똑같으면 에러 띄우기
        if (fromMember.equals(toMember)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }

        // 관계 찾기 (나 - 상대) == 우리는 이제부터 친구가 아닙니다.
        Friend fromFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(fromMember, toMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 관계 찾기 (상대 - 나) == 우리는 이제부터 친구가 아닙니다.
        Friend toFriend = friendRepository.findByFriendPkFromMemberAndFriendPkToMember(toMember, fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        if (fromFriend.getFriendStatus().equals(FriendStatus.FRIEND) && toFriend.getFriendStatus().equals(FriendStatus.FRIEND)) {
            fromFriend.updateFriendStatus(FriendStatus.DISCONNECTED);
            toFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

            friendRepository.save(fromFriend);
            friendRepository.save(toFriend);
        } else if (fromFriend.getFriendStatus().equals(FriendStatus.FRIEND) && toFriend.getFriendStatus().equals(FriendStatus.ACCEPTCHECK)) {
            fromFriend.updateFriendStatus(FriendStatus.DISCONNECTED);
            toFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

            friendRepository.save(fromFriend);
            friendRepository.save(toFriend);
        } else if (fromFriend.getFriendStatus().equals(FriendStatus.ACCEPTCHECK) && toFriend.getFriendStatus().equals(FriendStatus.FRIEND)) {
            fromFriend.updateFriendStatus(FriendStatus.DISCONNECTED);
            toFriend.updateFriendStatus(FriendStatus.DISCONNECTED);

            friendRepository.save(fromFriend);
            friendRepository.save(toFriend);
        }
        else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST);
        }

    }

    @Override
    public List<FriendListDto> getFriends(String accessToken, String refreshToken) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        int season = playResultService.getSeason();

        // 내 친구들 불러모아~
        List<FriendStatus> friendStatusList = new ArrayList<>();
        friendStatusList.add(FriendStatus.FRIEND);
        List<Friend> friendList = friendRepository.findByFriendPkFromMemberAndFriendStatusInOrderByCreatedTime(fromMember, friendStatusList);

        // 친구들을 ResponseDto로 만들기
        List<FriendListDto> friendListDtoList = new ArrayList<>();
        for (Friend f : friendList) {

            // 친구 UUID
            UUID toMember = f.getFriendPk().getToMember();
            Optional<Member> to = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember);

            if (to.isEmpty()) {
                continue;
            }

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

            MemberInfo memberInfo = memberInfoRepository.findMemberInfoByMemberId(toMember).orElseThrow(() -> new NullPointerException());

            FriendListDto friendListDto = FriendListDto.builder()
                    .toMember(toMember)
                    .toNickname(memberInfo.getNickname())
                    .score(score).win(win).lose(lose)
                    .friendWin(f.getWin()).friendLose(f.getLose())
                    .isConnect(memberInfo.getIsConnecting())
                    .build();

            if (to.get().getFcmToken() != null) {
                friendListDto.setFcmToken(to.get().getFcmToken().getFcmToken());
            }
            friendListDtoList.add(friendListDto);
        }
        return friendListDtoList;
    }

    // 이 AT를 가지고 있어야 기기에서 다른 기기에 알림을 보낼 수 있음
    private String getFirebaseAccessToken() throws IOException {
        String firebaseConfigPath = "/service_key.json";
        GoogleCredentials googleCredentials = GoogleCredentials.fromStream(new ClassPathResource(firebaseConfigPath).getInputStream())
                .createScoped("https://www.googleapis.com/auth/cloud-platform");

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }

    @Override
    public List<MessageListDto> getMessages(String accessToken, String refreshToken) {

        // 나
        UUID fromMember = jwtUtil.extractMemberId(accessToken.substring(7));
        MemberInfo fromMemberInfo = memberInfoRepository.findMemberInfoByMemberId(fromMember)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));

        // 내 친구 후보들 불러모아~
        List<FriendStatus> friendStatusList = new ArrayList<>();
        friendStatusList.add(FriendStatus.REQUESTCHECK);
        friendStatusList.add(FriendStatus.ACCEPTCHECK);

        List<Friend> friendList = friendRepository.findByFriendPkFromMemberAndFriendStatusInOrderByCreatedTime(fromMember, friendStatusList);

        int season = playResultService.getSeason();

        // 친구들을 ResponseDto로 만들기
        List<MessageListDto> messageListDtoList = new ArrayList<>();
        for (Friend f : friendList) {

            // 친구 UUID
            UUID toMember = f.getFriendPk().getToMember();
            Optional<Member> to = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember);

            if (to.isEmpty()) {
                continue;
            }

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
                    .score(score).win(win).lose(lose)
                    .build();

            FcmToken fcmToken = memberRepository.findMemberByMemberIdAndAndQuitFlagIsFalse(toMember).get()
                    .getFcmToken();
            if (fcmToken != null) {
                messageListDto.setFcmToken(fcmToken.getFcmToken());
            }

            messageListDtoList.add(messageListDto);
        }
        return messageListDtoList;
    }
}
