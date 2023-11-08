package com.dragong.dragong.domain.playLog.service.serviceImpl;

import com.dragong.dragong.domain.member.entity.Member;
import com.dragong.dragong.domain.member.repository.MemberRepository;
import com.dragong.dragong.domain.playLog.dto.GetMyPlayListRequestDto;
import com.dragong.dragong.domain.playLog.dto.GetMyPlayListResponseDto;
import com.dragong.dragong.domain.playLog.entity.PlayLog;
import com.dragong.dragong.domain.playLog.repository.PlayLogRepository;
import com.dragong.dragong.domain.playLog.service.PlayLogService;
import com.dragong.dragong.global.util.JwtUtil;
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
    JwtUtil jwtUtil;

    @Override
    public List<GetMyPlayListResponseDto> getMyPlayList(GetMyPlayListRequestDto getMyPlayListRequestDto) {
        String accessToken = getMyPlayListRequestDto.getAccessToken();

        UUID myUUID = jwtUtil.extractMemberId(accessToken.substring(7));

        Member member = memberRepository.findById(myUUID).orElse(null);
        List<PlayLog> playLogList = playLogRepository.findByMyUUID(member).orElse(null);

        for (PlayLog playLog : playLogList) {
            System.out.println("내 UUID : " + playLog.getMyUUID());
            System.out.println("상대 UUID : " + playLog.getOpponentPlay());
            System.out.println();
        }


        return null;
    }
}
