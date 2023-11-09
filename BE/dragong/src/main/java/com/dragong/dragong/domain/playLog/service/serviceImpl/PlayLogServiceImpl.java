package com.dragong.dragong.domain.playLog.service.serviceImpl;

import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.playLog.dto.GetMyPlayListRequestDto;
import com.dragong.dragong.domain.playLog.dto.GetMyPlayListResponseDto;
import com.dragong.dragong.domain.playLog.entity.PlayLog;
import com.dragong.dragong.domain.playLog.repository.PlayLogRepository;
import com.dragong.dragong.domain.playLog.service.PlayLogService;
import com.dragong.dragong.global.util.JwtUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PlayLogServiceImpl implements PlayLogService {

    @Autowired
    PlayLogRepository playLogRepository;

    @Autowired
    MemberRepository memberRepository;

    @Autowired
    MemberInfoRepository memberInfoRepository;

    @Autowired
    JwtUtil jwtUtil;

    @Override
    public List<GetMyPlayListResponseDto> getMyPlayList(
        GetMyPlayListRequestDto getMyPlayListRequestDto) {
        List<GetMyPlayListResponseDto> returnList = new ArrayList<>();

        String accessToken = getMyPlayListRequestDto.getAccessToken();

        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7));
        Member member = memberRepository.findById(myUUID)
            .orElseThrow(() -> new NullPointerException());

        // 내 닉네임 가져오기
        String myNickname = memberInfoRepository.findById(myUUID)
            .orElseThrow(() -> new NullPointerException()).getNickname();

        // 경기 결과
        List<PlayLog> playLogList = playLogRepository.findByMyUUIDOrderByCreatedTimeDesc(member)
            .orElseThrow(() -> new NullPointerException());

        for (PlayLog playLog : playLogList) {
            if (returnList.size() >= 5) {
                break;
            }

            // 상대 정보
            UUID opponentUUID = playLog.getOpponentUUID().getMemberId();

            // 상대 닉네임
            String opponentNickname = memberInfoRepository.findById(opponentUUID)
                .orElseThrow(() -> new NullPointerException())
                .getNickname();

            // 리턴 값 생성
            returnList.add(GetMyPlayListResponseDto.builder()
                .myPlay(playLog.getMyPlay())
                .myNickname(myNickname)
                .opponentPlay(playLog.getOpponentPlay())
                .playResult(playLog.isPlayResult())
                .opponentNickname(opponentNickname)
                .build());
        }
        return returnList;
    }
}
