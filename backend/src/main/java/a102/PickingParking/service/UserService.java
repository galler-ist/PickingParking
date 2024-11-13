package a102.PickingParking.service;

import a102.PickingParking.entity.User;
import a102.PickingParking.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // userId로 사용자 조회
    public Optional<User> getUserByUserId(String userId) {
        return userRepository.findByUserId(userId);
    }

    // 회원가입
    public User signupUser(String userId, String password, String phoneNumber) {
        if (userRepository.findByUserId(userId).isPresent()) {
            throw new IllegalArgumentException("이미 존재하는 아이디입니다.");
        }

        User user = User.builder()
                .userId(userId)
                .password(passwordEncoder.encode(password))
                .phoneNumber(phoneNumber)
                .build();

        return userRepository.save(user);
    }

    // 로그인
    public User loginUser(String userId, String password) {
        Optional<User> userOptional = userRepository.findByUserId(userId);

        User user = userOptional.orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        if(user.getUnsubcribedDate() != null) {
            throw new IllegalArgumentException("탈퇴한 사용자입니다. 로그인할 수 없습니다.");
        }

        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
        }

        return user;
    }

    // 회원탈퇴
    public void deleteUser(String userId) {
        User user = userRepository.findByUserId(userId).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        // 탈퇴일을 현재 날짜로 설정
        user.setUnsubcribedDate(LocalDateTime.now());

        userRepository.save(user);
    }
}
