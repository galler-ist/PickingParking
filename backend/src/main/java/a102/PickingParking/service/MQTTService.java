//package a102.PickingParking.service;
//import org.springframework.stereotype.Service;
//import com.amazonaws.services.iot.client.*;
//
//@Service
//public class MQTTService {
//    private final AWSIotMqttClient mqttClient;
//
//    public MQTTService(AWSIotMqttClient mqttClient) {
//        this.mqttClient = mqttClient;
//    }
//
//    public void publishLEDControl(String color) {
//        try {
//            mqttClient.publish(
//                    "led_control",
//                    AWSIotQos.QOS1,
//                    color
//            );
//            System.out.println("LED 제어 메시지 발행: " + color);
//        } catch (AWSIotException e) {
//            System.err.println("메시지 발행 에러: " + e.getMessage());
//            // 필요한 예외 처리 추가
//        }
//    }
//
//    public void subscribeToOCR() {
//        try {
//            mqttClient.subscribe(new AWSIotTopic("OCR", AWSIotQos.QOS1) {
//                @Override
//                public void onMessage(AWSIotMessage message) {
//                    String payload = message.getStringPayload();
//                    System.out.println("OCR 결과 수신: " + payload);
//                    // OCR 결과 처리 로직 추가
//                }
//            });
//            System.out.println("OCR 토픽 구독 시작");
//        } catch (AWSIotException e) {
//            System.err.println("구독 에러: " + e.getMessage());
//            // 필요한 예외 처리 추가
//        }
//    }
//}
//
////@Service
////public class MQTTService {
////    private final AWSIotMqttClient mqttClient;
////    private final HttpMessageConverters messageConverters;
////
////    public MQTTService(AWSIotMqttClient mqttClient, HttpMessageConverters messageConverters) {
////        this.mqttClient = mqttClient;
////        this.messageConverters = messageConverters;
////    }
////
////    // LED 조절용 MQTT 토픽 메세지 publish
////    public void publishLEDControl(String color){
////        try {
////            mqttClient.publish(
////                    "led_control",
////                    AWSIotQos.QOS1,
////                    color
////            );
////            System.out.println("LED 제어 메시지 발행: " + color);
////        } catch (Exception e) {
////            System.err.println("메세지 발행 에러: "+e.getMessage());
////        }
////    }
////
////    // OCR 결과 받기 (subscribe)
////    public void subscribeToOCR(){
////        try{
////            mqttClient.subscribe(new AWSIotTopic("OCR",AWSIotQos.QOS1)){
////                    @Override
////                    public void onMessage(AWSIotMessage message){
////                    //OCR 결과 수신 시 실행되는 콜백
////                    String payload = message.getStringPayload();
////                    System.out.println("OCR 결과 수신 : "+payload);
////
////                    // 여기서 결과 수신 이후로 어떻게 할지 로직 작성하면 됨
////                    /*
////
////                     */
////                }
////            });
////            System.out.println("OCR 토픽 구독 시작");
////        } catch (Exception e){
////            System.err.println("구독 에러: " + e.getMessage());
////        }
////    }
////
////
////}
