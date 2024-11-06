package a102.PickingParking.service;

import a102.PickingParking.entity.User;
import a102.PickingParking.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import static org.junit.jupiter.api.Assertions.*;


@ExtendWith(SpringExtension.class)
@SpringBootTest
@Transactional
class UserServiceTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

//    @BeforeEach
//    public void setUp() {
//        userRepository.deleteAll(); // 테스트 전에 데이터 초기화
//    }

    @Test
    public void 회원가입(){
        //given
        String username = "testUser";
        String password = "testPassword";
        String phoneNumber = "01012345678";

        //when
        User savedUser = userService.signupUser(username, password, phoneNumber);

        // then
        assertNotNull(savedUser);
        assertEquals(username, savedUser.getUsername());
        assertTrue(passwordEncoder.matches(password, savedUser.getPassword()));
        assertEquals(phoneNumber, savedUser.getPhoneNumber());
    }

    @Test
    public void 로그인(){
        // given
        String username = "testUser";
        String password = "testPassword";
        String phoneNumber = "01012345678";
        userService.signupUser(username, password, phoneNumber); // 회원가입 진행

        // when
        User loggedInUser = userService.loginUser(username, password);

        // then
        assertNotNull(loggedInUser);
        assertEquals(username, loggedInUser.getUsername());
    }

}