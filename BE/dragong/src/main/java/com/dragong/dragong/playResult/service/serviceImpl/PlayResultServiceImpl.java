package com.dragong.dragong.playResult.service.serviceImpl;

import com.dragong.dragong.member.entity.Member;
import com.dragong.dragong.playResult.entity.PlayResult;
import com.dragong.dragong.playResult.entity.PlayResultEmpId;
import com.dragong.dragong.playResult.repository.PlayResultRepository;
import com.dragong.dragong.playResult.service.PlayResultService;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PlayResultServiceImpl implements PlayResultService {

    // 랭킹을 초기화 할 때마다, 시즌이 하나씩 증가함
    static int season = 0;

    @Autowired
    PlayResultRepository playResultRepository;

    @Override
    public void findRank() {
        List<PlayResult> listPlayResult = playResultRepository.findByPlayResultEmpIdSeason(season)
            .orElse(null);

        Collections.sort(listPlayResult, ((o1, o2) -> {
            // 내림 차순이 안되면 수정하기
            return o2.getScore() - o1.getScore();
        }));

        // 순위
        int rank = 1;
        // 현재 넣은 사람의 점수로, 이 점수가 뒷 사람과 같으면 같은 랭킹으로 넣기
        int lastNum = -1;
        // 지금까지 넣은 사람의 수 => 점수가 같은 사람은 같은 등수로 넣고, 그게 끝이나면 이것으로 rank를 바꿔주고 넣으면 됨
        int putCnt = 0;
        for (PlayResult playResult : listPlayResult) {
            // 레디스에 넣을 것은 랭킹, 닉네임, 점수

            int score = playResult.getScore();
            String nickname = playResult.getPlayResultEmpId().getMember().getMemberInfo().getNickname();

            // 레디스에 넣기


        }
    }
}
