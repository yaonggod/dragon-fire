package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.game.dto.*;
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
    private final Set<GameRoomData> gameRoom[] = new HashSet[100000]; //
    private boolean visited[] = new boolean[10000]; // 각 사용자가 들어올 떄마다 visited를 true로
    private int total = 0;
    private final ArrayList<GiData> giDataRoom[] = new ArrayList[100000]; // 기 정보를 저장하기 위해서
    private final BossData bossList[] = new BossData[3];
    private final BossData bossInfo[] = new BossData[100000]; // 보스 정보를 저장
    private final ArrayList<String> messageReceiver[] = new ArrayList[100000]; // 선택을 제대로 했는지 확인하는 용도
    private final ArrayList<LifeData> lifeInfo[] = new ArrayList[100000]; // 각 게임에서 승자 정보를 저장하기 위해서!
    private Stack<String> bossChoose[] = new Stack[1000000]; // 해당 방에 컴퓨터가 무엇을 pick할 것인지

    {
        bossList[0] = new BossData("SSAFY1학기", 20, 5);
        bossList[1] = new BossData("SSAFY2학기", 30, 5);
        bossList[2] = new BossData("취직", 50, 5);
    }

    private final String[][] bossPick = {
            {"기", "기", "기", "기"},
            {"기", "기", "기", "기"},
            {"기", "기", "기", "기", "기", "기"},
            {"기", "기", "기"},
            {"기", "기", "기", "기", "기", "기"},
            {"기", "기", "기", "기"},
    };

    @PostConstruct
    public void initializeGameRoom() {
        // 처음 한번 초기화를 해준다.
        for (int i = 0; i < 100000; i++) {
            giDataRoom[i] = new ArrayList<>();
            messageReceiver[i] = new ArrayList<>();
            gameRoom[i] = new HashSet<>();
            lifeInfo[i] = new ArrayList<>();
            bossChoose[i] = new Stack<>();
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

    public void giReset(int roomId) {
        GiData gi1 = giDataRoom[roomId].get(0);
        GiData gi2 = giDataRoom[roomId].get(1);

        String nick1 = gi1.getNickname();
        String nick2 = gi2.getNickname();
        giDataRoom[roomId].set(0, new GiData(nick1, 0));
        giDataRoom[roomId].set(1, new GiData(nick2, 0));
    }


    public void messageInsert(int roomId, String nickname) {
        // 양쪽에서 메시지 전달을 받았는지 확인하기 위한 용도
        log.info("양측에서 메시지를 보냈는지 확인하기 위해 nickname을 넣어줍니다");
        messageReceiver[roomId].add(nickname);
    }

    public int messageRecevierSize(int roomId) {
        return messageReceiver[roomId].size();
    }

    public void cleanMessageReceiver(int roomId) {
        messageReceiver[roomId].clear();
    }

    public void initHpData(int roomId, String nickname, int life) {
        // 보스의 경우 life가 5, 유저의 경우 life가 3
        lifeInfo[roomId].add(new LifeData(nickname, life));
    }


    public void pickStack(int roomId, String nickname, String picked) {
        //게임 결과를 하나씩 넣어주는 느낌
        log.info("각각의 플레이어가 선택한 값을 넣어줍니다");
        GameRoomData gameRoomData = new GameRoomData(nickname, picked);

        Map<String, GameRoomData> gameRoomMap = new HashMap<>();
        for (GameRoomData data : gameRoom[roomId]) {
            gameRoomMap.put(data.getNickname(), data);
        }
        gameRoomMap.put(nickname, gameRoomData);
        gameRoom[roomId].clear();
        gameRoom[roomId].addAll(gameRoomMap.values());

    }

    public int choosedSize(int roomId) {
        return gameRoom[roomId].size();
    }

    public void bossScene(int roomId) {
        // 보스가 어떤 시나리오를 선택할지
        Random random = new Random();
        int randomIndex = random.nextInt(6);
        for (String pick : bossPick[randomIndex]) {
            bossChoose[roomId].push(pick);
        }

    }

    public String getBossTop(int roomId) {
        if (bossChoose[roomId].size() == 0) {
            // 아무것도 없다면?
            bossScene(roomId);
            return bossChoose[roomId].pop();
        } else {
            return bossChoose[roomId].pop();
        }
    }

    public void cleanBossChoose(int roomId) {
        bossChoose[roomId].clear();
    }


    public String showResult(int roomId) {
        log.info("게임 결과를 확인합니다");
        String answer = "";
        GameRoomData grd1 = null;
        GameRoomData grd2 = null;
        String winner = null;
        int damage = 0;
        boolean miss = false; //빗나감

        if (gameRoom[roomId].size() == 2) {
            // 이건 플레이어가 선택을 했다는 말이다.
            ArrayList<GameRoomData> list = new ArrayList<>(gameRoom[roomId]);
            gameRoom[roomId].clear();
            grd1 = list.get(0);
            grd2 = list.get(1);
        } else {
            // 플레이어가 아무것도 선택하지 않았다는 말이다.
            // 이건 보스가 이겼다고 할거다.
            answer += "싸피1학기" + ":" + "기" + " " + "사용자닉네임" + ":" + "미처리" + " " + "무효입니다" + " 끝냅니다";
            winner = "싸피1학기";
            return answer;
        }

        String player1 = grd1.getNickname();
        String picked1 = grd1.getPicked();
        String player2 = grd2.getNickname();
        String picked2 = grd2.getPicked();
        System.out.println("정보출력");
        log.info(player1);
        log.info(picked1);
        log.info(player2);
        log.info(picked2);


        answer += player1 + ":" + picked1 + " " + player2 + ":" + picked2 + " ";
        String nick1 = giDataRoom[roomId].get(0).getNickname(); // 이게 나다
        int gi1 = giDataRoom[roomId].get(0).getGi(); // 이게 나다
        String nick2 = giDataRoom[roomId].get(1).getNickname();// 이게 boss다
        int gi2 = giDataRoom[roomId].get(1).getGi();// 이게 boss다

        int evacPer = bossInfo[roomId].getEvacuatePer(); //=> 보스의 회피율
        Random random = new Random();
        int randomValue = random.nextInt(100); // 0부터 99까지의 난수
        if (randomValue > evacPer) {
            miss = false; // 빗나가지 않는다.
        } else {
            miss = true;// 빗나간다.
        }
        if (player1.equals(nick1)) {
            if (picked1.equals("기")) {
                gi1 += 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += player2;
                    winner = player2;
                    damage += 1;
                    System.out.println("1현재 damamge"+ damage);
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += player2;
                    winner = player2;
                    damage += 2;
                }
            } else if (picked1.equals("파")) {
                gi1 -= 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    if (!miss) {
                        answer += player1;
                        winner = player1;
                        damage+=5;
                    } else {
                        answer += "비겼습니다";
                    }
                    System.out.println("2현재 damamge"+ damage);
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += player2;
                    winner = player2;
                    damage += 2;
                }

            } else if (picked1.equals("막기")) {
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    gi2 -= 3;
                    // 원기옥
                    answer += player2;
                    winner = player2;
                    damage += 2;
                }

            } else if (picked1.equals("순간이동")) {
                gi1 -= 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += "비겼습니다";
                }

            } else {
                gi1 -= 3;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += player1;
                    winner = player1;
                    damage += 2;
                } else if (picked2.equals("파")) {
                    gi2 -= 1;

                    answer += player1;
                    winner = player1;
                    damage += 2;
                } else if (picked2.equals("막기")) {

                    answer += player1;
                    winner = player1;
                    damage += 2;
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    //원기옥
                    gi2 -= 3;
                    answer += "비겼습니다";
                }

            }

        } else {
            //player1이 boss이다.
            if (picked1.equals("기")) {
                gi2 += 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    if (!miss) {
                        answer += player2;
                        winner = player2;
                    } else {
                        answer += "비겼습니다";

                    }
                    System.out.println("3현재 damamge"+ damage);
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                    winner = player2;
                    damage += 2;
                }
            } else if (picked1.equals("파")) {
                gi2 -= 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += player1;
                    winner = player1;
                    System.out.println("4현재 damamge"+ damage);
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                    winner = player2;
                    damage += 2;
                }

            } else if (picked1.equals("막기")) {
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                    winner = player2;
                    damage += 2;
                }

            } else if (picked1.equals("순간이동")) {
                gi2 -= 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("막기")) {

                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += "비겼습니다";
                }

            } else {
                gi2 -= 3;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += player1;
                    winner = player1;
                    damage += 2;
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += player1;
                    winner = player1;
                    damage += 2;
                } else if (picked2.equals("막기")) {
                    answer += player1;
                    winner = player1;
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    //원기옥
                    gi1 -= 3;
                    answer += "비겼습니다";
                }

            }

        }
        // 이제 다시 넣어줘야한다.
        GiData giData1 = new GiData(nick1, gi1);
        GiData giData2 = new GiData(nick2, gi2);

        giDataRoom[roomId].set(0, giData1);
        giDataRoom[roomId].set(1, giData2);
        // 이제 여기서 winner의 승 1점을 올려야 한다.

        if (winner != null) {
            // 이제 life를 떨어뜨려야한다.
            if (lifeInfo[roomId].get(0).getNickname().equals(winner)) {
                // 만약에 첫번째 인간의 nickname과 승자의 nickname이 같다면?
                int life = lifeInfo[roomId].get(1).getLife();
                lifeInfo[roomId].get(1).setLife(life - damage);
                System.out.println("라이프 정보 " + (life - damage));
                if (life - damage <= 0) {
                    answer += " 끝냅니다";
                } else {
                    answer += " 계속합니다";
                }
            } else {
                int life = lifeInfo[roomId].get(0).getLife();
                lifeInfo[roomId].get(0).setLife(life - damage);
                System.out.println("라이프 정보 " + (life - damage));
                if (life - 1 <= 0) {
                    answer += " 끝냅니다";
                } else {
                    answer += " 계속합니다";
                }
            }
        } else {
            answer += " 계속합니다";
        }

        if (miss) {
            answer += " MISS!";
        } else {
            answer += " 명중!";
        }
        log.info("받아온 answer는 " + answer);
        return answer;
    }

    public String returnGi(int roomId) {
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

    public String returnHpData(int roomId) {
        String result = "";

        LifeData lifeData1 = lifeInfo[roomId].get(0);
        LifeData lifeData2 = lifeInfo[roomId].get(1);

        String nick1 = lifeData1.getNickname();
        int life1 = lifeData1.getLife();
        String nick2 = lifeData2.getNickname();
        int life2 = lifeData2.getLife();
        result += nick1 + ":" + Integer.toString(life1) + " " + nick2 + ":" + Integer.toString(life2);

        return result;
    }


}
