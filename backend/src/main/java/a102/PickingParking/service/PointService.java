package a102.PickingParking.service;

import a102.PickingParking.dto.PointRequestDto;
import a102.PickingParking.entity.Point;
import a102.PickingParking.entity.User;
import a102.PickingParking.repository.PointRepository;
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
    public int getCurrentPoints(String user_id) {
        // 사용자 정보를 조회
        User user = userRepository.findByUserId(user_id)
                .orElseThrow(() ->
                        new IllegalArgumentException("사용자가 존재하지 않습니다."));


        return user.getPoint();

        // 현재 포인트 반환
    }

    // 포인트 충전과 사용

    @Autowired
    private PointRepository pointRepository;

    public void pointRequest(PointRequestDto request) {
        // user_id로 user_seq 조회
        User user = userRepository.findByUserId(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        // 현재 포인트 확인
        int currentPoints = user.getPoint();

        // 포인트 증가
        user.setPoint(currentPoints + request.getPoint_price()); // 요청된 금액만큼 포인트 이동

        // 거래 기록 저장
        Point point = new Point();
        point.setSeq(user.getSeq());
        point.setPrice(request.getPoint_price());
        point.setSource(request.getPoint_source());

        // 거래 기록을 DB에 저장
        pointRepository.save(point);

        // 사용자 정보를 DB에 저장 (포인트 업데이트)
        userRepository.save(user);
    }
}
