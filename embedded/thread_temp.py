# -*- coding: utf-8 -*-
import threading
import time
import queue
import os
import json
import cv2
from MQTT import MQTTBuilder
from dotenv import load_dotenv
from OCR import CameraOCRManager
from model import ObjectDetector
from LED import LEDController

colors = ["R", "G", "Y", "Black"]

# SensorCameraThread 클래스
class SensorCameraThread(threading.Thread):
    def __init__(self, sensor_queue, mqtt_publish_queue, pause_event):
        super().__init__()
        self.sensor_queue = sensor_queue
        self.mqtt_publish_queue = mqtt_publish_queue
        self.camera_ocr = CameraOCRManager()
        self.running = True
        self.detector = ObjectDetector()
        self.pause_event = pause_event  # Event 객체로 스레드 제어

        self.cnt = 0
        self.is_car_present = False
        self.check_interval = 6
        cv2.setNumThreads(1)  # OpenCV 스레드 수 제한

    def run(self):
        while self.running:
            self.pause_event.wait()  # OCR 스레드가 일시정지 상태라면 대기
            try:
                detected = self.detector.detect_once()
                print(f'번호판 감지 상태: {detected}')

                if not self.is_car_present:
                    if detected:
                        self.cnt += 1
                        print(f'연속 True 감지: {self.cnt}회')
                        if self.cnt >= 2:
                            self.is_car_present = True
                            self.cnt = 0
                            self.start_ocr_sequence()
                            self.check_interval = 6
                        else:
                            self.check_interval = 3
                    else:
                        self.cnt = 0
                        self.check_interval = 6
                else:
                    if not detected:
                        self.cnt += 1
                        print(f'연속 False 감지: {self.cnt}회')
                        if self.cnt >= 2:
                            self.is_car_present = False
                            self.cnt = 0
                            self.check_interval = 6
                        else:
                            self.check_interval = 3
                    else:
                        self.cnt = 0
                        self.check_interval = 6

                print(f'{self.check_interval}초 대기')
                time.sleep(self.check_interval)
            except Exception as e:
                print(f'감지 스레드에서 에러 발생: {e}')

    def start_ocr_sequence(self):
        try:
            result = self.camera_ocr.capture_and_process()
            if result:
                self.mqtt_publish_queue.put({
                    'topic': 'OCR',
                    'message': {'result': result}
                })
        except Exception as e:
            print(f'OCR 에러: {e}')

    def stop(self):
        self.running = False
        self.is_car_present = False
        self.cnt = 0
        self.check_interval = 6

# MqttPublishThread 클래스
class MqttPublishThread(threading.Thread):  # 보드에서 송신할건 OCR 정보밖에 없음
    def __init__(self, mqtt_publish_queue, mqtt_client):
        super().__init__()
        self.mqtt_publish_queue = mqtt_publish_queue
        self.mqtt_client = mqtt_client
        self.running = True

    def run(self):
        while self.running:
            try:
                message = self.mqtt_publish_queue.get(timeout=1)
                self.mqtt_client.publishMessage(
                    topic=message['topic'],
                    messageString=message['message'],
                )
            except queue.Empty:
                continue

            except Exception as e:
                print(f'퍼블리시 스레드 에러 : {e}')

    def stop(self):
        self.running = False

# MQTTSubscriberThread 클래스
class MQTTSubscriberThread(threading.Thread):
    def __init__(self, mqtt_client, led_queue):
        super().__init__()
        self.mqtt_client = mqtt_client
        self.led_queue = led_queue
        self.running = True
        self.mqtt_client.client.on_message = self.on_message_received

    def run(self):
        print("MQTT 구독 스레드 시작")
        while self.running:
            try:
                time.sleep(0.1)
            except Exception as e:
                print(f'Sub 스레드 문제 발생: {e}')

    def on_message_received(self, client, userdata, message):
        try:
            topic = message.topic
            payload = message.payload
            print(f"메시지 수신: topic={topic}, payload={payload}")

            if topic == 'led_control':
                message_str = payload.decode('utf-8').strip()
                message_json = json.loads(message_str)
                color = message_json.get('color', '').upper()

                if color in colors:
                    print(f'LED 큐에 색상 추가: {color}')
                    self.led_queue.put(color)
                else:
                    print(f'잘못된 LED 명령: {color}')
        except Exception as e:
            print(f'메시지 처리 에러: {e}')

    def stop(self):
        self.running = False

