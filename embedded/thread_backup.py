# -*- coding: utf-8 -*-
# thread.py
import threading
import time
import queue
from MQTT import MQTTBuilder
from dotenv import load_dotenv
from OCR import CameraOCRManager
import os
from model import ObjectDetector
# from LED_temp import LEDController
import json
import cv2

#################
colors = ["R", "G", "Y",'Black']


class SensorCameraThread(threading.Thread):
    def __init__(self, sensor_queue, mqtt_publish_queue):
        super().__init__()
        self.sensor_queue = sensor_queue
        self.mqtt_publish_queue = mqtt_publish_queue
        self.camera_ocr = CameraOCRManager()
        self.running = True
        self.detector = ObjectDetector()

        # 연속 감지 확인하려고 변수 만들어둠
        self.cnt = 0
        self.is_car_present = False # 이걸로 현재 자동차 있는지 판단할거임
        self.check_interval = 6

    def run(self):
        while self.running:
            try:
                # TODO : 여기 메서드 이름 models.py에서 우호형이 만든 이름에 따라 바꿔야함
                detected = self.detector.detect_once() # todo 여기서 models.py 메서드 처리
                # detected는 True/False
                print(f'번호판 감지 상태 :  {detected}')
                # 현재 차량이 있는 상태

                if not self.is_car_present: # 차량이 없을 때
                    if detected: # 차량이 없는 줄 알았는데 true가 떴을 때
                        self.cnt += 1
                        print(f'연속 True 감지 : {True} * {self.cnt}')
                        if self.cnt>=2:
                            print('차량 존재 확정 -> ocr 실시')
                            self.is_car_present = True
                            self.cnt = 0
                            self.start_ocr_sequence()
                            self.check_interval = 3 # 다시 60초 간격으로 실시하도록 변경
                            # 여기서 mqtt 보낼건지 고민
                        else: # 아직 확정지으려면 조금 더 체크해야할 때
                            self.check_interval = 3
                    else: #그냥 없다고 감지된거임
                        self.cnt = 0
                        self.check_interval = 3
                else: # 차량이 있다고 판단되어 있는 상태
                    if not detected: #차가 있다고 판단되었었는데, false가 떴을 때
                        self.cnt +=1
                        print(f'연속 False 감지: {False}*{self.cnt}')

                        if self.cnt>=2: # 연속으로 False 5번 감지
                            print('차량 없음 확정')
                            self.is_car_present = False
                            self.cnt = 0
                            self.check_interval = 3
                            # TODO : MQTT 보낼 지
                        else:
                            self.check_interval = 3
                    else:
                        self.cnt = 0
                        self.check_interval = 3
                print(f'{self.check_interval}초 대기')
                time.sleep(self.check_interval)
            except Exception as e:
                print(f'!!!!!!!감지 스레드에서 에러 남!!!!!!!!!!!')
                print(f"{e}")
                print("===========================================")


    def start_ocr_sequence(self):
        # while self.detected and self.ocr_cnt < self.max_ocr_cnt:
        try:
            # OCR 수행
            # 일단 압력 상태부터 다시 확인
            result = self.camera_ocr.capture_and_process()
            if result:
                self.mqtt_publish_queue.put({
                    'topic': 'OCR',
                    'message': {
                        'result':result}
                })

        except Exception as e:
            print(f'OCR 에러 : {e}')

    def stop(self):
        self.running = False
        self.is_car_present = False
        self.cnt = 0
        self.check_interval = 6


