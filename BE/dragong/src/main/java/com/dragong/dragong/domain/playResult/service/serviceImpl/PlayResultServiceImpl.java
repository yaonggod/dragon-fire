package com.dragong.dragong.domain.playResult.service.serviceImpl;

import com.dragong.dragong.domain.member.entity.MemberInfo;
import com.dragong.dragong.domain.member.repository.MemberInfoRepository;
import com.dragong.dragong.domain.playResult.service.PlayResultService;
import com.dragong.dragong.global.util.JwtUtil;
import com.dragong.dragong.domain.playResult.dto.GetMyRankRequestDto;
import com.dragong.dragong.domain.playResult.dto.GetRankRequestDto;
import com.dragong.dragong.domain.playResult.entity.PlayResult;
import com.dragong.dragong.domain.playResult.repository.PlayResultRepository;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.ListOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class PlayResultServiceImpl implements PlayResultService {

    // 랭킹을 초기화 할 때마다, 시즌이 하나씩 증가함
    static int season = 1;

    @Autowired
    PlayResultRepository playResultRepository;

    @Autowired
    MemberInfoRepository memberInfoRepository;

    @Autowired
    RedisTemplate<String, String> redisTemplate;

    @Autowired
    JwtUtil jwtUtil;

    @Override
    @Transactional
    public void putRank() {
        ListOperations<String, String> listOperations = redisTemplate.opsForList();

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
        int putCnt = 1;
        for (PlayResult playResult : listPlayResult) {
            // 레디스에 넣을 것은 UUID, 랭킹, 닉네임, 점수
            int score = playResult.getScore();
            UUID memberUUID = playResult.getPlayResultEmpId().getMember().getMemberId();
            MemberInfo memberInfo = memberInfoRepository.findById(memberUUID).orElse(null);

            String UUID = memberInfo.getMemberId().toString();
            String nickname = memberInfo.getNickname();

            log.info("UUID는 " + UUID);
            log.info("nickname은 " + nickname);
            log.info("score는 " + score);
            log.info("rank는 " + rank);

            // 레디스에 넣기
            listOperations.rightPush("UUID", UUID); // UUID는 필요 없다면 빼기 => 내 랭킹 찾을 때 사용해야함
            listOperations.rightPush("nickname", nickname);
            listOperations.rightPush("score", String.valueOf(score));

            if (lastNum == score) {
                // 점수가 같은 사람임 => 랭킹도 같아야함
                listOperations.rightPush("rank", String.valueOf(rank));
            } else {
                // 점수가 다른 사람임 => 당연히 랭킹도 달라야함
                listOperations.rightPush("rank", String.valueOf(putCnt));
                rank = putCnt;
            }
            // 만료는 5분 => 약간 더 빠르게 해야함.. expire 가 먼저 되고나서 값이 들어가야함
            // 그렇게 안하면 expire가 안되고 계속 값이 들어감
//            redisTemplate.expire("UUID", 5, TimeUnit.MINUTES);
//            redisTemplate.expire("nickname", 5, TimeUnit.MINUTES);
//            redisTemplate.expire("score", 5, TimeUnit.MINUTES);
//            redisTemplate.expire("rank", 5, TimeUnit.MINUTES);
//            redisTemplate.expire("UUID", 1, TimeUnit.MINUTES);
//            redisTemplate.expire("nickname", 1, TimeUnit.MINUTES);
//            redisTemplate.expire("score", 1, TimeUnit.MINUTES);
//            redisTemplate.expire("rank", 1, TimeUnit.MINUTES);
            redisTemplate.expire("UUID", 59, TimeUnit.SECONDS);
            redisTemplate.expire("nickname", 59, TimeUnit.SECONDS);
            redisTemplate.expire("score", 59, TimeUnit.SECONDS);
            redisTemplate.expire("rank", 59, TimeUnit.SECONDS);

            lastNum = score;
            putCnt++;
        }
    }

    @Override
    public GetRankRequestDto getRank() {
        List<String[]> ranking = new ArrayList<>();
        List<String> nicknameList = redisTemplate.opsForList().range("nickname", 0, -1);
        List<String> scoreList = redisTemplate.opsForList().range("score", 0, -1);
        List<String> rankList = redisTemplate.opsForList().range("rank", 0, -1);

        for (int i = 0; i < nicknameList.size(); i++) {
            String nickname = nicknameList.get(i);
            String score = scoreList.get(i);
            String rank = rankList.get(i);

            ranking.add(new String[]{nickname, score, rank});
        }
        return new GetRankRequestDto(ranking);
    }

    @Override
    public GetMyRankRequestDto getMyRank(String accessToken) {
        // 나중에 리팩토링하기
        List<String> UUIDList = redisTemplate.opsForList().range("UUID", 0, -1);
        List<String> nicknameList = redisTemplate.opsForList().range("nickname", 0, -1);
        List<String> scoreList = redisTemplate.opsForList().range("score", 0, -1);
        List<String> rankList = redisTemplate.opsForList().range("rank", 0, -1);

        String myUUID = jwtUtil.extractRole(accessToken).toString(); // getUUID로 UUID 얻기

        for (int i = 0; i < UUIDList.size(); i++) {
            String UUID = UUIDList.get(i);

            if (UUID.equals(myUUID)) {
                String nickname = nicknameList.get(i);
                String score = scoreList.get(i);
                String rank = rankList.get(i);

                return new GetMyRankRequestDto(new String[]{nickname, score, rank});
            }
        }
        return null;
    }

    @Scheduled(cron = "0 0 0 * * ?")
    public void updateSeason() {
        // 매주 월요일마다 시즌 초기화
        // cron의 시간이 겹치면, 먼저 선언된 메소드 부터 실행이됨 => 그래서 시즌 초기화를 먼저 실행시킴
        season += 1;
    }

    //    @Scheduled(cron = "0 */5 * * * ?")
    @Scheduled(cron = "0 */1 * * * ?")
    public void updateRank() {
        // 5분마다 랭크 초기화
        log.info("랭킹 초기화 중.....");
        putRank();
        log.info("랭킹 초기화 완료!");
    }
}
