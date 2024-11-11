package a102.PickingParking.controller;

import a102.PickingParking.entity.Car;
import a102.PickingParking.service.CarService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/car")
@Tag(name = "자동차 API", description = "자동차 관련 API")
public class CarController {

    @Autowired
    private CarService carService;

    // 챠량 등록
    @PostMapping("/{userId}")
    public ResponseEntity<Car> registerCar(@PathVariable String userId, @RequestBody Car car) {
        Car registeredCar = carService.registerCar(userId, car); // userId를 전달
        return ResponseEntity.ok(registeredCar);
    }

    // 사용자 ID로 차량 목록 조회
    @GetMapping("/{userId}")
    public ResponseEntity<List<Car>> getCars(@PathVariable String userId) {
        List<Car> cars = carService.getCarsByUser(userId);
        return ResponseEntity.ok(cars);
    }

    // 차량 상세 정보 조회
    @GetMapping("/{userId}/{carId}")
    public ResponseEntity<Car> getCar(@PathVariable String userId, @PathVariable Integer carId) {
        Car car = carService.getCarById(userId, carId);
        return ResponseEntity.ok(car);
    }
}
