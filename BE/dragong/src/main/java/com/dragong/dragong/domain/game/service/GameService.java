package com.dragong.dragong.domain.game.service;

import com.dragong.dragong.domain.game.dto.GameRoomData;
import com.dragong.dragong.domain.game.dto.GiData;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.sql.Array;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Queue;

@Service
public class GameService {
    private final Queue<GameRoomData> gameRoom[] = new Queue[100000];
    private final ArrayList<GiData> giDataRoom[] = new ArrayList[100000];

    @PostConstruct
    public void initializeGameRoom() {
        for (int i = 0; i < gameRoom.length; i++) {
            gameRoom[i] = new LinkedList<>();
            giDataRoom[i] = new ArrayList<>();
        }
    }

    public void giInit(String roomId, String nickname) {
        // 기 정보를 처음으로 초기화 해주고 넣어준다.
        GiData giData = new GiData(nickname, 0);
        giDataRoom[Integer.parseInt(roomId)].add(giData);
    }

    public String giReturn(String roomId) {
        String answer = "";
        for (int i = 0; i < 2; i++) {
            GiData giData = giDataRoom[Integer.parseInt(roomId)].get(i);
            String player = giData.getNickname();
            String giCnt = Integer.toString(giData.getGi());
            answer += player + " " + giCnt + " ";
        }
        return answer;
    }


    public void gameStack(String roomId, String nickname, String picked) {
        //게임 결과를 하나씩 넣어주는 느낌
        GameRoomData gameRoomData = new GameRoomData(nickname, picked);
        gameRoom[Integer.parseInt(roomId)].add(gameRoomData);
        System.out.println(gameRoom[Integer.parseInt(roomId)].size());
        //들어오는 값들을 확인하고
    }

    public String gameResult(String roomId) {
        System.out.println("gameResult 확인!");
        //넣어준 gameStack에서 결과를 도출해내고 그걸 반환하는 함수
        // 여기서 예외 처리를 해줘야 하는데, 4가지 경우가 있을 것이다.
        // 1. 둘 다 제대로 제출한 경우, 2. 둘 중 한 명만 제출한 경우(이게 2가지), 4. 둘 다 제출하지 않은 경우
        String answer = "";
        GameRoomData grd1 = null;
        GameRoomData grd2 = null;
        if (gameRoom[Integer.parseInt(roomId)].size() == 2) {
            //둘다 제대로 정보를 입력한 경우
            grd1 = gameRoom[Integer.parseInt(roomId)].poll();
            grd2 = gameRoom[Integer.parseInt(roomId)].poll();
        } else if (gameRoom[Integer.parseInt(roomId)].size() == 1) {
            // 한 명만 정보를 입력한 경우
            grd1 = gameRoom[Integer.parseInt(roomId)].poll();
            answer+=grd1.getNickname()+":"+grd1.getPicked()+" "+"player2"+":"+"미처리"+" "+"무효입니다";
            return answer;

        } else if (gameRoom[Integer.parseInt(roomId)].size() == 0) {
            // 둘 다 정보를 입력하지 않은 경우
            answer = "player1:미처리 player2:미처리 무효입니다";
            return answer;
        }


        String player1 = grd1.getNickname();
        String picked1 = grd1.getPicked();

        String player2 = grd2.getNickname();
        String picked2 = grd2.getPicked();
        answer += player1 + ":" + picked1 + " " + player2 + ":" + picked2+" ";
        String nick1 = giDataRoom[Integer.parseInt(roomId)].get(0).getNickname();
        int gi1 = giDataRoom[Integer.parseInt(roomId)].get(0).getGi(); // Arraylist안의 첫번째 사람의 기 개수
        String nick2 = giDataRoom[Integer.parseInt(roomId)].get(1).getNickname();// Arraylist안의 두번째 사람의 닉네임
        int gi2 = giDataRoom[Integer.parseInt(roomId)].get(1).getGi();// Arraylist안의 두번째 사람의 기 개수

        if (player1.equals(nick1)) {
            if (picked1.equals("기")) {
                gi1 += 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi2 -= 1;
                    answer += player2;
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi2 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi2 -= 3;
                    answer += player2;
                }
            } else if (picked1.equals("파")) {
                gi1 -= 1;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += player1;
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
                    answer += player2;
                }

            } else {
                gi1 -= 3;
                if (picked2.equals("기")) {
                    gi2 += 1;
                    answer += player1;
                } else if (picked2.equals("파")) {
                    gi2 += 1;
                    answer += player1;
                } else if (picked2.equals("막기")) {
                    answer += player1;
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
            if (picked1.equals("기")) {
                gi2 += 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += "비겼습니다";
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += player2;
                } else if (picked2.equals("막기")) {
                    answer += "비겼습니다";
                } else if (picked2.equals("순간이동")) {
                    gi1 -= 1;
                    answer += "비겼습니다";
                } else {
                    // 원기옥
                    gi1 -= 3;
                    answer += player2;
                }
            } else if (picked1.equals("파")) {
                gi2 -= 1;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += player1;
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
                    answer += player2;
                }

            } else {
                gi2 -= 3;
                if (picked2.equals("기")) {
                    gi1 += 1;
                    answer += player1;
                } else if (picked2.equals("파")) {
                    gi1 -= 1;
                    answer += player1;
                } else if (picked2.equals("막기")) {
                    answer += player1;
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

        giDataRoom[Integer.parseInt(roomId)].set(0, giData1);
        giDataRoom[Integer.parseInt(roomId)].set(1, giData2);
        return answer;

    }

}
