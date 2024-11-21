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

        # ¿¬¼Ó °¨Áö È®ÀÎÇÏ·Á°í º¯¼ö ¸¸µé¾îµÒ
        self.cnt = 0
        self.is_car_present = False # ÀÌ°É·Î ÇöÀç ÀÚµ¿Â÷ ÀÖ´ÂÁö ÆÇ´ÜÇÒ°ÅÀÓ
        self.check_interval = 6

    def run(self):
        while self.running:
            try:
                # TODO : ¿©±â ¸Þ¼­µå ÀÌ¸§ models.py¿¡¼­ ¿ìÈ£ÇüÀÌ ¸¸µç ÀÌ¸§¿¡ µû¶ó ¹Ù²ã¾ßÇÔ
                detected = self.detector.detect_once() # todo ¿©±â¼­ models.py ¸Þ¼­µå Ã³¸®
                # detected´Â True/False
                print(f'¹øÈ£ÆÇ °¨Áö »óÅÂ :  {detected}')
                # ÇöÀç Â÷·®ÀÌ ÀÖ´Â »óÅÂ

                if not self.is_car_present: # Â÷·®ÀÌ ¾øÀ» ¶§
                    if detected: # Â÷·®ÀÌ ¾ø´Â ÁÙ ¾Ë¾Ò´Âµ¥ true°¡ ¶¹À» ¶§
                        self.cnt += 1
                        print(f'¿¬¼Ó True °¨Áö : {True} * {self.cnt}')
                        if self.cnt>=2:
                            print('Â÷·® Á¸Àç È®Á¤ -> ocr ½Ç½Ã')
                            self.is_car_present = True
                            self.cnt = 0
                            self.start_ocr_sequence()
                            self.check_interval = 3 # ´Ù½Ã 60ÃÊ °£°ÝÀ¸·Î ½Ç½ÃÇÏµµ·Ï º¯°æ
                            # ¿©±â¼­ mqtt º¸³¾°ÇÁö °í¹Î
                        else: # ¾ÆÁ÷ È®Á¤ÁöÀ¸·Á¸é Á¶±Ý ´õ Ã¼Å©ÇØ¾ßÇÒ ¶§
                            self.check_interval = 3
                    else: #±×³É ¾ø´Ù°í °¨ÁöµÈ°ÅÀÓ
                        self.cnt = 0
                        self.check_interval = 3
                else: # Â÷·®ÀÌ ÀÖ´Ù°í ÆÇ´ÜµÇ¾î ÀÖ´Â »óÅÂ
                    if not detected: #Â÷°¡ ÀÖ´Ù°í ÆÇ´ÜµÇ¾ú¾ú´Âµ¥, false°¡ ¶¹À» ¶§
                        self.cnt +=1
                        print(f'¿¬¼Ó False °¨Áö: {False}*{self.cnt}')

                        if self.cnt>=2: # ¿¬¼ÓÀ¸·Î False 5¹ø °¨Áö
                            print('Â÷·® ¾øÀ½ È®Á¤')
                            self.is_car_present = False
                            self.cnt = 0
                            self.check_interval = 3
                            # TODO : MQTT º¸³¾ Áö
                        else:
                            self.check_interval = 3
                    else:
                        self.cnt = 0
                        self.check_interval = 3
                print(f'{self.check_interval}ÃÊ ´ë±â')
                time.sleep(self.check_interval)
            except Exception as e:
                print(f'!!!!!!!°¨Áö ½º·¹µå¿¡¼­ ¿¡·¯ ³²!!!!!!!!!!!')
                print(f"{e}")
                print("===========================================")


    def start_ocr_sequence(self):
        # while self.detected and self.ocr_cnt < self.max_ocr_cnt:
        try:
            # OCR ¼öÇà
            # ÀÏ´Ü ¾Ð·Â »óÅÂºÎÅÍ ´Ù½Ã È®ÀÎ
            result = self.camera_ocr.capture_and_process()
            if result:
                self.mqtt_publish_queue.put({
                    'topic': 'OCR',
                    'message': {
                        'result':result}
                })

        except Exception as e:
            print(f'OCR ¿¡·¯ : {e}')

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
#         # ¿¬¼Ó °¨Áö È®ÀÎÇÏ·Á°í º¯¼ö ¸¸µé¾îµÒ
#         self.cnt = 0
#         self.is_car_present = False
#         self.check_interval = 6
#
#         # OpenCV ¼³Á¤
#         cv2.setNumThreads(1)  # OpenCV ½º·¹µå ¼ö Á¦ÇÑ
#
#     def run(self):
#         while self.running:
#             try:
#                 # Ä«¸Þ¶ó/°¨Áö ÀÛ¾÷ Àü¿¡ Ã¢ Ã³¸®
#                 cv2.destroyWindow("camera_window")  # ÀÌÀü Ã¢ÀÌ ÀÖ´Ù¸é Á¦°Å
#                 time.sleep(0.1)  # Àá½Ã ´ë±â
#
#                 detected = self.detector.detect_once()
#                 print(f'¹øÈ£ÆÇ °¨Áö »óÅÂ : {detected}')
#
#                 if not self.is_car_present:
#                     if detected:
#                         self.cnt += 1
#                         print(f'¿¬¼Ó True °¨Áö : {True} * {self.cnt}')
#                         if self.cnt >= 2:
#                             print('Â÷·® Á¸Àç È®Á¤ -> ocr ½Ç½Ã')
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
#                         print(f'¿¬¼Ó False °¨Áö: {False}*{self.cnt}')
#
#                         if self.cnt >= 2:
#                             print('Â÷·® ¾øÀ½ È®Á¤')
#                             self.is_car_present = False
#                             self.cnt = 0
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#
#                 # Ä«¸Þ¶ó/°¨Áö ÀÛ¾÷ ÈÄ Ã¢ Á¤¸®
#                 cv2.destroyWindow("camera_window")
#                 time.sleep(0.1)  # Àá½Ã ´ë±â
#
#                 print(f'{self.check_interval}ÃÊ ´ë±â')
#                 time.sleep(self.check_interval)
#
#             except Exception as e:
#                 print(f'!!!!!!!°¨Áö ½º·¹µå¿¡¼­ ¿¡·¯ ³²!!!!!!!!!!!')
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
#         self.pause_event = pause_event  # Event °´Ã¼·Î ½º·¹µå Á¦¾î
#
#         self.cnt = 0
#         self.is_car_present = False
#         self.check_interval = 6
#         cv2.setNumThreads(1)  # OpenCV ½º·¹µå ¼ö Á¦ÇÑ
#
#     def run(self):
#         while self.running:
#             # OCR ½º·¹µå°¡ ÀÏ½ÃÁ¤Áö »óÅÂ¶ó¸é ´ë±â
#             self.pause_event.wait()
#
#             try:
#                 detected = self.detector.detect_once()
#                 print(f'¹øÈ£ÆÇ °¨Áö »óÅÂ : {detected}')
#
#                 if not self.is_car_present:
#                     if detected:
#                         self.cnt += 1
#                         print(f'¿¬¼Ó True °¨Áö : {True} * {self.cnt}')
#                         if self.cnt >= 2:
#                             print('Â÷·® Á¸Àç È®Á¤ -> ocr ½Ç½Ã')
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
#                         print(f'¿¬¼Ó False °¨Áö: {False}*{self.cnt}')
#                         if self.cnt >= 2:
#                             print('Â÷·® ¾øÀ½ È®Á¤')
#                             self.is_car_present = False
#                             self.cnt = 0
#                             self.check_interval = 6
#                         else:
#                             self.check_interval = 3
#                     else:
#                         self.cnt = 0
#                         self.check_interval = 6
#
#                 print(f'{self.check_interval}ÃÊ ´ë±â')
#                 time.sleep(self.check_interval)
#             except Exception as e:
#                 print(f'!!!!!!!°¨Áö ½º·¹µå¿¡¼­ ¿¡·¯ ³²!!!!!!!!!!!')
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
#             print(f'OCR ¿¡·¯ : {e}')
#
#     def stop(self):
#         self.running = False
#         self.is_car_present = False
#         self.cnt = 0
#         self.check_interval = 6


