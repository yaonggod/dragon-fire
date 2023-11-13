package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.game.dto.BossData;
import com.dragong.dragong.domain.game.dto.ComData;
import com.dragong.dragong.domain.game.dto.GiData;
import com.dragong.dragong.global.util.JwtUtil;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@Slf4j
public class TowerService {

    @Autowired
    JwtUtil jwtUtil;

    private boolean visited[] = new boolean[10000]; // 각 사용자가 들어올 떄마다 visited를 true로
    private int total = 0;
    private final ArrayList<GiData> giDataRoom[] = new ArrayList[100000]; // 기 정보를 저장하기 위해서
    private final BossData bossList[] = new BossData[3];
    private final BossData bossInfo[] = new BossData[100000]; // 보스 정보를 저장

    {
        bossList[0] = new BossData("SSAFY1학기", 20, 5);
        bossList[1] = new BossData("SSAFY2학기", 30, 6);
        bossList[2] = new BossData("취직", 50, 7);
    }

    @PostConstruct
    public void initializeGameRoom() {
        // 처음 한번 초기화를 해준다.
        for (int i = 0; i < 100000; i++) {
            giDataRoom[i] = new ArrayList<>();
        }
    }

    public int enter() {
        log.info("보스를 처치하기 위해 방에 입장합니다.");
        total += 1;
        if (visited[total]) {
            // 이미 차지하고 있다면?
            while (visited[total]) {
                total += 1;
            }
            visited[total] = true;
        } else {
            // 빈 곳이라면?
            visited[total] = true;
        }
        return total;
    }

    public void chooseBoss(int roomId, int nowFloor) {
        String bossName = bossList[nowFloor - 1].getBossName();
        int bossEvacuate = bossList[nowFloor - 1].getEvacuatePer();
        int bossLife = bossList[nowFloor - 1].getLife();

        bossInfo[roomId] = new BossData(bossName, bossEvacuate, bossLife);
    }

    public Map<String, Object> getBoss(int roomId) {
        Map<String, Object> data = new HashMap<>();
        BossData bossData = bossInfo[roomId];
        String bossName = bossData.getBossName();
        int bossEvacuate = bossData.getEvacuatePer();
        int bossLife = bossData.getLife();
        data.put("bossName", bossName);
        data.put("bossEvacuate", bossEvacuate);
        data.put("bossLife", bossLife);
        return data;
    }

    public int giInit(int roomId, String nickname) {
        // 기 정보를 처음으로 초기화 해주고 넣어준다.
        log.info("기 정보를 초기화해줍니다");
        GiData giData = new GiData(nickname, 0);
        giDataRoom[roomId].add(giData);
        return giDataRoom[roomId].size();
    }

    public String giReturn(int roomId) {
        String answer = "";
        for (int i = 0; i < 2; i++) {
            GiData giData = giDataRoom[roomId].get(i);
            String player = giData.getNickname();

            String giCnt = Integer.toString(giData.getGi());
            answer += player + " " + giCnt + " ";
        }
        log.info("각각의 플레이어가 가지고 있는 기 정보를 반환합니다" + answer);
        return answer;
    }
}