# LEDControlThread 클래스
class LEDControlThread(threading.Thread):
    def __init__(self, led_queue, led_controller, pause_event):
        super().__init__()
        self.led_queue = led_queue
        self.led_controller = led_controller
        self.pause_event = pause_event  # Event 객체로 스레드 제어
        self.running = True

    def run(self):
        print("LED 제어 스레드 시작")
        while self.running:
            try:
                command = self.led_queue.get(timeout=1)
                print(f'LED 제어 명령 수신: {command}')

                if command in colors:
                    self.pause_event.clear()  # OCR 스레드 일시정지
                    for attempt in range(3):
                        print(f'{command} 색상 변경 시도 {attempt + 1}회')
                        success = self.led_controller.set_color(command)
                        if success:
                            print(f'{command} 색상 변경 성공')
                            break
                        else:
                            print(f'{command} 색상 변경 실패, 재시도')
                            time.sleep(0.5)
                    self.pause_event.set()  # 색상 변경 완료 후 OCR 스레드 재개
                else:
                    print(f'잘못된 명령: {command}')
            except queue.Empty:
                continue
            except Exception as e:
                print(f'LED 제어 스레드 에러: {e}')

    def stop(self):
        self.running = False

# ThreadManager 클래스
class ThreadManager:
    def __init__(self):
        self.sensor_queue = queue.Queue()
        self.mqtt_publish_queue = queue.Queue()
        self.led_queue = queue.Queue()
        self.pause_event = threading.Event()
        self.pause_event.set()  # 초기 상태에서 OCR 스레드 활성화

        self.led_controller = LEDController()
        self.led_controller.create_color_images()
        print("색상 이미지 생성 완료")
        self.led_controller.set_color('Black')

        load_dotenv()
        self.END_POINT = os.environ.get('END_POINT')
        self.CERT_FILE_PATH = os.environ.get('CERT_FILE_PATH')
        self.CA_FILE_PATH = os.environ.get('CA_FILE_PATH')
        self.PRI_KEY_FILE_PATH = os.environ.get('PRI_KEY_FILE_PATH')

        self.mqtt_client = MQTTBuilder(). \
            setEndpoint(self.END_POINT). \
            setPort(). \
            setCertFilepath(self.CERT_FILE_PATH). \
            setCaFilepath(self.CA_FILE_PATH). \
            setPriKeyFilepath(self.PRI_KEY_FILE_PATH). \
            setClientId("JetsonNano"). \
            setConnection(). \
            addTopic(['led_control', ])

        self.threads = {
            'sensor_camera': SensorCameraThread(self.sensor_queue, self.mqtt_publish_queue, self.pause_event),
            'mqtt_publish': MqttPublishThread(self.mqtt_publish_queue, self.mqtt_client),
            'mqtt_subscribe': MQTTSubscriberThread(self.mqtt_client, self.led_queue),
            'led_control': LEDControlThread(self.led_queue, self.led_controller, self.pause_event)
        }

    def start_threads(self):
        for name, thread in self.threads.items():
            print(f'{name} 스레드 시작')
            thread.start()

    def stop_threads(self):
        for name, thread in self.threads.items():
            print(f'{name} 스레드 종료')
            thread.stop()
            thread.join()

def main():
    manager = ThreadManager()
    try:
        print('전체 스레드 시작')
        manager.start_threads()
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print('스레드 종료 중...')
        manager.stop_threads()
    except Exception as e:
        print(f'메인 스레드 에러: {e}')

if __name__ == '__main__':
    main()
