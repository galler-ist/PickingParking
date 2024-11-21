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

        # ���� ���� Ȯ���Ϸ��� ���� ������
        self.cnt = 0
        self.is_car_present = False # �̰ɷ� ���� �ڵ��� �ִ��� �Ǵ��Ұ���
        self.check_interval = 6

    def run(self):
        while self.running:
            try:
                # TODO : ���� �޼��� �̸� models.py���� ��ȣ���� ���� �̸��� ���� �ٲ����
                detected = self.detector.detect_once() # todo ���⼭ models.py �޼��� ó��
                # detected�� True/False
                print(f'��ȣ�� ���� ���� :  {detected}')
                # ���� ������ �ִ� ����

                if not self.is_car_present: # ������ ���� ��
                    if detected: # ������ ���� �� �˾Ҵµ� true�� ���� ��
                        self.cnt += 1
                        print(f'���� True ���� : {True} * {self.cnt}')
                        if self.cnt>=2:
                            print('���� ���� Ȯ�� -> ocr �ǽ�')
                            self.is_car_present = True
                            self.cnt = 0
                            self.start_ocr_sequence()
                            self.check_interval = 3 # �ٽ� 60�� �������� �ǽ��ϵ��� ����
                            # ���⼭ mqtt �������� ���
                        else: # ���� Ȯ���������� ���� �� üũ�ؾ��� ��
                            self.check_interval = 3
                    else: #�׳� ���ٰ� �����Ȱ���
                        self.cnt = 0
                        self.check_interval = 3
                else: # ������ �ִٰ� �ǴܵǾ� �ִ� ����
                    if not detected: #���� �ִٰ� �ǴܵǾ����µ�, false�� ���� ��
                        self.cnt +=1
                        print(f'���� False ����: {False}*{self.cnt}')

                        if self.cnt>=2: # �������� False 5�� ����
                            print('���� ���� Ȯ��')
                            self.is_car_present = False
                            self.cnt = 0
                            self.check_interval = 3
                            # TODO : MQTT ���� ��
                        else:
                            self.check_interval = 3
                    else:
                        self.cnt = 0
                        self.check_interval = 3
                print(f'{self.check_interval}�� ���')
                time.sleep(self.check_interval)
            except Exception as e:
                print(f'!!!!!!!���� �����忡�� ���� ��!!!!!!!!!!!')
                print(f"{e}")
                print("===========================================")


    def start_ocr_sequence(self):
        # while self.detected and self.ocr_cnt < self.max_ocr_cnt:
        try:
            # OCR ����
            # �ϴ� �з� ���º��� �ٽ� Ȯ��
            result = self.camera_ocr.capture_and_process()
            if result:
                self.mqtt_publish_queue.put({
                    'topic': 'OCR',
                    'message': {
                        'result':result}
                })

        except Exception as e:
            print(f'OCR ���� : {e}')

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
#         # ���� ���� Ȯ���Ϸ��� ���� ������
#         self.cnt = 0
#         self.is_car_present = False
#         self.check_interval = 6
#
#         # OpenCV ����
#         cv2.setNumThreads(1)  # OpenCV ������ �� ����
#
#     def run(self):
#         while self.running:
#             try:
#                 # ī�޶�/���� �۾� ���� â ó��
#                 cv2.destroyWindow("camera_window")  # ���� â�� �ִٸ� ����
#                 time.sleep(0.1)  # ��� ���
#
#                 detected = self.detector.detect_once()
#                 print(f'��ȣ�� ���� ���� : {detected}')
#
#                 if not self.is_car_present:
#                     if detected:
#                         self.cnt += 1
#                         print(f'���� True ���� : {True} * {self.cnt}')
#                         if self.cnt >= 2:
#                             print('���� ���� Ȯ�� -> ocr �ǽ�')
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
#                         print(f'���� False ����: {False}*{self.cnt}')
#
#                         if self.cnt >= 2:
#                             print('���� ���� Ȯ��')
#                             self.is_car_present = False
#                             self.cnt = 0
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#
#                 # ī�޶�/���� �۾� �� â ����
#                 cv2.destroyWindow("camera_window")
#                 time.sleep(0.1)  # ��� ���
#
#                 print(f'{self.check_interval}�� ���')
#                 time.sleep(self.check_interval)
#
#             except Exception as e:
#                 print(f'!!!!!!!���� �����忡�� ���� ��!!!!!!!!!!!')
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
#         self.pause_event = pause_event  # Event ��ü�� ������ ����
#
#         self.cnt = 0
#         self.is_car_present = False
#         self.check_interval = 6
#         cv2.setNumThreads(1)  # OpenCV ������ �� ����
#
#     def run(self):
#         while self.running:
#             # OCR �����尡 �Ͻ����� ���¶�� ���
#             self.pause_event.wait()
#
#             try:
#                 detected = self.detector.detect_once()
#                 print(f'��ȣ�� ���� ���� : {detected}')
#
#                 if not self.is_car_present:
#                     if detected:
#                         self.cnt += 1
#                         print(f'���� True ���� : {True} * {self.cnt}')
#                         if self.cnt >= 2:
#                             print('���� ���� Ȯ�� -> ocr �ǽ�')
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
#                         print(f'���� False ����: {False}*{self.cnt}')
#                         if self.cnt >= 2:
#                             print('���� ���� Ȯ��')
#                             self.is_car_present = False
#                             self.cnt = 0
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#
#                 print(f'{self.check_interval}�� ���')
#                 time.sleep(self.check_interval)
#             except Exception as e:
#                 print(f'!!!!!!!���� �����忡�� ���� ��!!!!!!!!!!!')
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
#             print(f'OCR ���� : {e}')
#
#     def stop(self):
#         self.running = False
#         self.is_car_present = False
#         self.cnt = 0
#         self.check_interval = 6


