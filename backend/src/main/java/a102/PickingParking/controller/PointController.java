package a102.PickingParking.controller;

import a102.PickingParking.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/point")
@Tag(name = "포인트 API", description = "포인트 관련 API")
@RequiredArgsConstructor
public class PointController {

    private final pointService pointService;

    @PostMapping("")
    public ResponseEntity<Integer> getPoints(@RequestBody String userId) {
        int currentPoints = pointService.getCurrentPoints(userId);
        return ResponseEntity.ok(currentPoints);
    }
}
