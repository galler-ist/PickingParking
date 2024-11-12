package a102.PickingParking.config;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.beans.factory.annotation.Value;
import com.amazonaws.services.iot.client.AWSIotMqttClient;

@Configuration
public class MQTTConfig {
    @Value("${aws.iot.endpoint}") //엔드포인트 주소
    private String endpoint;

    @Value("${aws.iot.cert.path}") //인증서 파일 주소
    private String certificatePath;

    @Value("${aws.iot.private.key.path}")  // 프라이빗 키 파일 경로
    private String privateKeyPath;

    @Bean // 여기서부턴 스프링이 관리한 MQTT 클라이언트 객체 생성
    public AWSIotMqttClient mqttClient() throws Exception{
        String clientID = "EC2_Backend";

        //여기서부터 MQTT 클라이언트 생성 및 설정
        AWSIotMqttClient client = new AWSIotMqttClient(
                endpoint,
                clientID,
                certificatePath,
                privateKeyPath
        );

        client.connect();
        return client;
    }

}
