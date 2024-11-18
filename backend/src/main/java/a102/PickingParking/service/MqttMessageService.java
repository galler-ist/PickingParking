package a102.PickingParking.service;

import a102.PickingParking.dto.LicensePlateResponse;
import a102.PickingParking.entity.MqttData;
import a102.PickingParking.repository.MqttMessageRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MqttMessageService {

    @Autowired
    private MqttMessageRepository mqttMessageRepository;

    public void handleMqttMessage(String payload) {
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            // JSON 문자열을 파싱하여 DTO로 변환
            LicensePlateResponse messageDto = objectMapper.readValue(payload, LicensePlateResponse.class);

            // 데이터베이스에 저장
            MqttData messageData = new MqttData();
            messageData.setZoneSeq(messageDto.getMessage().getZone_seq());
            messageData.setResult(messageDto.getMessage().getResult());
            mqttMessageRepository.save(messageData);
        } catch (Exception e) {
            e.printStackTrace(); // 예외 처리
        }
    }
}