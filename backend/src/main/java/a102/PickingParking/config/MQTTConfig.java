//package a102.PickingParking.config;
//import io.github.cdimascio.dotenv.Dotenv;
//import lombok.extern.slf4j.Slf4j;
//import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
//import org.bouncycastle.openssl.PEMKeyPair;
//import org.bouncycastle.openssl.PEMParser;
//import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
//import org.eclipse.paho.client.mqttv3.*;
//import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
//import org.springframework.context.annotation.Configuration;
//import jakarta.annotation.PostConstruct;
//import jakarta.annotation.PreDestroy;
//
//import javax.net.ssl.KeyManagerFactory;
//import javax.net.ssl.SSLContext;
//import javax.net.ssl.SSLSocketFactory;
//import javax.net.ssl.TrustManagerFactory;
//import java.io.IOException;
//import java.io.InputStream;
//import java.io.StringReader;
//import java.nio.charset.StandardCharsets;
//import java.security.KeyStore;
//import java.security.PrivateKey;
//import java.security.cert.Certificate;
//import java.security.cert.CertificateFactory;
//import java.security.cert.X509Certificate;
//
//
//
//@Configuration
//@Slf4j
//public class MQTTConfig {
//    private MqttClient client;
//    private MqttConnectOptions options;
//    private final String topic = "mqtt_test";
//
//    private String loadResourceAsString(String resourcePath) throws IOException {
//        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream(resourcePath)) {
//            if (inputStream == null) {
//                throw new IOException("Resource not found: " + resourcePath);
//            }
//            return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
//        }
//    }
//
//    private InputStream loadResource(String resourcePath) throws IOException {
//        InputStream inputStream = getClass().getClassLoader().getResourceAsStream(resourcePath);
//        if (inputStream == null) {
//            throw new IOException("Resource not found: " + resourcePath);
//        }
//        return inputStream;
//    }
//
//    @PostConstruct
//    public void init() {
//        try {
//            Dotenv dotenv = Dotenv.load();
//            String broker = "ssl://" + dotenv.get("AWS_IOT_ENDPOINT") + ":8883";
//            String clientId = dotenv.get("AWS_CLIENT_ID");
//
//            // 인증서 리소스 로드
//            String certPath = "certs/certificate.pem.crt";
//            String keyPath = "certs/private.pem.key";
//            String caPath = "certs/AmazonRootCA1.pem";
//
//            log.info("Loading certificates...");
//
//            client = new MqttClient(broker, clientId, new MemoryPersistence());
//
//            options = new MqttConnectOptions();
//            options.setCleanSession(true);
//            options.setKeepAliveInterval(60);
//            options.setConnectionTimeout(30);
//
//            // SSL 설정
//            SSLSocketFactory socketFactory = getSSLSocketFactory(caPath, certPath, keyPath);
//            options.setSocketFactory(socketFactory);
//
//            // 연결 콜백
//            client.setCallback(new MqttCallback() {
//                @Override
//                public void connectionLost(Throwable cause) {
//                    log.error("Connection lost! Trying to reconnect...", cause);
//                    reconnect();
//                }
//
//                @Override
//                public void messageArrived(String topic, MqttMessage message) {
//                    log.info("Message received on topic {}: {}", topic, new String(message.getPayload()));
//                }
//
//                @Override
//                public void deliveryComplete(IMqttDeliveryToken token) {
//                    log.info("Message delivered");
//                }
//            });
//
//            connect(options);
//
//            // ==============test==========
//            if (client.isConnected()) {
//                String payload = "Hello from PickingParking!";
//                publishMessage(topic, payload);
//                log.info("Initial message published successfully");
//            } else {
//                log.warn("Client is not connected. Unable to publish initial message.");
//            }
//            //=====================================
//
//        } catch (Exception e) {
//            log.error("Failed to initialize MQTT client", e);
//            throw new RuntimeException("Failed to initialize MQTT client", e);
//        }
//    }
//
//    private SSLSocketFactory getSSLSocketFactory(String caPath, String certPath, String keyPath) throws Exception {
//        // CA 인증서 로드
//        CertificateFactory cf = CertificateFactory.getInstance("X.509");
//        X509Certificate caCert;
//        try (InputStream caInputStream = loadResource(caPath)) {
//            caCert = (X509Certificate) cf.generateCertificate(caInputStream);
//        }
//
//        // 클라이언트 인증서 로드
//        X509Certificate clientCert;
//        try (InputStream certInputStream = loadResource(certPath)) {
//            clientCert = (X509Certificate) cf.generateCertificate(certInputStream);
//        }
//
//        // 프라이빗 키 로드
//        PEMParser pemParser = new PEMParser(new StringReader(loadResourceAsString(keyPath)));
//        Object object = pemParser.readObject();
//        PrivateKey privateKey;
//
//        if (object instanceof PEMKeyPair) {
//            privateKey = new JcaPEMKeyConverter().getPrivateKey(((PEMKeyPair) object).getPrivateKeyInfo());
//        } else if (object instanceof PrivateKeyInfo) {
//            privateKey = new JcaPEMKeyConverter().getPrivateKey((PrivateKeyInfo) object);
//        } else {
//            throw new IllegalStateException("Unexpected key format");
//        }
//
//        // 키스토어 설정
//        KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
//        keyStore.load(null);
//        keyStore.setCertificateEntry("ca-certificate", caCert);
//        keyStore.setKeyEntry("client-key", privateKey, new char[0], new Certificate[]{clientCert});
//
//        // SSL 컨텍스트 설정
//        KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
//        kmf.init(keyStore, new char[0]);
//
//        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
//        tmf.init(keyStore);
//
//        SSLContext context = SSLContext.getInstance("TLSv1.2");
//        context.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);
//
//        return context.getSocketFactory();
//    }
//
//    private void connect(MqttConnectOptions options) {
//        try {
//            if (client != null && !client.isConnected()) {
//                client.connect(options);
//                client.subscribe(topic);
//                log.info("Connected to AWS IoT Core");
//            }
//        } catch (MqttException e) {
//            log.error("Failed to connect to AWS IoT Core", e);
//        }
//    }
//
//    private void reconnect() {
//        try {
//            Thread.sleep(5000);  // 5초 대기
//            connect(options);
//        } catch (Exception e) {
//            log.error("Failed to reconnect to AWS IoT Core", e);
//        }
//    }
//
//    public void publishMessage(String topic, String payload) {
//        try {
//            if (client != null && client.isConnected()) {
//                MqttMessage message = new MqttMessage(payload.getBytes());
//                message.setQos(1);
//                client.publish(topic, message);
//                log.info("Published message to topic {}: {}", topic, payload);
//            }
//        } catch (MqttException e) {
//            log.error("Failed to publish message", e);
//        }
//    }
//
//    public boolean isConnected() {
//        return client != null && client.isConnected();
//    }
//
//    @PreDestroy
//    public void cleanup() {
//        try {
//            if (client != null && client.isConnected()) {
//                client.disconnect();
//                client.close();
//                log.info("MQTT client disconnected and cleaned up");
//            }
//        } catch (MqttException e) {
//            log.error("Failed to clean up MQTT client", e);
//        }
//    }
//}
package a102.PickingParking.config;

