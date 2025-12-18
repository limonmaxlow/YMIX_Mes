package com.messenger.config;

import com.messenger.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    @Autowired
    private UserService userService;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        
        if (accessor != null) {
            String userIdHeader = accessor.getFirstNativeHeader("userId");
            if (userIdHeader != null) {
                try {
                    UUID userId = UUID.fromString(userIdHeader);
                    // Проверяем существование пользователя
                    if (userService.getUserById(userId).isPresent()) {
                        // Устанавливаем аутентификацию
                        UsernamePasswordAuthenticationToken auth = 
                            new UsernamePasswordAuthenticationToken(userId, null);
                        accessor.setUser(auth);
                    }
                } catch (IllegalArgumentException e) {
                    // Невалидный UUID
                }
            }
        }
        
        return message;
    }
}