# class SensorCameraThread(threading.Thread):
#     def __init__(self, sensor_queue, mqtt_publish_queue):
#         super().__init__()
#         self.sensor_queue = sensor_queue
#         self.mqtt_publish_queue = mqtt_publish_queue
#         self.camera_ocr = CameraOCRManager()
#         self.running = True
#         self.detector = ObjectDetector()
#
#         # 연속 감지 확인하려고 변수 만들어둠
#         self.cnt = 0
#         self.is_car_present = False
#         self.check_interval = 6
#
#         # OpenCV 설정
#         cv2.setNumThreads(1)  # OpenCV 스레드 수 제한
#
#     def run(self):
#         while self.running:
#             try:
#                 # 카메라/감지 작업 전에 창 처리
#                 cv2.destroyWindow("camera_window")  # 이전 창이 있다면 제거
#                 time.sleep(0.1)  # 잠시 대기
#
#                 detected = self.detector.detect_once()
#                 print(f'번호판 감지 상태 : {detected}')
#
#                 if not self.is_car_present:
#                     if detected:
#                         self.cnt += 1
#                         print(f'연속 True 감지 : {True} * {self.cnt}')
#                         if self.cnt >= 2:
#                             print('차량 존재 확정 -> ocr 실시')
#                             self.is_car_present = True
#                             self.cnt = 0
#                             self.start_ocr_sequence()
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#                 else:
#                     if not detected:
#                         self.cnt += 1
#                         print(f'연속 False 감지: {False}*{self.cnt}')
#
#                         if self.cnt >= 2:
#                             print('차량 없음 확정')
#                             self.is_car_present = False
#                             self.cnt = 0
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#
#                 # 카메라/감지 작업 후 창 정리
#                 cv2.destroyWindow("camera_window")
#                 time.sleep(0.1)  # 잠시 대기
#
#                 print(f'{self.check_interval}초 대기')
#                 time.sleep(self.check_interval)
#
#             except Exception as e:
#                 print(f'!!!!!!!감지 스레드에서 에러 남!!!!!!!!!!!')
#                 print(f"{e}")
#                 print("===========================================")


# class SensorCameraThread(threading.Thread):
#     def __init__(self, sensor_queue, mqtt_publish_queue, pause_event):
#         super().__init__()
#         self.sensor_queue = sensor_queue
#         self.mqtt_publish_queue = mqtt_publish_queue
#         self.camera_ocr = CameraOCRManager()
#         self.running = True
#         self.detector = ObjectDetector()
#         self.pause_event = pause_event  # Event 객체로 스레드 제어
#
#         self.cnt = 0
#         self.is_car_present = False
#         self.check_interval = 6
#         cv2.setNumThreads(1)  # OpenCV 스레드 수 제한
#
#     def run(self):
#         while self.running:
#             # OCR 스레드가 일시정지 상태라면 대기
#             self.pause_event.wait()
#
#             try:
#                 detected = self.detector.detect_once()
#                 print(f'번호판 감지 상태 : {detected}')
#
#                 if not self.is_car_present:
#                     if detected:
#                         self.cnt += 1
#                         print(f'연속 True 감지 : {True} * {self.cnt}')
#                         if self.cnt >= 2:
#                             print('차량 존재 확정 -> ocr 실시')
#                             self.is_car_present = True
#                             self.cnt = 0
#                             self.start_ocr_sequence()
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#                 else:
#                     if not detected:
#                         self.cnt += 1
#                         print(f'연속 False 감지: {False}*{self.cnt}')
#                         if self.cnt >= 2:
#                             print('차량 없음 확정')
#                             self.is_car_present = False
#                             self.cnt = 0
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#
#                 print(f'{self.check_interval}초 대기')
#                 time.sleep(self.check_interval)
#             except Exception as e:
#                 print(f'!!!!!!!감지 스레드에서 에러 남!!!!!!!!!!!')
#                 print(f"{e}")
#                 print("===========================================")
#
#     def start_ocr_sequence(self):
#         try:
#             result = self.camera_ocr.capture_and_process()
#             if result:
#                 self.mqtt_publish_queue.put({
#                     'topic': 'OCR',
#                     'message': {'result': result}
#                 })
#         except Exception as e:
#             print(f'OCR 에러 : {e}')
#
#     def stop(self):
#         self.running = False
#         self.is_car_present = False
#         self.cnt = 0
#         self.check_interval = 6


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