import a102.PickingParking.entity.ZoneStatus;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.cdimascio.dotenv.Dotenv;
import lombok.extern.slf4j.Slf4j;
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.openssl.PEMKeyPair;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

@Configuration
@Slf4j
public class MQTTConfig {
    private MqttClient client;
    private MqttConnectOptions options;
    private final String topic = "mqtt_test";
    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostConstruct
    public void init() {
        try {
            Dotenv dotenv = Dotenv.load();
            String broker = "ssl://" + dotenv.get("AWS_IOT_ENDPOINT") + ":8883";
            String clientId = dotenv.get("AWS_CLIENT_ID");

            String certPath = "certs/certificate.pem.crt";
            String keyPath = "certs/private.pem.key";
            String caPath = "certs/AmazonRootCA1.pem";

            log.info("Loading certificates...");

            client = new MqttClient(broker, clientId, new MemoryPersistence());

            options = new MqttConnectOptions();
            options.setCleanSession(true);
            options.setKeepAliveInterval(60);
            options.setConnectionTimeout(30);

            SSLSocketFactory socketFactory = getSSLSocketFactory(caPath, certPath, keyPath);
            options.setSocketFactory(socketFactory);

            client.setCallback(new MqttCallback() {
                @Override
                public void connectionLost(Throwable cause) {
                    log.error("Connection lost! Trying to reconnect...", cause);
                    reconnect();
                }

                @Override
                public void messageArrived(String topic, MqttMessage message) {
                    log.info("Message received on topic {}: {}", topic, new String(message.getPayload()));
                    handleIncomingMessage(new String(message.getPayload()));
                }

                @Override
                public void deliveryComplete(IMqttDeliveryToken token) {
                    log.info("Message delivered");
                }
            });

            connect(options);

            if (client.isConnected()) {
                log.info("Connected to AWS IoT Core and ready to publish/subscribe");
            } else {
                log.warn("Client is not connected.");
            }
        } catch (Exception e) {
            log.error("Failed to initialize MQTT client", e);
            throw new RuntimeException("Failed to initialize MQTT client", e);
        }
    }