class MqttPublishThread(threading.Thread):  # º¸µå¿¡¼­ ¼Û½ÅÇÒ°Ç OCR Á¤º¸¹Û¿¡ ¾øÀ½
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
                print(f'ÆÛºí¸®½Ã ½º·¹µå ¿¡·¯ : {e}')

    def stop(self):
        self.running = False


# class MQTTSubscriberThread(threading.Thread):
#     def __init__(self, mqtt_client, led_queue):
#         super().__init__()
#         self.mqtt_client = mqtt_client
#         self.led_queue = led_queue
#         self.running = True
#
#         # MQTT ÄÝ¹é ÇÔ¼ö ¼³Á¤
#         self.mqtt_client.set_message_callback(self.on_message_received)
#         print('MQTT ÄÝ¹é ÇÔ¼ö ¼³Á¤ ¿Ï·á')
#
#
#     def run(self):
#         print("MQTT ±¸µ¶ ½º·¹µå ½ÃÀÛ")
#         while self.running:
#             try:
#                 time.sleep(0.1)
#             except Exception as e:
#                 print(f'Sub ½º·¹µå ¹®Á¦ ¹ß»ý: {e}')
#
#     def on_message_received(self, topic, payload, dup, qos, retain, **kwargs):
#         print()
#         print()
#         print()
#         print()
#         print()
#         print()
#         print(f'==================ÄÝ¹éÇÔ¼ö½ÇÇà================')
#         print()
#         print()
#         print()
#         print()
#         print()
#         print()
#         try:
#             print(f"¸Þ½ÃÁö ¼ö½Å: topic={topic}, payload={payload}")
#             if topic == 'led_control':
#                 message_str = payload.decode('utf-8').strip()
#                 message_json = json.loads(message_str)
#                 color = message_json.get('color', '').upper()
#                 print(f'!!!!!!!!!!!!!color : {color}!!!!!!!!!!!!!!!!!')
#
#                 if color in colors:
#                     print(f'LED Å¥¿¡ »ö»ó Ãß°¡: {color}')
#                     self.led_queue.put(color)
#                 else:
#                     print(f'Àß¸øµÈ LED ¸í·É: {color}')
#         except json.JSONDecodeError as e:
#             print(f'JSON µðÄÚµå ¿¡·¯: {e}')
#         except Exception as e:
#             print(f'¸Þ½ÃÁö Ã³¸® ¿¡·¯: {e}')
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
        # ? todo ÀÌ ºÎºÐ Á» ÇØ°á. ¸Þ¼¼Áö ¸®½Ãºê ¹Þ´Â°Å¶û, return µî ÀÇ¹®Á¡ ¸¹À½
    def run(self):
        while self.running:
            try:
                time.sleep(0.1)
            except Exception as e:
                print(f'Sub ½º·¹µå ¹®Á¦ ¹ß»ý : {e}')

    def on_message_received(self, topic, payload,**kwargs):
        if topic == 'led_control': # ÀÏ´Ü ÀÓ½Ã ÅäÇÈ
            message = json.loads(payload)
            self.led_queue.put(message)
            print(f"LED ¸Þ¼¼Áö ¹ÞÀ½: {message}")

    def stop(self):
        self.running = False


