////package a102.PickingParking.config;
////import org.springframework.context.annotation.Bean;
////import org.springframework.context.annotation.Configuration;
////import org.springframework.beans.factory.annotation.Value;
////import com.amazonaws.services.iot.client.AWSIotMqttClient;
////import software.amazon.awssdk.crt.mqtt.MqttClientConnection;
////
////@Configuration
////public class MQTTConfig {
////    @Value("${aws.iot.endpoint}") //엔드포인트 주소
////    private String endpoint;
////
////    @Value("${aws.iot.cert.path}") //인증서 파일 주소
////    private String certificatePath;
////
////    @Value("${aws.iot.private.key.path}")  // 프라이빗 키 파일 경로
////    private String privateKeyPath;
////
////    @Bean // 여기서부턴 스프링이 관리한 MQTT 클라이언트 객체 생성
////    public AWSIotMqttClient mqttClient() throws Exception{
////        String clientID = "EC2_Backend";
////
////        //여기서부터 MQTT 클라이언트 생성 및 설정
////        AWSIotMqttClient client = new AWSIotMqttClient(
////                endpoint,
////                clientID,
////                certificatePath,
////                privateKeyPath
////        );
////
////        client.connect();
////        return client;
////    }
////
////}
//package a102.PickingParking.config;
//
//import io.github.cdimascio.dotenv.Dotenv;
//import org.eclipse.paho.client.mqttv3.*;
//import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
//import org.springframework.context.annotation.Configuration;
//
//import javax.annotation.PostConstruct;
//
//@Configuration
//public class MQTTConfig {
//
////    public static void main(String[] args) {
////        MQTTConfig mqttConfig = new MQTTConfig();
////        mqttConfig.connectAndSubscribe();
////    }
//    @PostConstruct
//    public void connectAndSubscribe() {
//        try {
//            // .env 파일에서 환경변수 로드
//            Dotenv dotenv = Dotenv.load();
//            String broker = "ssl://" + dotenv.get("AWS_IOT_ENDPOINT") + ":8883";
//            String clientId = dotenv.get("AWS_CLIENT_ID");
//            String topic = "mqtt_test";
//
//            // MQTT 클라이언트 설정
//            MqttClient client = new MqttClient(broker, clientId, new MemoryPersistence());
//            MqttConnectOptions options = new MqttConnectOptions();
//            options.setCleanSession(true);
//            client.connect(options);
//
//            System.out.println("Connected to AWS IoT");
//
//            // 메시지 발행 예제
//            String payload = "Hello from PickingParking!";
//            MqttMessage message = new MqttMessage(payload.getBytes());
//            message.setQos(1);
//            client.publish("mqtt_test", message);
//            System.out.println("Message published: " + payload);
//
//            // 구독 설정
//            client.subscribe(topic, (receivedTopic, receivedMessage) -> {
//                System.out.println("Message received. Topic: " + receivedTopic + ", Message: " + new String(receivedMessage.getPayload()));
//            });
//
//            // 클라이언트를 종료하지 않고 계속 실행되도록 설정
//            System.out.println("Subscribed to topic: " + topic);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//
//    public void connectToAwsIot() {
//        try {
//            // .env 파일에서 환경변수 로드
//            Dotenv dotenv = Dotenv.load();
//            String broker = "ssl://" + dotenv.get("AWS_IOT_ENDPOINT") + ":8883";
//            String clientId = dotenv.get("AWS_CLIENT_ID");
//
//            MqttClient client = new MqttClient(broker, clientId, new MemoryPersistence());
//            MqttConnectOptions options = new MqttConnectOptions();
//            // SSL 소켓 팩토리 설정 생략 (필요 시 추가)
//            options.setCleanSession(true);
//
//            client.connect(options);
//            System.out.println("Connected to AWS IoT");
//
//            // 예제 메시지 발행
//            String topic = "your/topic";
//            String payload = "Hello from PickingParking!";
//            MqttMessage message = new MqttMessage(payload.getBytes());
//            message.setQos(1);
//            client.publish(topic, message);
//
//            System.out.println("Message published");
//            client.disconnect();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//}

package a102.PickingParking.config;

import io.github.cdimascio.dotenv.Dotenv;
import lombok.extern.slf4j.Slf4j;
import org.bouncycastle.openssl.PEMKeyPair;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;
import java.io.FileInputStream;
import java.io.StringReader;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.cert.Certificate;


@Configuration
@Slf4j  // 로깅을 위해 추가
public class MQTTConfig {
    private MqttClient client;
    private final String topic = "mqtt_test";
    private MqttConnectOptions options;

