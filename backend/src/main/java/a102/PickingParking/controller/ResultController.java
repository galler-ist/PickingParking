package a102.PickingParking.controller;

import a102.PickingParking.dto.VehicleValidationResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "하드웨어 통신 API", description = "하드웨어 관련 API")
@RequestMapping("/api/vehicle/validation")
public class ResultController {

    private VehicleValidationResponse latestResponse;

    @PostMapping("/response")
    @Operation(summary = "자동차 번호판 결과")
    public ResponseEntity<VehicleValidationResponse> getValidationResult() {
        // 프론트엔드에서 결과를 요청할 때 이 메서드가 호출됨
        if (latestResponse != null) {
            return ResponseEntity.ok(latestResponse);
        } else {
            return ResponseEntity.noContent().build(); // 결과가 없을 경우 204 No Content 반환
        }
    }

    // MQTTConfig에서 호출하는 메서드
    public void updateValidationResult(VehicleValidationResponse response) {
        this.latestResponse = response;
    }
}
