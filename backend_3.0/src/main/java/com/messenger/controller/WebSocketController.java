package com.messenger.controller;

import com.messenger.model.Message;
import com.messenger.model.dto.MessageRequest;
import com.messenger.model.dto.WebSocketMessage;
import com.messenger.service.MessageService;
import com.messenger.service.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@Controller
public class WebSocketController {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private MessageService messageService;

    @Autowired
    private ChatService chatService;

    // ОСНОВНОЙ МЕТОД ОТПРАВКИ СООБЩЕНИЯ
    @MessageMapping("/chat/{chatId}/send")
    public void sendMessage(@DestinationVariable UUID chatId, 
                          @Payload MessageRequest request) {
        
        System.out.println("=== WEBSOCKET: Получено сообщение для чата " + chatId);
        System.out.println("Отправитель: " + request.getSenderId());
        System.out.println("Сообщение: " + request.getContent());

        // Проверяем права доступа к чату
        if (!chatService.isUserInChat(chatId, request.getSenderId())) {
            System.out.println("Ошибка: пользователь не состоит в чате");
            return;
        }

        // Сохраняем сообщение в БД
        Message message = messageService.sendMessage(request);
        if (message != null) {
            System.out.println("Сообщение сохранено в БД: " + message.getId());
            
            // Отправляем сообщение всем подписанным на чат
            WebSocketMessage<Message> wsMessage = new WebSocketMessage<>(
                "NEW_MESSAGE", message
            );
            
            String destination = "/topic/chat/" + chatId;
            messagingTemplate.convertAndSend(destination, wsMessage);
            System.out.println("Сообщение отправлено в WebSocket: " + destination);
            
        } else {
            System.out.println("Ошибка: не удалось сохранить сообщение");
        }
    }

    // Дублирующий метод для HTTP запросов (вызывается из MessageController)
    public void broadcastNewMessage(Message message) {
        if (message != null) {
            System.out.println("=== HTTP BROADCAST: Отправка сообщения в WebSocket");
            WebSocketMessage<Message> wsMessage = new WebSocketMessage<>(
                "NEW_MESSAGE", message
            );
            
            String destination = "/topic/chat/" + message.getChatId();
            messagingTemplate.convertAndSend(destination, wsMessage);
            System.out.println("Сообщение broadcast: " + destination);
        }
    }

    // Статус "печатает"
    @MessageMapping("/chat/{chatId}/typing")
    public void typingStatus(@DestinationVariable UUID chatId,
                           @Payload TypingRequest request) {
        
        System.out.println("Пользователь " + request.getUserId() + " печатает: " + request.isTyping());
        
        WebSocketMessage<TypingRequest> wsMessage = new WebSocketMessage<>(
            "USER_TYPING", request
        );
        
        messagingTemplate.convertAndSend("/topic/chat/" + chatId, wsMessage);
    }

    // DTO классы для WebSocket
    public static class TypingRequest {
        private UUID userId;
        private UUID chatId;
        private boolean isTyping;

        // Геттеры и сеттеры
        public UUID getUserId() { return userId; }
        public void setUserId(UUID userId) { this.userId = userId; }
        
        public UUID getChatId() { return chatId; }
        public void setChatId(UUID chatId) { this.chatId = chatId; }
        
        public boolean isTyping() { return isTyping; }
        public void setTyping(boolean typing) { isTyping = typing; }
    }
}