    @PostConstruct
    public void init() {
        try {
            Dotenv dotenv = Dotenv.load();
            String broker = "ssl://" + dotenv.get("AWS_IOT_ENDPOINT") + ":8883";
            String clientId = dotenv.get("AWS_CLIENT_ID");

            // 인증서 파일 경로
            String certPath = dotenv.get("AWS_CERT_PATH");
            String keyPath = dotenv.get("AWS_KEY_PATH");
            String caPath = dotenv.get("AWS_ROOT_CA_PATH");

            client = new MqttClient(broker, clientId, new MemoryPersistence());

            options = new MqttConnectOptions();
            options.setCleanSession(true);
            options.setKeepAliveInterval(60);
            options.setConnectionTimeout(30);

            // SSL 컨텍스트 설정
            SSLSocketFactory socketFactory = getSocketFactory(caPath, certPath, keyPath);
            options.setSocketFactory(socketFactory);

            // 연결 콜백
            client.setCallback(new MqttCallback() {
                @Override
                public void connectionLost(Throwable cause) {
                    log.error("Connection lost! Trying to reconnect...", cause);
                    reconnect();
                }

                @Override
                public void messageArrived(String topic, MqttMessage message) {
                    log.info("Message received on topic {}: {}", topic, new String(message.getPayload()));
                }

                @Override
                public void deliveryComplete(IMqttDeliveryToken token) {
                    log.info("Message delivered");
                }
            });

            connect(options);

        } catch (Exception e) {
            log.error("Failed to initialize MQTT client", e);
        }
    }
    public MqttConnectOptions getConnectOptions() {
        return options;
    }

    // SSL 소켓 팩토리 생성 메소드
    private SSLSocketFactory getSocketFactory(String caPath, String certPath, String keyPath) throws Exception {
        // CA 인증서 로드
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        FileInputStream caStream = new FileInputStream(caPath);
        X509Certificate caCert = (X509Certificate) cf.generateCertificate(caStream);
        caStream.close();

        // 클라이언트 인증서 로드
        FileInputStream certStream = new FileInputStream(certPath);
        X509Certificate clientCert = (X509Certificate) cf.generateCertificate(certStream);
        certStream.close();

        // 프라이빗 키 로드
        FileInputStream keyStream = new FileInputStream(keyPath);
        byte[] keyBytes = keyStream.readAllBytes();
        keyStream.close();

        PEMParser pemParser = new PEMParser(new StringReader(new String(keyBytes)));
        PEMKeyPair pemKeyPair = (PEMKeyPair) pemParser.readObject();
        PrivateKey privateKey = new JcaPEMKeyConverter().getPrivateKey(pemKeyPair.getPrivateKeyInfo());

        // 키스토어 생성 및 설정
        KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
        keyStore.load(null);
        keyStore.setCertificateEntry("ca-certificate", caCert);
        keyStore.setKeyEntry("client-key", privateKey, new char[0], new Certificate[] { clientCert });

        // 트러스트 매니저 설정
        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(keyStore);

        // 키 매니저 설정
        KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        kmf.init(keyStore, new char[0]);

        // SSL 컨텍스트 설정
        SSLContext context = SSLContext.getInstance("TLSv1.2");
        context.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);

        return context.getSocketFactory();
    }

    private void connect(MqttConnectOptions options) {
        try {
            if (client != null && !client.isConnected()) {
                client.connect(options);
                client.subscribe(topic);
                log.info("Connected to AWS IoT Core");
            }
        } catch (MqttException e) {
            log.error("Failed to connect to AWS IoT Core", e);
        }
    }

    private void reconnect() {
        try {
            Thread.sleep(5000);  // 5초 대기 후 재연결 시도
            connect(options);
        } catch (Exception e) {
            log.error("Failed to reconnect to AWS IoT Core", e);
        }
    }

    public void publishMessage(String topic, String payload) {
        try {
            if (client != null && client.isConnected()) {
                MqttMessage message = new MqttMessage(payload.getBytes());
                message.setQos(1);
                client.publish(topic, message);
                log.info("Published message to topic {}: {}", topic, payload);
            }
        } catch (MqttException e) {
            log.error("Failed to publish message", e);
        }
    }

    @PreDestroy
    public void cleanup() {
        try {
            if (client != null && client.isConnected()) {
                client.disconnect();
                client.close();
                log.info("MQTT client disconnected and cleaned up");
            }
        } catch (MqttException e) {
            log.error("Failed to clean up MQTT client", e);
        }
    }

    public boolean isConnected() {
        return client != null && client.isConnected();
    }
}