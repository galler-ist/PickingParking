# -*- coding: utf-8 -*-
# LED.py
import cv2
import numpy as np
from PIL import Image
import os
import time
from threading import Lock


class LEDController:
    def __init__(self,img_dir='./colors'):
        self.images = {}
        self.img_dir = img_dir
        self.width = 1920
        self.height = 1200
        self.current_color = None
        self.window_lock = Lock()
        os.environ['DISPLAY'] = ':0'

        time.sleep(2)

        # cv2.namedWindow('LED', cv2.WINDOW_NORMAL)
        # cv2.moveWindow('LED', 0, 0)
        # cv2.resizeWindow('LED', self.width, self.height)
        #
        # cv2.setWindowProperty('LED', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)


        try:
            # 전체 화면 윈도우 설정
            cv2.namedWindow('LED', cv2.WND_PROP_FULLSCREEN)
            cv2.setWindowProperty('LED', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
            print("Display window initialized")
        except Exception as e:
            print(f"Failed to initialize display: {e}")
            # X11 권한 문제 가능성 안내
            print("Check if X11 permissions are properly set")

        # self.create_color_images()

    def create_color_images(self):
        colors = {
            'R': (0, 0, 255),  # Red (BGR)
            'G': (0, 255, 0),  # Green (BGR)
            'Y': (0, 255, 255),  # Yellow (BGR)
            'Black': (255, 255, 255)
        }

        for color_name, bgr_value in colors.items():
            img = np.full((self.height, self.width, 3), bgr_value, dtype=np.uint8)
            self.images[color_name] = img
            print('Color {} image created ({}x{})'.format(color_name, self.width, self.height))
        # print(f'~~~~~~~~~~~~~{self.images}~~~~~~~~~~~~~~~~~~~~~~~~~')

    # def set_color(self, color):
    #     if color in self.images:
    #         print(f'색상 변경 시작!!!!!!!!!!!!!{color}')
    #         try:
    #             cv2.imshow('LED', self.images[color])
    #             cv2.setWindowProperty('LED', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
    #             cv2.waitKey(1)
    #             print('Color {} displayed ({}x{})'.format(color, self.width, self.height))
    #         except Exception as e:
    #             print('Failed to display color: {}'.format(e))
    #     else:
    #         print(f'없는 색깔이야!!!!!!!!!!!!!!!{color}')


    def set_color(self, color):
        """색상 변경"""
        if color not in self.images:
            print(f"Invalid color: {color}")
            return False

        with self.window_lock:
            try:
                # 현재 색상과 같으면 스킵
                if self.current_color == color:
                    return True

                # 이미지 표시
                cv2.imshow('LED', self.images[color])
                cv2.waitKey(1)  # 필수: 화면 업데이트를 위해

                self.current_color = color
                print(f"Display changed to {color}")
                return True

            except Exception as e:
                print(f"Failed to set color {color}: {e}")
                return False

    def cleanup(self):
        """정리"""
        with self.window_lock:
            try:
                cv2.destroyAllWindows()
                print("Display cleanup completed")
            except Exception as e:
                print(f"Cleanup error: {e}")
    # def set_color(self, color):
    #     if color in self.images:
    #         try:
    #             # 기존 창 제거
    #             cv2.destroyWindow('LED')
    #             time.sleep(0.1)  # 창이 완전히 닫힐 때까지 대기
    #
    #             # 새 창 생성 및 설정
    #             cv2.imshow('LED', self.images[color])
    #             cv2.namedWindow('LED', cv2.WINDOW_NORMAL)
    #             cv2.setWindowProperty('LED', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
    #             cv2.moveWindow('LED', 0, 0)  # 항상 최상단에 위치
    #             cv2.waitKey(1)
    #             print('Color {} displayed ({}x{})'.format(color, self.width, self.height))
    #             # 이미지 표시
    #             print(f'색상 {color} 표시됨')
    #         except Exception as e:
    #             print(f'색상 표시 실패: {e}')

    #
    # def cleanup(self):
    #     cv2.destroyAllWindows()
# import cv2
# import numpy as np
# from PIL import Image
# import os
#
#
# class LEDController:
#     def __init__(self, img_dir='./colors'):
#         self.img_dir = img_dir
#         self.images = {}
#
#         # 창 생성 및 전체 화면 설정
#         cv2.namedWindow('LED', cv2.WINDOW_NORMAL)
#         cv2.moveWindow('LED', 0, 0)  # 창을 화면 좌상단에 위치
#         cv2.setWindowProperty('LED', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
#
#         # 화면 해상도 설정
#         self.width = 1920
#         self.height = 1200
#
#         # 단색 이미지 생성
#         self.create_color_images()
#
#     def create_color_images(self):
#         # BGR 형식으로 색상 정의
#         colors = {
#             'R': (0, 0, 255),    # 빨간색 (BGR)
#             'G': (0, 255, 0),    # 초록색 (BGR)
#             'Y': (0, 255, 255),   # 노란색 (BGR)
#             'Black' : (255, 255, 255)
#         }
#
#         for color_name, bgr_value in colors.items():
#             # 전체 화면 크기의 단색 이미지 생성
#             img = np.full((self.height, self.width, 3), bgr_value, dtype=np.uint8)
#             self.images[color_name] = img
#             print(f'색상 {color_name} 이미지 생성됨')
#
#     def set_color(self, color):
#         if color in self.images:
#             try:
#                 # 이미지 표시
#                 cv2.imshow('LED', self.images[color])
#                 cv2.waitKey(1)  # waitKey는 imshow 후에 호출
#                 cv2.setWindowProperty('LED', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)  # 전체화면 속성 다시 설정
#                 print(f'색상 {color} 표시됨')
#             except Exception as e:
#                 print(f'색상 표시 실패: {e}')
#
#     def cleanup(self):
#         cv2.destroyAllWindows()
# -----------x서버 끄는 방법으로 가능하긴 함-0---------------------------------
# # LED.py
# import numpy as np
# from PIL import Image
# import os
# import fcntl
# import mmap
# import struct
#
#
# class LEDController:
#     def __init__(self, img_dir='./colors'):
#         try:
#             # 프레임버퍼 디바이스 열기
#             self.fb = open('/dev/fb0', 'rb+')
#             self.fb_info = self._get_fb_info()
#             self.screen_width = self.fb_info['width']
#             self.screen_height = self.fb_info['height']
#             self.fb_size = self.screen_width * self.screen_height * self.fb_info['bpp'] // 8
#             self.fb_map = mmap.mmap(self.fb.fileno(), self.fb_size, mmap.MAP_SHARED)
#
#             self.img_dir = img_dir
#             self.images = {}
#             self.load_images()
#             print("프레임버퍼 초기화 완료")
#
#         except Exception as e:
#             print(f"프레임버퍼 초기화 실패: {e}")
#             raise
#
#     def _get_fb_info(self):
#         FBIOGET_VSCREENINFO = 0x4600
#         fmt = 'IIIIIIIIIHHHHHHIIIIIIHHHHHHHHH'
#
#         try:
#             buffer = ' ' * struct.calcsize(fmt)
#             fb_info = fcntl.ioctl(self.fb.fileno(), FBIOGET_VSCREENINFO, buffer)
#             fb_var = struct.unpack(fmt, fb_info)
#
#             return {
#                 'width': fb_var[0],
#                 'height': fb_var[1],
#                 'bpp': fb_var[6]
#             }
#         except Exception as e:
#             print(f"프레임버퍼 정보 가져오기 실패: {e}")
#             raise
#
#     def load_images(self):
#         for color in ["R", "G", "Y"]:
#             image_path = os.path.join(self.img_dir, f'{color}.png')
#             if os.path.exists(image_path):
#                 try:
#                     img = Image.open(image_path)
#                     img = img.resize((self.screen_width, self.screen_height))
#                     img = img.convert('RGB')
#                     self.images[color] = np.array(img)
#                     print(f'이미지 {color}.png 성공적으로 로드됨')
#                 except Exception as e:
#                     print(f'이미지 {image_path}을(를) 로드하는 중 오류 발생: {e}')
#             else:
#                 print(f'이미지 {image_path}이(가) 존재하지 않습니다.')
#
#     def set_color(self, color):
#         if color in self.images:
#             try:
#                 img_array = self.images[color]
#
#                 print(f"이미지 배열 형태: {img_array.shape}")
#                 print(f"프레임버퍼 크기: {self.fb_size}")
#                 print(f"스크린 해상도: {self.screen_width}x{self.screen_height}")
#                 print(f"비트 깊이: 32")
#
#                 # BGRA 포맷으로 변환 (Jetson의 프레임버퍼는 BGRA를 사용)
#                 fb_array = np.zeros((self.screen_height * self.screen_width * 4), dtype=np.uint8)
#
#                 for y in range(self.screen_height):
#                     for x in range(self.screen_width):
#                         pixel_index = (y * self.screen_width + x) * 4
#                         fb_array[pixel_index + 0] = img_array[y, x, 2]  # Blue
#                         fb_array[pixel_index + 1] = img_array[y, x, 1]  # Green
#                         fb_array[pixel_index + 2] = img_array[y, x, 0]  # Red
#                         fb_array[pixel_index + 3] = 255  # Alpha
#
#                 # 프레임버퍼에 직접 쓰기
#                 self.fb_map.seek(0)
#                 self.fb_map.write(fb_array.tobytes())
#                 self.fb_map.flush()
#
#                 # 강제로 화면 업데이트
#                 os.system('sync')
#
#                 print(f'이미지 {color}.png 표시됨')
#
#             except Exception as e:
#                 print(f'이미지 표시 실패: {e}')
#                 import traceback
#                 traceback.print_exc()
#
#     def cleanup(self):
#         try:
#             if hasattr(self, 'fb_map'):
#                 self.fb_map.close()
#             if hasattr(self, 'fb'):
#                 self.fb.close()
#             print("프레임버퍼 정리 완료")
#         except Exception as e:
#             print(f"프레임버퍼 정리 실패: {e}")

# # -*- coding: utf-8 -*-
# # LED.py
# import numpy as np
# from PIL import Image
# import os
# import fcntl
# import mmap
# import struct
#
#
# class LEDController:
#     def __init__(self, img_dir='./colors'):
#         try:
#             # 프레임버퍼 디바이스 열기
#             self.fb = open('/dev/fb0', 'rb+')
#             self.fb_info = self._get_fb_info()
#             self.screen_width = self.fb_info['width']
#             self.screen_height = self.fb_info['height']
#             self.fb_size = self.screen_width * self.screen_height * self.fb_info['bpp'] // 8
#             self.fb_map = mmap.mmap(self.fb.fileno(), self.fb_size, mmap.MAP_SHARED)
#
#             self.img_dir = img_dir
#             self.images = {}
#             self.load_images()
#             print("프레임버퍼 초기화 완료")
#
#         except Exception as e:
#             print(f"프레임버퍼 초기화 실패: {e}")
#             raise
#
#     # def _get_fb_info(self):
#     #     # 프레임버퍼 정보 구조체
#     #     FBIOGET_VSCREENINFO = 0x4600
#     #     fmt = 'IIIIHH'
#     #
#     #     try:
#     #         fb_info = fcntl.ioctl(self.fb.fileno(), FBIOGET_VSCREENINFO, struct.pack(fmt, 0, 0, 0, 0, 0, 0))
#     #         width, height, bpp = struct.unpack(fmt, fb_info)[:3]
#     #         print(f"프레임버퍼 정보: {width}x{height}, {bpp}bpp")
#     #         return {'width': width, 'height': height, 'bpp': bpp}
#     #     except Exception as e:
#     #         print(f"프레임버퍼 정보 가져오기 실패: {e}")
#     #         raise
#
#     def _get_fb_info(self):
#         FBIOGET_VSCREENINFO = 0x4600
#         fmt = 'IIIIIIIIIHHHHHHIIIIIIHHHHHHHHH'
#
#         try:
#             buffer = ' ' * struct.calcsize(fmt)
#             fb_info = fcntl.ioctl(self.fb.fileno(), FBIOGET_VSCREENINFO, buffer)
#             fb_var = struct.unpack(fmt, fb_info)
#
#             return {
#                 'width': fb_var[0],
#                 'height': fb_var[1],
#                 'bpp': fb_var[6]
#             }
#         except Exception as e:
#             print(f"프레임버퍼 정보 가져오기 실패: {e}")
#             raise
#
#     def load_images(self):
#         for color in ["R", "G", "Y"]:
#             image_path = os.path.join(self.img_dir, f'{color}.png')
#             if os.path.exists(image_path):
#                 try:
#                     img = Image.open(image_path)
#                     img = img.resize((self.screen_width, self.screen_height))
#                     img = img.convert('RGB')
#                     self.images[color] = np.array(img)
#                     print(f'이미지 {color}.png 성공적으로 로드됨')
#                 except Exception as e:
#                     print(f'이미지 {image_path}을(를) 로드하는 중 오류 발생: {e}')
#             else:
#                 print(f'이미지 {image_path}이(가) 존재하지 않습니다.')
#
#     # -*- coding: utf-8 -*-
#     # LED.py
#     import numpy as np
#     from PIL import Image
#     import os
#     import fcntl
#     import mmap
#     import struct
#
#     class LEDController:
#         def __init__(self, img_dir='./colors'):
#             try:
#                 # 프레임버퍼 디바이스 열기
#                 self.fb = open('/dev/fb0', 'rb+')
#                 self.fb_info = self._get_fb_info()
#                 self.screen_width = self.fb_info['width']
#                 self.screen_height = self.fb_info['height']
#                 self.fb_size = self.screen_width * self.screen_height * self.fb_info['bpp'] // 8
#                 self.fb_map = mmap.mmap(self.fb.fileno(), self.fb_size, mmap.MAP_SHARED)
#
#                 self.img_dir = img_dir
#                 self.images = {}
#                 self.load_images()
#                 print("프레임버퍼 초기화 완료")
#
#             except Exception as e:
#                 print(f"프레임버퍼 초기화 실패: {e}")
#                 raise
#
#         # def _get_fb_info(self):
#         #     # 프레임버퍼 정보 구조체
#         #     FBIOGET_VSCREENINFO = 0x4600
#         #     fmt = 'IIIIHH'
#         #
#         #     try:
#         #         fb_info = fcntl.ioctl(self.fb.fileno(), FBIOGET_VSCREENINFO, struct.pack(fmt, 0, 0, 0, 0, 0, 0))
#         #         width, height, bpp = struct.unpack(fmt, fb_info)[:3]
#         #         print(f"프레임버퍼 정보: {width}x{height}, {bpp}bpp")
#         #         return {'width': width, 'height': height, 'bpp': bpp}
#         #     except Exception as e:
#         #         print(f"프레임버퍼 정보 가져오기 실패: {e}")
#         #         raise
#
#         def _get_fb_info(self):
#             FBIOGET_VSCREENINFO = 0x4600
#             fmt = 'IIIIIIIIIHHHHHHIIIIIIHHHHHHHHH'
#
#             try:
#                 buffer = ' ' * struct.calcsize(fmt)
#                 fb_info = fcntl.ioctl(self.fb.fileno(), FBIOGET_VSCREENINFO, buffer)
#                 fb_var = struct.unpack(fmt, fb_info)
#
#                 return {
#                     'width': fb_var[0],
#                     'height': fb_var[1],
#                     'bpp': fb_var[6]
#                 }
#             except Exception as e:
#                 print(f"프레임버퍼 정보 가져오기 실패: {e}")
#                 raise
#
#         def load_images(self):
#             for color in ["R", "G", "Y"]:
#                 image_path = os.path.join(self.img_dir, f'{color}.png')
#                 if os.path.exists(image_path):
#                     try:
#                         img = Image.open(image_path)
#                         img = img.resize((self.screen_width, self.screen_height))
#                         img = img.convert('RGB')
#                         self.images[color] = np.array(img)
#                         print(f'이미지 {color}.png 성공적으로 로드됨')
#                     except Exception as e:
#                         print(f'이미지 {image_path}을(를) 로드하는 중 오류 발생: {e}')
#                 else:
#                     print(f'이미지 {image_path}이(가) 존재하지 않습니다.')
#
#         def set_color(self, color):
#             if color in self.images:
#                 try:
#                     img_array = self.images[color]
#
#                     # 디버깅 정보 출력
#                     print(f"이미지 배열 형태: {img_array.shape}")
#                     print(f"프레임버퍼 크기: {self.fb_size}")
#                     print(f"스크린 해상도: {self.screen_width}x{self.screen_height}")
#                     print(f"비트 깊이: 32")
#                     print(f"Stride: 7680")
#
#                     # 32비트 ARGB 포맷으로 변환 (stride 고려)
#                     fb_array = np.zeros((self.screen_height, 7680 // 4), dtype=np.uint32)
#
#                     # RGB 이미지를 32비트 ARGB 형식으로 변환
#                     for y in range(self.screen_height):
#                         for x in range(self.screen_width):
#                             # 알파(255), 빨강, 초록, 파랑 순서
#                             fb_array[y, x] = (
#                                     0xFF000000 |  # 알파 채널 (255)
#                                     (img_array[y, x, 0] << 16) |  # 빨강
#                                     (img_array[y, x, 1] << 8) |  # 초록
#                                     img_array[y, x, 2]  # 파랑
#                             )
#
#                     # 프레임버퍼에 직접 쓰기
#                     self.fb_map.seek(0)
#                     self.fb_map.write(fb_array.tobytes())
#                     self.fb_map.flush()
#
#                     print(f'이미지 {color}.png 표시됨')
#
#                     # 이미지 저장으로 내용 확인
#                     Image.fromarray(img_array).save(f'/tmp/{color}_debug.png')
#
#                 except Exception as e:
#                     print(f'이미지 표시 실패: {e}')
#                     import traceback
#                     traceback.print_exc()
#
#         def cleanup(self):
#             try:
#                 if hasattr(self, 'fb_map'):
#                     self.fb_map.close()
#                 if hasattr(self, 'fb'):
#                     self.fb.close()
#                 print("프레임버퍼 정리 완료")
#             except Exception as e:
#                 print(f"프레임버퍼 정리 실패: {e}")
#
#     def cleanup(self):
#         try:
#             if hasattr(self, 'fb_map'):
#                 self.fb_map.close()
#             if hasattr(self, 'fb'):
#                 self.fb.close()
#             print("프레임버퍼 정리 완료")
#         except Exception as e:
#             print(f"프레임버퍼 정리 실패: {e}")
#
# # class LEDController:
# #     def __init__(self, img_dir='./colors'):
# #         self.fb = open('/dev/fb0', 'rb+')
# #         self.fb_info = self._get_fb_info()
# #         self.screen_width = self.fb_info['width']
# #         self.screen_height = self.fb_info['height']
# #         self.fb_size = self.screen_width * self.screen_height * self.fb_info['bpp'] // 8
# #         self.fb_map = mmap.mmap(self.fb.fileno(), self.fb_size, mmap.MAP_SHARED)
# #
# #         self.img_dir = img_dir
# #         self.images = {}
# #         self.load_images()
# #
# #     def _get_fb_info(self):
# #         # 프레임버퍼 정보 구조체
# #         FBIOGET_VSCREENINFO = 0x4600
# #         fmt = 'IIIIHH'  # width, height, bpp 정보를 담는 구조체 형식
# #
# #         # ioctl을 통해 프레임버퍼 정보 가져오기
# #         fb_info = fcntl.ioctl(self.fb.fileno(), FBIOGET_VSCREENINFO, struct.pack(fmt, 0, 0, 0, 0, 0, 0))
# #         width, height, bpp = struct.unpack(fmt, fb_info)[:3]
# #
# #         return {'width': width, 'height': height, 'bpp': bpp}
# #
# #     def load_images(self):
# #         for color in ["R", "G", "Y"]:
# #             image_path = os.path.join(self.img_dir, f'{color}.png')
# #             if os.path.exists(image_path):
# #                 try:
# #                     img = Image.open(image_path)
# #                     img = img.resize((self.screen_width, self.screen_height))
# #                     img = img.convert('RGB')
# #                     self.images[color] = np.array(img)
# #                 except Exception as e:
# #                     print(f'이미지 {image_path}을(를) 로드하는 중 오류 발생: {e}')
# #
# #     def set_color(self, color):
# #         if color in self.images:
# #             try:
# #                 img_array = self.images[color]
# #                 # RGB888 형식으로 변환
# #                 fb_array = np.zeros((self.screen_height, self.screen_width * 4), dtype=np.uint8)
# #                 fb_array[:, 0::4] = img_array[:, :, 2]  # Blue
# #                 fb_array[:, 1::4] = img_array[:, :, 1]  # Green
# #                 fb_array[:, 2::4] = img_array[:, :, 0]  # Red
# #
# #                 # 프레임버퍼에 직접 쓰기
# #                 self.fb_map.seek(0)
# #                 self.fb_map.write(fb_array.tobytes())
# #                 print(f'이미지 {color}.png 표시됨')
# #             except Exception as e:
# #                 print(f'이미지 표시 중 오류 발생: {e}')
# #         else:
# #             print(f'알 수 없는 색상: {color}')
# #
# #     def cleanup(self):
# #         self.fb_map.close()
# #         self.fb.close()
#
#
# # import pygame
# # import os
# # # LED.py
# # class LEDController:
# #     def __init__(self,img_dir = './colors'):
# #         pygame.init()
# #         self.screen_info = pygame.display.Info()
# #         self.screen_width, self.screen_height = self.screen_info.current_w, self.screen_info.current_h
# #         self.screen = pygame.display.set_mode((self.screen_info.current_w, self.screen_info.current_h)\
# #                                               ,pygame.FULLSCREEN)
# #         pygame.display.set_caption('LED Display')
# #         self.img_dir = img_dir
# #         self.images = {}
# #         self.load_images()
# #         self.current_image = None
# #
# #     def load_images(self):
# #         for color in ["R","G","Y"]:
# #             image_path = os.path.join(self.img_dir, f'{color}.png')
# #         if os.path.exists(image_path):
# #             try:
# #                 img  = pygame.image.load(image_path)
# #                 img = pygame.transform.scale(img,(self.screen_width,self.screen_height))
# #                 self.images[color] = img
# #             except pygame.error as e:
# #                 print(f'이미지 {image_path}을(를) 로드하는 중 오류 발생: {e}')
# #
# #     def set_color(self,color):
# #         if color in self.images:
# #             self.current_image = self.images[color]
# #             self.screen.blit(self.current_image,(0,0))
# #             pygame.display.flip()
# #             print(f'이미지 {color}.png 표시됨')
# #         else:
# #             print(f'알 수 없는 색상 : {color}')
# #
# #     def cleanup(self):
# #         pygame.quit()
# #
#
#
# # import board
# # import neopixel_spi as neopixel
# # import time
# # import traceback
# #
# # class LEDController:
# #     def __init__(self):
# #         self.NUM_PIXELS = 12
# #         try:
# #             print('LED 초기화 시작')
# #             self.spi = board.SPI()
# #             self.pixels = neopixel.NeoPixel_SPI(
# #                 self.spi,
# #                 self.NUM_PIXELS,
# #                 brightness=0.5,
# #                 auto_write=False,
# #                 pixel_order=neopixel.GRB
# #             )
# #             print('LED 초기화 완료')
# #             self.turn_off()
# #
# #         except Exception as e:
# #             print(f'LED 초기화 에러 : {e}')
# #             print(traceback.format_exc())
# #             raise
# #
# #     def set_color(self, command):
# #         try:
# #             colors = {
# #                 'R': (0, 255, 0),  # GRB 순서
# #                 'G': (255, 0, 0),  # GRB 순서
# #                 'Y': (255, 255, 0)  # GRB 순서
# #             }
# #
# #             if command not in colors:
# #                 print(f'{command}는 지정된 색이 아님')
# #                 return
# #
# #             self.pixels.fill(colors[command])
# #             self.pixels.show()
# #             print(f'LED {command}색으로 변경')
# #
# #         except Exception as e:
# #             print(f'LED 색상 변경 에러: {e}')
# #             print(traceback.format_exc())
# #
# #     def turn_off(self):
# #         try:
# #             self.pixels.fill((0, 0, 0))
# #             self.pixels.show()
# #         except Exception as e:
# #             print(f'LED 끄기 에러: {e}')
# #             print(traceback.format_exc())
# #
# #     def cleanup(self):
# #         self.turn_off()
# #
# # if __name__ == "__main__":
# #     led = None
# #     try:
# #         led = LEDController()
# #         led.set_color('R')
# #         time.sleep(60)
# #     except Exception as e:
# #         print(f'메인 프로그램 에러: {e}')
# #         print(traceback.format_exc())
# #     finally:
# #         if led:
# #             led.cleanup()
#
# # import board
# # import neopixel_spi as neopixel
# # import time
# #
# # class LEDController:
# #     def __init__(self):
# #         self.NUM_PIXELS = 12
# #         try:
# #             print('spi 초기화 시작')
# #             self.spi = board.SPI()
# #             print('spi 초기화 완료')
# #             self.spi.max_speed_hz = 2400000  # WS2812B 권장 속도
# #             self.pixels = neopixel.NeoPixel_SPI(
# #                 self.spi,
# #                 self.NUM_PIXELS,
# #                 brightness=0.5,
# #                 auto_write=True,  # 자동 업데이트 활성화
# #                 pixel_order=neopixel.GRB
# #             )
# #             self.turn_off()
# #         except Exception as e:
# #             print(f'LED 초기화 에러: {e}')
# #             raise
# #
# #     def set_color(self, command):
# #         try:
# #             if command == 'R':
# #                 color = (0, 255, 0)  # GRB 순서: 빨간색 (0,255,0)
# #             elif command == 'G':
# #                 color = (255, 0, 0)  # GRB 순서: 초록색 (255,0,0)
# #             elif command == 'Y':
# #                 color = (255, 255, 0)  # GRB 순서: 노란색 (255,255,0)
# #             else:
# #                 print(f'{command}는 지정된 색이 아님')
# #                 return
# #
# #             self.pixels.fill(color)
# #             print(f'LED {color}색으로 변경')
# #
# #         except Exception as e:
# #             print(f'LED 색상 변경 에러: {e}')
# #
# #     def turn_off(self):
# #         try:
# #             self.pixels.fill((0, 0, 0))
# #         except Exception as e:
# #             print(f'LED 끄기 에러: {e}')
# #
# #     def cleanup(self):
# #         try:
# #             self.turn_off()
# #             self.spi.deinit()  # SPI 연결 종료
# #         except Exception as e:
# #             print(f'정리 중 에러: {e}')
# #
# # if __name__ == "__main__":
# #     led = None
# #     try:
# #         led = LEDController()
# #         led.set_color('R')
# #         time.sleep(60)
# #     except Exception as e:
# #         print(f'메인 프로그램 에러: {e}')
# #     finally:
# #         if led:
# #             led.cleanup()