class MqttPublishThread(threading.Thread):  # ���忡�� �۽��Ұ� OCR �����ۿ� ����
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
                print(f'�ۺ��� ������ ���� : {e}')

    def stop(self):
        self.running = False


# class MQTTSubscriberThread(threading.Thread):
#     def __init__(self, mqtt_client, led_queue):
#         super().__init__()
#         self.mqtt_client = mqtt_client
#         self.led_queue = led_queue
#         self.running = True
#
#         # MQTT �ݹ� �Լ� ����
#         self.mqtt_client.set_message_callback(self.on_message_received)
#         print('MQTT �ݹ� �Լ� ���� �Ϸ�')
#
#
#     def run(self):
#         print("MQTT ���� ������ ����")
#         while self.running:
#             try:
#                 time.sleep(0.1)
#             except Exception as e:
#                 print(f'Sub ������ ���� �߻�: {e}')
#
#     def on_message_received(self, topic, payload, dup, qos, retain, **kwargs):
#         print()
#         print()
#         print()
#         print()
#         print()
#         print()
#         print(f'==================�ݹ��Լ�����================')
#         print()
#         print()
#         print()
#         print()
#         print()
#         print()
#         try:
#             print(f"�޽��� ����: topic={topic}, payload={payload}")
#             if topic == 'led_control':
#                 message_str = payload.decode('utf-8').strip()
#                 message_json = json.loads(message_str)
#                 color = message_json.get('color', '').upper()
#                 print(f'!!!!!!!!!!!!!color : {color}!!!!!!!!!!!!!!!!!')
#
#                 if color in colors:
#                     print(f'LED ť�� ���� �߰�: {color}')
#                     self.led_queue.put(color)
#                 else:
#                     print(f'�߸��� LED ���: {color}')
#         except json.JSONDecodeError as e:
#             print(f'JSON ���ڵ� ����: {e}')
#         except Exception as e:
#             print(f'�޽��� ó�� ����: {e}')
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
        # ? todo �� �κ� �� �ذ�. �޼��� ���ú� �޴°Ŷ�, return �� �ǹ��� ����
    def run(self):
        while self.running:
            try:
                time.sleep(0.1)
            except Exception as e:
                print(f'Sub ������ ���� �߻� : {e}')

    def on_message_received(self, topic, payload,**kwargs):
        if topic == 'led_control': # �ϴ� �ӽ� ����
            message = json.loads(payload)
            self.led_queue.put(message)
            print(f"LED �޼��� ����: {message}")

    def stop(self):
        self.running = False


