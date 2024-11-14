//package a102.PickingParking.controller;
//
//import a102.PickingParking.config.MQTTConfig;
//import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.RestController;
//
//@RestController
//public class MqttController {
//
//    private final MQTTConfig mqttConfig;
//
//    public MqttController(MQTTConfig mqttConfig) {
//        this.mqttConfig = mqttConfig;
//    }
//
//    @GetMapping("/connect-mqtt")
//    public String connectMqtt() {
//        mqttConfig.connectToAwsIot();
//        return "MQTT 연결 시도!";
//    }
//}
package a102.PickingParking.controller;

import a102.PickingParking.config.MQTTConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/api/mqtt")  // API 경로 구조화
@Slf4j  // 로깅 추가
public class MqttController {
    private final MQTTConfig mqttConfig;

    public MqttController(MQTTConfig mqttConfig) {
        this.mqttConfig = mqttConfig;
    }

    @GetMapping("/publish")
    public ResponseEntity<String> publishMessage(@RequestParam(defaultValue = "mqtt_test") String topic,
                                                 @RequestParam String message) {
        try {
            mqttConfig.publishMessage(topic, message);
            log.info("Successfully published message to topic: {}", topic);
            return ResponseEntity.ok("Message published successfully!");
        } catch (Exception e) {
            log.error("Failed to publish message to topic: {}", topic, e);
            return ResponseEntity.internalServerError().body("Failed to publish message: " + e.getMessage());
        }
    }

    // 추가 엔드포인트: 연결 상태 확인
    @GetMapping("/status")
    public ResponseEntity<String> checkConnectionStatus() {
        try {
            boolean isConnected = mqttConfig.isConnected(); // MQTTConfig에 이 메서드 추가 필요
            return ResponseEntity.ok("MQTT Client is " + (isConnected ? "connected" : "disconnected"));
        } catch (Exception e) {
            log.error("Failed to check MQTT connection status", e);
            return ResponseEntity.internalServerError().body("Failed to check connection status: " + e.getMessage());
        }
    }
}