# class MQTTSubscriberThread(threading.Thread):
#     def __init__(self, mqtt_client, led_queue):
#         super().__init__()
#         self.mqtt_client = mqtt_client
#         self.led_queue = led_queue
#         self.running = True
#
#         # MQTT 콜백 함수 설정
#         self.mqtt_client.set_message_callback(self.on_message_received)
#         print('MQTT 콜백 함수 설정 완료')
#
#
#     def run(self):
#         print("MQTT 구독 스레드 시작")
#         while self.running:
#             try:
#                 time.sleep(0.1)
#             except Exception as e:
#                 print(f'Sub 스레드 문제 발생: {e}')
#
#     def on_message_received(self, topic, payload, dup, qos, retain, **kwargs):
#         print()
#         print()
#         print()
#         print()
#         print()
#         print()
#         print(f'==================콜백함수실행================')
#         print()
#         print()
#         print()
#         print()
#         print()
#         print()
#         try:
#             print(f"메시지 수신: topic={topic}, payload={payload}")
#             if topic == 'led_control':
#                 message_str = payload.decode('utf-8').strip()
#                 message_json = json.loads(message_str)
#                 color = message_json.get('color', '').upper()
#                 print(f'!!!!!!!!!!!!!color : {color}!!!!!!!!!!!!!!!!!')
#
#                 if color in colors:
#                     print(f'LED 큐에 색상 추가: {color}')
#                     self.led_queue.put(color)
#                 else:
#                     print(f'잘못된 LED 명령: {color}')
#         except json.JSONDecodeError as e:
#             print(f'JSON 디코드 에러: {e}')
#         except Exception as e:
#             print(f'메시지 처리 에러: {e}')
#
#     def stop(self):
#         self.running = False

class MQTTSubscriberThread(threading.Thread):
    def __init__(self,mqtt_client,led_queue):
        super().__init__()
        self.mqtt_client = mqtt_client
        self.led_queue = led_queue
        self.running = True
        self.mqtt_client._onMessageReceived = self.on_message_received
        # ? todo 이 부분 좀 해결. 메세지 리시브 받는거랑, return 등 의문점 많음
    def run(self):
        while self.running:
            try:
                time.sleep(0.1)
            except Exception as e:
                print(f'Sub 스레드 문제 발생 : {e}')

    def on_message_received(self, topic, payload,**kwargs):
        if topic == 'led_control': # 일단 임시 토픽
            message = json.loads(payload)
            self.led_queue.put(message)
            print(f"LED 메세지 받음: {message}")

    def stop(self):
        self.running = False


# class MQTTSubscriberThread(threading.Thread):
#     def __init__(self, mqtt_client, led_queue):
#         super().__init__()
#         self.mqtt_client = mqtt_client
#         self.led_queue = led_queue
#         self.running = True
#         self.mqtt_client._onMessageReceived = self.on_message_received
#         # ? todo 이 부분 좀 해결. 메세지 리시브 받는거랑, return 등 의문점 많음
#         # self.mqtt_client._on_message = self.on_message_received
#
#     def run(self):
#         while self.running:
#             try:
#                 time.sleep(0.1)
#                 self.mqtt_client.client.loop(timeout=1.0)
#                 time.sleep(0.1)
#             except Exception as e:
#                 print(f'Sub 스레드 문제 발생 : {e}')
#
#     def on_message_received(self, topic, payload, **kwargs):
#         try:
#             if topic == 'led_control':
#                 # 메시지가 JSON 형식일 경우
#                 message_str = payload.decode('utf-8').strip()
#                 message_json = json.loads(message_str)
#                 color = message_json.get('color', '').upper()
#                 if color in colors:
#                     self.led_queue.put(color)
#                     print(f'LED 명령 수신 : {color}')
#                 else:
#                     print(f'잘못된 LED 명령 : {color}')
#         except json.JSONDecodeError:
#             print('JSON 디코드 에러')
#         except Exception as e:
#             print(f'명령 수신 에러 : {e}')
#
#     def stop(self):
#         self.running = False