# class MQTTSubscriberThread(threading.Thread):
#     def __init__(self, mqtt_client, led_queue):
#         super().__init__()
#         self.mqtt_client = mqtt_client
#         self.led_queue = led_queue
#         self.running = True
#         self.mqtt_client._onMessageReceived = self.on_message_received
#         # ? todo �� �κ� �� �ذ�. �޼��� ���ú� �޴°Ŷ�, return �� �ǹ��� ����
#         # self.mqtt_client._on_message = self.on_message_received
#
#     def run(self):
#         while self.running:
#             try:
#                 time.sleep(0.1)
#                 self.mqtt_client.client.loop(timeout=1.0)
#                 time.sleep(0.1)
#             except Exception as e:
#                 print(f'Sub ������ ���� �߻� : {e}')
#
#     def on_message_received(self, topic, payload, **kwargs):
#         try:
#             if topic == 'led_control':
#                 # �޽����� JSON ������ ���
#                 message_str = payload.decode('utf-8').strip()
#                 message_json = json.loads(message_str)
#                 color = message_json.get('color', '').upper()
#                 if color in colors:
#                     self.led_queue.put(color)
#                     print(f'LED ��� ���� : {color}')
#                 else:
#                     print(f'�߸��� LED ��� : {color}')
#         except json.JSONDecodeError:
#             print('JSON ���ڵ� ����')
#         except Exception as e:
#             print(f'��� ���� ���� : {e}')
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
#         print("LED ���� ������ ����")
#         time.sleep(1)  # �ʱ�ȭ�� ���� ���
#
#         while self.running:
#             try:
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED ���� ������: ���� ���� ��� ���� - {command}')
#
#                 if command in colors:
#                     for attempt in range(3):  # �ִ� 3�� �õ�
#                         print(f'LED ���� ������: {command} ���� ���� �õ� {attempt + 1}')
#
#                         # �ٸ� â�� ����
#                         cv2.destroyWindow("camera_window")
#                         time.sleep(0.2)
#
#                         success = self.led_controller.set_color(command)
#
#                         if success:
#                             print(f'LED ���� ������: {command} ���� ���� ����')
#                             break
#                         else:
#                             print(f'LED ���� ������: {command} ���� ���� ����, ��õ� �غ�')
#                             time.sleep(0.5)
#                 else:
#                     print(f'LED ���� ������: �߸��� ���� ��� - {command}')
#
#             except queue.Empty:
#                 pass
#             except Exception as e:
#                 print(f'LED ���� ������ ����: {e}')
# class LEDControlThread(threading.Thread):
#     def __init__(self, led_queue, led_controller, pause_event):
#         super().__init__()
#         self.led_queue = led_queue
#         self.led_controller = led_controller
#         self.pause_event = pause_event  # Event ��ü�� ������ ����
#         self.running = True
#
#     def run(self):
#         print("LED ���� ������ ����")
#         while self.running:
#             try:
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED ���� ������: ���� ���� ��� ���� - {command}')
#
#                 if command in colors:
#                     # OCR ������ �Ͻ�����
#                     self.pause_event.clear()
#                     for attempt in range(3):
#                         print(f'LED ���� ������: {command} ���� ���� �õ� {attempt + 1}')
#                         success = self.led_controller.set_color(command)
#                         if success:
#                             print(f'LED ���� ������: {command} ���� ���� ����')
#                             break
#                         else:
#                             print(f'LED ���� ������: {command} ���� ���� ����, ��õ� �غ�')
#                             time.sleep(0.5)
#                     # ���� ���� �Ϸ� �� OCR ������ �簳
#                     self.pause_event.set()
#                 else:
#                     print(f'LED ���� ������: �߸��� ���� ��� - {command}')
#             except queue.Empty:
#                 continue
#             except Exception as e:
#                 print(f'LED ���� ������ ����: {e}')
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
#         print("LED ���� ������ ����")
#         while self.running:
#             try:
#                 # ť���� �޽��� ��������
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED ���� ���� �õ�: {command}')
#
#                 if command in colors:
#                     print(f'LED ���� ���� ����: {command}')
#                     self.led_controller.set_color(command)
#                 else:
#                     print(f'�߸��� ���� ���: {command}')
#
#             except queue.Empty:
#                 pass
#             except Exception as e:
#                 print(f'LED ���� ����: {e}')
#
#     def stop(self):
#         print("LED ���� ������ ����")
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
#                # ���� �޼��� ��������
#                command = self.led_queue.get(timeout=1)
#                if command in colors:
#                    print(f'LED ���� ���� ��� ���� : {command}')
#                    self.led_controller.set_color(command)
#                else:
#                    print(f'����� �� ���� ���� ��� : {command}')
#
#             except queue.Empty:
#                 # print('���� queue�� �������')
#                 pass
#             except Exception as e:
#                 print(f'LED �����忡�� ���� �߻� : {e}')
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
    #     print("LED ��Ʈ�ѷ� �ʱ�ȭ ����")
    #     if os.geteuid() != 0:
    #         print("�����ӹ��� ������ ���� root ������ �ʿ��մϴ�")
    #         raise PermissionError("root ���� �ʿ�")
    #
    #     self.led_controller = LEDController()
    #     print("���� �̹��� ���� ����")
    #     self.led_controller.create_color_images()
    #     self.led_controller.set_color('Black')


