import threading
import time
import queue
from MQTT import MQTTBuilder
from dotenv import load_dotenv
from OCR import CameraOCRManager
import os
#################
class SensorCameraThread(threading.Thread):
    def __init__(self,sensor_queue,mqtt_publish_queue):
        super().__init__()
        self.sensor_queue = sensor_queue
        self.mqtt_publish_queue = mqtt_publish_queue
        self.camera_ocr = CameraOCRManager()
        self.running = True
        self.pressure_detected = False
        self.ocr_cnt = 0
        self.max_ocr_cnt = 5
        self.no_pressure_time = 0
        self.current_pressure = 0 # 현재 존재하는지.

    # todo
    def check_pressure(self):
        # todo 압력 센서 부분인데, 여기 다시 구현해야함
        Threshold = -float('inf') # 일단 임계값은 -무한대로 해놨으니깐 무조건 True 나옴. 이거 실험값으로 바꿔야함.
        # read_pressure_value() 제대로 구현해야함
        pressure_val = self.read_pressure_value()
        return pressure_val > Threshold
    # todo 제대로 구현해야함. 일단 무조건 True 나오도록 뗌빵해놓음
    def read_pressure_value(self):
        return float('inf')
    def run(self):
        while self.running:
            try:
                current_pressure = self.check_pressure() # True or False. 현재 입력되는 압력이 있는지.
                if current_pressure: # 일단 임시용으로 압력센서 없이 돌아가도록 처리
                    self.no_pressure_time = 0
                    #  새로운 입력 감지 후 이전에 감지된 적이 없다면. -> 첫 시작
                    if not self.pressure_detected:
                        print('압력 감지됨. OCR 시작')
                        self.pressure_detected = True
                        self.ocr_cnt = 0
                        self.start_ocr_sequence()
                else: # 압력 신호가 있던 상태에서, 현재 압력이 없다면? -> 1초씩 증가해야지
                    self.no_pressure_time += 1

                if self.no_pressure_time > 5.0 and self.pressure_detected:
                    print('5초간 압력 없음. OCR 중단')
                    self.pressure_detected = False
                    self.ocr_cnt = 0
                time.sleep(1) # 1초 간격으로 체크할거

            except Exception as e:
                print(f'!!! 압력 센서 에러 : {e}')
                # time.sleep(0.1)
                #
                #     result = self.camera_ocr.capture_and_process()
                #     if result:
                #         self.mqtt_publish_queue.put({
                #             'topic': 'OCR',
                #             'message': result
                #         })
                #     time.sleep(0.1)
    def start_ocr_sequence(self):
        # 1분 간격으로 5번 수행
        while self.pressure_detected and self.ocr_cnt < self.max_ocr_cnt:
            try:
                # OCR 수행
                # 일단 압력 상태부터 다시 확인
                if self.no_pressure_time >= 5.0:
                    print('압력 햊로 OCR 시퀀스 중단')
                    break
                result = self.camera_ocr.capture_and_process()
                if result:
                    self.mqtt_publish_queue.put({
                        'topic' : 'OCR',
                        'message' : result
                    })
                    self.ocr_cnt += 1
                    print(f"{self.ocr_cnt+1}회 OCR 수행")

                # 마지막 OCR이 아니면 1분 대기
                if self.ocr_cnt <self.max_ocr_cnt:
                    print('다음 OCR까지 1분 대기')
                    for _ in range(60): # 60초
                        if not self.check_pressure():
                            print('대기 중 압력이 해제되어 OCR을 종료합니다.')
                            self.pressure_detected = False
                            return
                        time.sleep(1)
            except Exception as e:
                print(f'OCR 에러 : {e}')

    def stop(self):
        self.running = False
        self.pressure_detected = False

class MqttPublishThread(threading.Thread): # 보드에서 송신할건 OCR 정보밖에 없음
    def __init__(self,mqtt_publish_queue,mqtt_client):
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


class LEDControlThread(threading.Thread):
    def __init__(self,led_queue):
        super().__init__()
        self.led_queue = led_queue
        self.running = True

    def run(self):
        while self.running:
            try:
                # todo 여기서 색 구분하는거 생각 다시 해야함
                command = self.led_queue.get(timeout=1)
                self.control_led(command)
            except queue.Empty:
                continue

            except Exception as e:
                print(f'LED 스레드에서 에러 발생 : {e}')

    # todo LED 컨트롤하는 로직 구성해야함
    def control_led(self,command):
        pass

    def stop(self):
        self.running = False



class ThreadManager:
    def __init__(self):
        # 큐 초기화부터
        self.sensor_queue = queue.Queue()
        self.mqtt_publish_queue = queue.Queue()
        self.led_queue = queue.Queue()

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
        self.mqtt_client = MQTTBuilder().\
            setEndpoint(self.END_POINT).\
            setPort().\
            setCertFilepath(self.CERT_FILE_PATH).\
            setCaFilepath(self.CA_FILE_PATH).\
            setPriKeyFilepath(self.PRI_KEY_FILE_PATH).\
            setClientId("JetsonNano").\
            setConnection(). \
            addTopic(['led_control',])

        # 스레드 초기화
        self.threads = {
            'sensor_camera': SensorCameraThread(
                self.sensor_queue,
                self.mqtt_publish_queue),
            'mqtt_publish': MqttPublishThread(
                self.mqtt_publish_queue,
                self.mqtt_client),
            'mqtt_subscribe' : MQTTSubscriberThread(
                self.mqtt_client,
                self.led_queue
            ),
            'led_control' : LEDControlThread(
                self.led_queue
            ),
        }

    # 전체 스레드 시작 메서드
    def start_threads(self):
        for thread_name,thread in self.threads.items():
            print(f'{thread_name} 스레드 실행')
            thread.start()

    # 전체 스레드 종료 메서드
    def stop_threads(self):
        for thread_name,thread in self.threads.items():
            print(f'{thread_name} 스레드 종료')
            thread.stop()
            thread.join()

def main():
    manager = ThreadManager()
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
