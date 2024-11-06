package a102.PickingParking.controller;

import a102.PickingParking.dto.UserSignupRequestDto;
import a102.PickingParking.entity.User;
import a102.PickingParking.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
public class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Test
    @DisplayName("회원가입 API 테스트")
    public void testSignupUser() throws Exception{
        //given
        UserSignupRequestDto userSignupRequestDto = new UserSignupRequestDto("testUser", "testPass", "01012345678");
        User user = User.builder()
                .username(userSignupRequestDto.getUser_id())
                .password(passwordEncoder.encode(userSignupRequestDto.getUser_pw()))
                .phoneNumber(userSignupRequestDto.getUser_phone())
                .build();
        
        when(userService.signupUser(any(String.class), any(String.class),any(String.class))).thenReturn(user);


        //when
        //then
        mockMvc.perform(post("/api/users/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userSignupRequestDto)))
                .andExpect(status().isOk())
                .andExpect(content().string("회원가입이 완료되었습니다."));
    }
    
    
    @Test
    @DisplayName("로그인 API 테스트")
    public void testLoginUser() throws Exception{
        //given
        
        //when
        
        //then
    }

}