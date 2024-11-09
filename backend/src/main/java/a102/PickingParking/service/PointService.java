package a102.PickingParking.service;

import a102.PickingParking.entity.User;
import a102.PickingParking.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PointService {

    private final UserRepository userRepository;

    @Autowired
    public PointService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // 사용자 ID로 현재 포인트 조회
    public int getCurrentPoints(String username) {
        // 사용자 정보를 조회
        User user = userRepository.findByUsername(username)
                .orElseThrow(() ->
                        new IllegalArgumentException("사용자가 존재하지 않습니다."));


        return user.getPoint();

        // 현재 포인트 반환
    }
}