# class MQTTSubscriberThread(threading.Thread):
#     def __init__(self, mqtt_client, led_queue):
#         super().__init__()
#         self.mqtt_client = mqtt_client
#         self.led_queue = led_queue
#         self.running = True
#         self.mqtt_client._onMessageReceived = self.on_message_received
#         # ? todo ÀÌ ºÎºÐ Á» ÇØ°á. ¸Þ¼¼Áö ¸®½Ãºê ¹Þ´Â°Å¶û, return µî ÀÇ¹®Á¡ ¸¹À½
#         # self.mqtt_client._on_message = self.on_message_received
#
#     def run(self):
#         while self.running:
#             try:
#                 time.sleep(0.1)
#                 self.mqtt_client.client.loop(timeout=1.0)
#                 time.sleep(0.1)
#             except Exception as e:
#                 print(f'Sub ½º·¹µå ¹®Á¦ ¹ß»ý : {e}')
#
#     def on_message_received(self, topic, payload, **kwargs):
#         try:
#             if topic == 'led_control':
#                 # ¸Þ½ÃÁö°¡ JSON Çü½ÄÀÏ °æ¿ì
#                 message_str = payload.decode('utf-8').strip()
#                 message_json = json.loads(message_str)
#                 color = message_json.get('color', '').upper()
#                 if color in colors:
#                     self.led_queue.put(color)
#                     print(f'LED ¸í·É ¼ö½Å : {color}')
#                 else:
#                     print(f'Àß¸øµÈ LED ¸í·É : {color}')
#         except json.JSONDecodeError:
#             print('JSON µðÄÚµå ¿¡·¯')
#         except Exception as e:
#             print(f'¸í·É ¼ö½Å ¿¡·¯ : {e}')
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
#         print("LED Á¦¾î ½º·¹µå ½ÃÀÛ")
#         time.sleep(1)  # ÃÊ±âÈ­¸¦ À§ÇÑ ´ë±â
#
#         while self.running:
#             try:
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED Á¦¾î ½º·¹µå: »ö»ó º¯°æ ¸í·É ¼ö½Å - {command}')
#
#                 if command in colors:
#                     for attempt in range(3):  # ÃÖ´ë 3¹ø ½Ãµµ
#                         print(f'LED Á¦¾î ½º·¹µå: {command} »ö»ó º¯°æ ½Ãµµ {attempt + 1}')
#
#                         # ´Ù¸¥ Ã¢µé Á¤¸®
#                         cv2.destroyWindow("camera_window")
#                         time.sleep(0.2)
#
#                         success = self.led_controller.set_color(command)
#
#                         if success:
#                             print(f'LED Á¦¾î ½º·¹µå: {command} »ö»ó º¯°æ ¼º°ø')
#                             break
#                         else:
#                             print(f'LED Á¦¾î ½º·¹µå: {command} »ö»ó º¯°æ ½ÇÆÐ, Àç½Ãµµ ÁØºñ')
#                             time.sleep(0.5)
#                 else:
#                     print(f'LED Á¦¾î ½º·¹µå: Àß¸øµÈ »ö»ó ¸í·É - {command}')
#
#             except queue.Empty:
#                 pass
#             except Exception as e:
#                 print(f'LED Á¦¾î ½º·¹µå ¿¡·¯: {e}')
# class LEDControlThread(threading.Thread):
#     def __init__(self, led_queue, led_controller, pause_event):
#         super().__init__()
#         self.led_queue = led_queue
#         self.led_controller = led_controller
#         self.pause_event = pause_event  # Event °´Ã¼·Î ½º·¹µå Á¦¾î
#         self.running = True
#
#     def run(self):
#         print("LED Á¦¾î ½º·¹µå ½ÃÀÛ")
#         while self.running:
#             try:
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED Á¦¾î ½º·¹µå: »ö»ó º¯°æ ¸í·É ¼ö½Å - {command}')
#
#                 if command in colors:
#                     # OCR ½º·¹µå ÀÏ½ÃÁ¤Áö
#                     self.pause_event.clear()
#                     for attempt in range(3):
#                         print(f'LED Á¦¾î ½º·¹µå: {command} »ö»ó º¯°æ ½Ãµµ {attempt + 1}')
#                         success = self.led_controller.set_color(command)
#                         if success:
#                             print(f'LED Á¦¾î ½º·¹µå: {command} »ö»ó º¯°æ ¼º°ø')
#                             break
#                         else:
#                             print(f'LED Á¦¾î ½º·¹µå: {command} »ö»ó º¯°æ ½ÇÆÐ, Àç½Ãµµ ÁØºñ')
#                             time.sleep(0.5)
#                     # »ö»ó º¯°æ ¿Ï·á ÈÄ OCR ½º·¹µå Àç°³
#                     self.pause_event.set()
#                 else:
#                     print(f'LED Á¦¾î ½º·¹µå: Àß¸øµÈ »ö»ó ¸í·É - {command}')
#             except queue.Empty:
#                 continue
#             except Exception as e:
#                 print(f'LED Á¦¾î ½º·¹µå ¿¡·¯: {e}')
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
#         print("LED Á¦¾î ½º·¹µå ½ÃÀÛ")
#         while self.running:
#             try:
#                 # Å¥¿¡¼­ ¸Þ½ÃÁö °¡Á®¿À±â
#                 command = self.led_queue.get(timeout=1)
#                 print(f'LED »ö»ó º¯°æ ½Ãµµ: {command}')
#
#                 if command in colors:
#                     print(f'LED »ö»ó º¯°æ ½ÇÇà: {command}')
#                     self.led_controller.set_color(command)
#                 else:
#                     print(f'Àß¸øµÈ »ö»ó ¸í·É: {command}')
#
#             except queue.Empty:
#                 pass
#             except Exception as e:
#                 print(f'LED Á¦¾î ¿¡·¯: {e}')
#
#     def stop(self):
#         print("LED Á¦¾î ½º·¹µå Á¾·á")
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
#                # Äí¿¡¼­ ¸Þ¼¼Áö °¡Á®¿À±â
#                command = self.led_queue.get(timeout=1)
#                if command in colors:
#                    print(f'LED »ö»ó º¯°æ ¸í·É ¼ö½Å : {command}')
#                    self.led_controller.set_color(command)
#                else:
#                    print(f'»ç¿ëÇÒ ¼ö ¾ø´Â »ö»ó ¸í·É : {command}')
#
#             except queue.Empty:
#                 # print('¾ÆÁ÷ queue°¡ ºñ¾îÀÖÀ½')
#                 pass
#             except Exception as e:
#                 print(f'LED ½º·¹µå¿¡¼­ ¿¡·¯ ¹ß»ý : {e}')
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
    #     print("LED ÄÁÆ®·Ñ·¯ ÃÊ±âÈ­ ½ÃÀÛ")
    #     if os.geteuid() != 0:
    #         print("ÇÁ·¹ÀÓ¹öÆÛ Á¢±ÙÀ» À§ÇØ root ±ÇÇÑÀÌ ÇÊ¿äÇÕ´Ï´Ù")
    #         raise PermissionError("root ±ÇÇÑ ÇÊ¿ä")
    #
    #     self.led_controller = LEDController()
    #     print("»ö»ó ÀÌ¹ÌÁö »ý¼º ½ÃÀÛ")
    #     self.led_controller.create_color_images()
    #     self.led_controller.set_color('Black')