    public void publishZoneStatus(ZoneStatus status) {
        try {
            String payload = objectMapper.writeValueAsString(status);
            publishMessage(topic, payload);
            log.info("Published ZoneStatus to MQTT: {}", payload);
        } catch (Exception e) {
            log.error("Failed to publish ZoneStatus", e);
        }
    }

    private void handleIncomingMessage(String payload) {
        try {
            ZoneStatus status = objectMapper.readValue(payload, ZoneStatus.class);
            log.info("Received ZoneStatus: {}", status);

            switch (status) {
                case R:
                    log.info("ZoneStatus is RED (R): Parking zone is restricted.");
                    break;
                case B:
                    log.info("ZoneStatus is BLUE (B): Parking zone is available.");
                    break;
                case Y:
                    log.info("ZoneStatus is YELLOW (Y): Parking zone is reserved.");
                    break;
                default:
                    log.warn("Unknown ZoneStatus received: {}", status);
            }
        } catch (Exception e) {
            log.error("Failed to parse incoming message", e);
        }
    }

    private SSLSocketFactory getSSLSocketFactory(String caPath, String certPath, String keyPath) throws Exception {
        CertificateFactory cf = CertificateFactory.getInstance("X.509");
        X509Certificate caCert;
        try (InputStream caInputStream = loadResource(caPath)) {
            caCert = (X509Certificate) cf.generateCertificate(caInputStream);
        }

        X509Certificate clientCert;
        try (InputStream certInputStream = loadResource(certPath)) {
            clientCert = (X509Certificate) cf.generateCertificate(certInputStream);
        }

        PEMParser pemParser = new PEMParser(new StringReader(loadResourceAsString(keyPath)));
        Object object = pemParser.readObject();
        PrivateKey privateKey;

        if (object instanceof PEMKeyPair) {
            privateKey = new JcaPEMKeyConverter().getPrivateKey(((PEMKeyPair) object).getPrivateKeyInfo());
        } else if (object instanceof PrivateKeyInfo) {
            privateKey = new JcaPEMKeyConverter().getPrivateKey((PrivateKeyInfo) object);
        } else {
            throw new IllegalStateException("Unexpected key format");
        }

        KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
        keyStore.load(null);
        keyStore.setCertificateEntry("ca-certificate", caCert);
        keyStore.setKeyEntry("client-key", privateKey, new char[0], new Certificate[]{clientCert});

        KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        kmf.init(keyStore, new char[0]);

        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(keyStore);

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
            Thread.sleep(5000);
            connect(options);
        } catch (Exception e) {
            log.error("Failed to reconnect to AWS IoT Core", e);
        }
    }

    private void publishMessage(String topic, String payload) {
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

    private InputStream loadResource(String resourcePath) throws IOException {
        InputStream inputStream = getClass().getClassLoader().getResourceAsStream(resourcePath);
        if (inputStream == null) {
            throw new IOException("Resource not found: " + resourcePath);
        }
        return inputStream;
    }

    private String loadResourceAsString(String resourcePath) throws IOException {
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream(resourcePath)) {
            if (inputStream == null) {
                throw new IOException("Resource not found: " + resourcePath);
            }
            return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
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
}