# class LEDControlThread(threading.Thread):
#     def __init__(self, led_queue, led_controller):
#         super().__init__()
#         self.led_queue = led_queue
#         self.led_controller = led_controller
#         self.running = True
#
#     def run(self):
#         print("LED 제어 스레드 시작")
#         time.sleep(1)  # 초기화를 위한 대기
#
#         while self.running:
#             try:
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED 제어 스레드: 색상 변경 명령 수신 - {command}')
#
#                 if command in colors:
#                     for attempt in range(3):  # 최대 3번 시도
#                         print(f'LED 제어 스레드: {command} 색상 변경 시도 {attempt + 1}')
#
#                         # 다른 창들 정리
#                         cv2.destroyWindow("camera_window")
#                         time.sleep(0.2)
#
#                         success = self.led_controller.set_color(command)
#
#                         if success:
#                             print(f'LED 제어 스레드: {command} 색상 변경 성공')
#                             break
#                         else:
#                             print(f'LED 제어 스레드: {command} 색상 변경 실패, 재시도 준비')
#                             time.sleep(0.5)
#                 else:
#                     print(f'LED 제어 스레드: 잘못된 색상 명령 - {command}')
#
#             except queue.Empty:
#                 pass
#             except Exception as e:
#                 print(f'LED 제어 스레드 에러: {e}')
# class LEDControlThread(threading.Thread):
#     def __init__(self, led_queue, led_controller, pause_event):
#         super().__init__()
#         self.led_queue = led_queue
#         self.led_controller = led_controller
#         self.pause_event = pause_event  # Event 객체로 스레드 제어
#         self.running = True
#
#     def run(self):
#         print("LED 제어 스레드 시작")
#         while self.running:
#             try:
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED 제어 스레드: 색상 변경 명령 수신 - {command}')
#
#                 if command in colors:
#                     # OCR 스레드 일시정지
#                     self.pause_event.clear()
#                     for attempt in range(3):
#                         print(f'LED 제어 스레드: {command} 색상 변경 시도 {attempt + 1}')
#                         success = self.led_controller.set_color(command)
#                         if success:
#                             print(f'LED 제어 스레드: {command} 색상 변경 성공')
#                             break
#                         else:
#                             print(f'LED 제어 스레드: {command} 색상 변경 실패, 재시도 준비')
#                             time.sleep(0.5)
#                     # 색상 변경 완료 후 OCR 스레드 재개
#                     self.pause_event.set()
#                 else:
#                     print(f'LED 제어 스레드: 잘못된 색상 명령 - {command}')
#             except queue.Empty:
#                 continue
#             except Exception as e:
#                 print(f'LED 제어 스레드 에러: {e}')
#
#     def stop(self):
#         self.running = False





# class LEDControlThread(threading.Thread):
#     def __init__(self, led_queue,led_controller):
#         super().__init__()
#         self.led_queue = led_queue
#         self.led_controller = led_controller
#         self.running = True
#
#     def run(self):
#         print("LED 제어 스레드 시작")
#         while self.running:
#             try:
#                 # 큐에서 메시지 가져오기
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED 색상 변경 시도: {command}')
#
#                 if command in colors:
#                     print(f'LED 색상 변경 실행: {command}')
#                     self.led_controller.set_color(command)
#                 else:
#                     print(f'잘못된 색상 명령: {command}')
#
#             except queue.Empty:
#                 pass
#             except Exception as e:
#                 print(f'LED 제어 에러: {e}')
#
#     def stop(self):
#         print("LED 제어 스레드 종료")
#         self.running = False


# class LEDControlThread(threading.Thread):
#    def __init__(self, led_queue):
#        super().__init__()
#        self.led_queue = led_queue
#
#        self.led_controller = LEDController()
#        self.running = True
#
#    def run(self):
#        while self.running:
#             try:
#                # 쿠에서 메세지 가져오기
#                command = self.led_queue.get(timeout=1)
#                if command in colors:
#                    print(f'LED 색상 변경 명령 수신 : {command}')
#                    self.led_controller.set_color(command)
#                else:
#                    print(f'사용할 수 없는 색상 명령 : {command}')
#
#             except queue.Empty:
#                 # print('아직 queue가 비어있음')
#                 pass
#             except Exception as e:
#                 print(f'LED 스레드에서 에러 발생 : {e}')
#
#    def stop(self):
#        self.running = False
#        self.led_controller.cleanup()

    #
    # def __init__(self):
    #     self.sensor_queue = queue.Queue()
    #     self.mqtt_publish_queue = queue.Queue()
    #     self.led_queue = queue.Queue()
    #
    #     print("LED 컨트롤러 초기화 시작")
    #     if os.geteuid() != 0:
    #         print("프레임버퍼 접근을 위해 root 권한이 필요합니다")
    #         raise PermissionError("root 권한 필요")
    #
    #     self.led_controller = LEDController()
    #     print("색상 이미지 생성 시작")
    #     self.led_controller.create_color_images()
    #     self.led_controller.set_color('Black')


