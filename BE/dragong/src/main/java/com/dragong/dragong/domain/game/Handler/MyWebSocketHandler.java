package com.dragong.dragong.domain.game.Handler;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@Component
public class MyWebSocketHandler extends TextWebSocketHandler {

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        // WebSocket 요청 처리
        System.out.println("handler 들어옴");
        String roomId = session.getUri().getPath(); // 이 부분을 통해 roomId를 추출

        // roomId를 사용하여 방 관련 처리 수행
    }
}