class ThreadManager:
    def __init__(self):
        # ť �ʱ�ȭ����
        self.sensor_queue = queue.Queue()
        self.mqtt_publish_queue = queue.Queue()
        self.led_queue = queue.Queue()

        # self.led_controller = LEDController()
        # self.led_controller.create_color_images()
        # print("!!!!!!!!!!!!�� ���� �Ϸ�!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        # self.led_controller.set_color('Black')  # �ʱ� ȭ���� ���������� ����
        # print('!!!!!!!!!!!!!�ʱ�ȭ�� ���� �Ϸ�!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        load_dotenv()
        self.END_POINT = os.environ.get('END_POINT')
        self.CERT_FILE_PATH = os.environ.get('CERT_FILE_PATH')
        self.CA_FILE_PATH = os.environ.get('CA_FILE_PATH')
        self.PRI_KEY_FILE_PATH = os.environ.get('PRI_KEY_FILE_PATH')

        print("CertPath:{}".format(self.CERT_FILE_PATH))
        print(f'CA PATH : {self.CA_FILE_PATH}')
        print(f'PRI_KEY : {self.PRI_KEY_FILE_PATH}')

        # Ŭ���̾�Ʈ �ʱ�ȭ
        # ���⼭ addTopic �ؾ��ϳ�? -> ��
        self.mqtt_client = MQTTBuilder(). \
            setEndpoint(self.END_POINT). \
            setPort(). \
            setCertFilepath(self.CERT_FILE_PATH). \
            setCaFilepath(self.CA_FILE_PATH). \
            setPriKeyFilepath(self.PRI_KEY_FILE_PATH). \
            setClientId("JetsonNano"). \
            setConnection(). \
            addTopic(['led_control', ])

        # ������ �ʱ�ȭ
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

    # �����尡 ������ ���� ����ؼ� ������ ���ÿ� ������ ó��
    def monitor_threads(self):
        while True:
            for thread_name, thread in self.threads.items():
                if not thread.is_alive():
                    logger.warning(f"{thread_name} �ٽ� ����")
                    new_thread = type(thread)(*thread.__init__args)
                    new_thread.start()
                    self.threads[thread_name] = new_thread
            time.sleep(10)  # 10�ʸ��� üũ

    # ��ü ������ ���� �޼���
    def start_threads(self):
        for thread_name, thread in self.threads.items():
            print(f'{thread_name} ������ ����')
            thread.start()
        threading.Thread(target=self.monitor_threads, daemon=True).start()

    # ��ü ������ ���� �޼���
    def stop_threads(self):
        for thread_name, thread in self.threads.items():
            print(f'{thread_name} ������ ����')
            thread.stop()
            thread.join()


def main():
    manager = ThreadManager()
    pause_event = threading.Event()
    pause_event.set()  # �ʱ� ���¿��� OCR ������ Ȱ��ȭ
    try:
        print()
        print('=================��ü ������ ����=============')
        manager.start_threads()
        # ���� ������ ������
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print('������ ���� ��')
        manager.stop_threads()
        print('=================��ü ������ ����=================')
        print()
    except Exception as e:
        print(f'������ �Ŵ��� ���� : {e}')


if __name__ == '__main__':
    main()