class ThreadManager:
    def __init__(self):
        # Å¥ ÃÊ±âÈ­ºÎÅÍ
        self.sensor_queue = queue.Queue()
        self.mqtt_publish_queue = queue.Queue()
        self.led_queue = queue.Queue()

        # self.led_controller = LEDController()
        # self.led_controller.create_color_images()
        # print("!!!!!!!!!!!!»ö ¼³Á¤ ¿Ï·á!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        # self.led_controller.set_color('Black')  # ÃÊ±â È­¸éÀ» °ËÀº»öÀ¸·Î ¼³Á¤
        # print('!!!!!!!!!!!!!ÃÊ±âÈ­¸é ¼³Á¤ ¿Ï·á!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        load_dotenv()
        self.END_POINT = os.environ.get('END_POINT')
        self.CERT_FILE_PATH = os.environ.get('CERT_FILE_PATH')
        self.CA_FILE_PATH = os.environ.get('CA_FILE_PATH')
        self.PRI_KEY_FILE_PATH = os.environ.get('PRI_KEY_FILE_PATH')

        print("CertPath:{}".format(self.CERT_FILE_PATH))
        print(f'CA PATH : {self.CA_FILE_PATH}')
        print(f'PRI_KEY : {self.PRI_KEY_FILE_PATH}')

        # Å¬¶óÀÌ¾ðÆ® ÃÊ±âÈ­
        # ¿©±â¼­ addTopic ÇØ¾ßÇÏ³ª? -> ¯˜
        self.mqtt_client = MQTTBuilder(). \
            setEndpoint(self.END_POINT). \
            setPort(). \
            setCertFilepath(self.CERT_FILE_PATH). \
            setCaFilepath(self.CA_FILE_PATH). \
            setPriKeyFilepath(self.PRI_KEY_FILE_PATH). \
            setClientId("JetsonNano"). \
            setConnection(). \
            addTopic(['led_control', ])

        # ½º·¹µå ÃÊ±âÈ­
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

    # ½º·¹µå°¡ ²÷°åÀ» °ÍÀ» ´ëºñÇØ¼­ ½º·¹µå °¨½Ã¿ë ½º·¹µå Ã³¸®
    def monitor_threads(self):
        while True:
            for thread_name, thread in self.threads.items():
                if not thread.is_alive():
                    logger.warning(f"{thread_name} ´Ù½Ã ½ÃÀÛ")
                    new_thread = type(thread)(*thread.__init__args)
                    new_thread.start()
                    self.threads[thread_name] = new_thread
            time.sleep(10)  # 10ÃÊ¸¶´Ù Ã¼Å©

    # ÀüÃ¼ ½º·¹µå ½ÃÀÛ ¸Þ¼­µå
    def start_threads(self):
        for thread_name, thread in self.threads.items():
            print(f'{thread_name} ½º·¹µå ½ÇÇà')
            thread.start()
        threading.Thread(target=self.monitor_threads, daemon=True).start()

    # ÀüÃ¼ ½º·¹µå Á¾·á ¸Þ¼­µå
    def stop_threads(self):
        for thread_name, thread in self.threads.items():
            print(f'{thread_name} ½º·¹µå Á¾·á')
            thread.stop()
            thread.join()


def main():
    manager = ThreadManager()
    pause_event = threading.Event()
    pause_event.set()  # ÃÊ±â »óÅÂ¿¡¼­ OCR ½º·¹µå È°¼ºÈ­
    try:
        print()
        print('=================ÀüÃ¼ ½º·¹µå ½ÃÀÛ=============')
        manager.start_threads()
        # ¸ÞÀÎ ½º·¹µå À¯Áö¿ë
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print('½º·¹µå Á¾·á Áß')
        manager.stop_threads()
        print('=================ÀüÃ¼ ½º·¹µå Á¾·á=================')
        print()
    except Exception as e:
        print(f'½º·¹µå ¸Å´ÏÀú ¿À·ù : {e}')


if __name__ == '__main__':
    main()