class ThreadManager:
    def __init__(self):
        # 큐 초기화부터
        self.sensor_queue = queue.Queue()
        self.mqtt_publish_queue = queue.Queue()
        self.led_queue = queue.Queue()

        # self.led_controller = LEDController()
        # self.led_controller.create_color_images()
        # print("!!!!!!!!!!!!색 설정 완료!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        # self.led_controller.set_color('Black')  # 초기 화면을 검은색으로 설정
        # print('!!!!!!!!!!!!!초기화면 설정 완료!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        load_dotenv()
        self.END_POINT = os.environ.get('END_POINT')
        self.CERT_FILE_PATH = os.environ.get('CERT_FILE_PATH')
        self.CA_FILE_PATH = os.environ.get('CA_FILE_PATH')
        self.PRI_KEY_FILE_PATH = os.environ.get('PRI_KEY_FILE_PATH')

        print("CertPath:{}".format(self.CERT_FILE_PATH))
        print(f'CA PATH : {self.CA_FILE_PATH}')
        print(f'PRI_KEY : {self.PRI_KEY_FILE_PATH}')

        # 클라이언트 초기화
        # 여기서 addTopic 해야하나? -> 캍
        self.mqtt_client = MQTTBuilder(). \
            setEndpoint(self.END_POINT). \
            setPort(). \
            setCertFilepath(self.CERT_FILE_PATH). \
            setCaFilepath(self.CA_FILE_PATH). \
            setPriKeyFilepath(self.PRI_KEY_FILE_PATH). \
            setClientId("JetsonNano"). \
            setConnection(). \
            addTopic(['led_control', ])

        # 스레드 초기화
        self.threads = {
            'sensor_camera': SensorCameraThread(
                self.sensor_queue,
                self.mqtt_publish_queue),
            'mqtt_publish': MqttPublishThread(
                self.mqtt_publish_queue,
                self.mqtt_client),
            'mqtt_subscribe': MQTTSubscriberThread(
                self.mqtt_client,
                self.led_queue
            ),
           # 'led_control': LEDControlThread(
           #     self.led_queue,self.led_controller
           #  ),
        }

    # 스레드가 끊겼을 것을 대비해서 스레드 감시용 스레드 처리
    def monitor_threads(self):
        while True:
            for thread_name, thread in self.threads.items():
                if not thread.is_alive():
                    logger.warning(f"{thread_name} 다시 시작")
                    new_thread = type(thread)(*thread.__init__args)
                    new_thread.start()
                    self.threads[thread_name] = new_thread
            time.sleep(10)  # 10초마다 체크

    # 전체 스레드 시작 메서드
    def start_threads(self):
        for thread_name, thread in self.threads.items():
            print(f'{thread_name} 스레드 실행')
            thread.start()
        threading.Thread(target=self.monitor_threads, daemon=True).start()

    # 전체 스레드 종료 메서드
    def stop_threads(self):
        for thread_name, thread in self.threads.items():
            print(f'{thread_name} 스레드 종료')
            thread.stop()
            thread.join()


def main():
    manager = ThreadManager()
    pause_event = threading.Event()
    pause_event.set()  # 초기 상태에서 OCR 스레드 활성화
    try:
        print()
        print('=================전체 스레드 시작=============')
        manager.start_threads()
        # 메인 스레드 유지용
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print('스레드 종료 중')
        manager.stop_threads()
        print('=================전체 스레드 종료=================')
        print()
    except Exception as e:
        print(f'스레드 매니저 오류 : {e}')


if __name__ == '__main__':
    main()
