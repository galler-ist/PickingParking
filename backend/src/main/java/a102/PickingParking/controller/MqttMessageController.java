package a102.PickingParking.controller;

import a102.PickingParking.entity.MqttData;
import a102.PickingParking.repository.MqttMessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/mqtt")
public class MqttMessageController {

    @Autowired
    private MqttMessageRepository mqttMessageRepository;

    @GetMapping("/messages")
    public ResponseEntity<List<MqttData>> getMessages(
            @RequestParam(required = false) Integer zoneSeq) {
        List<MqttData> messages;

        if (zoneSeq != null) {
            messages = mqttMessageRepository.findAll().stream()
                    .filter(message -> message.getZoneSeq().equals(zoneSeq))
                    .toList();
        } else {
            messages = mqttMessageRepository.findAll();
        }

        return ResponseEntity.ok(messages);
    }
}
