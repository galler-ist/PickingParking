import cv2
import numpy as np
import os
import time
from threading import Lock


class LEDController:
    def __init__(self):
        self.images = {}
        self.width = 1920
        self.height = 1200
        self.current_color = None
        self.window_lock = Lock()
        self.window_name = 'LED_DISPLAY'

        os.environ['DISPLAY'] = ':0'

        try:
            cv2.setNumThreads(1)
            cv2.destroyAllWindows()
            time.sleep(0.5)

            # 화면 강제 on
            os.system('xset -display :0 dpms force on')
            os.system('xset s off -dpms')

            # 기존 창 처리
            os.system('wmctrl -c "LED_DISPLAY"')
            time.sleep(0.5)

            # 창 생성 및 설정
            cv2.namedWindow(self.window_name, cv2.WINDOW_NORMAL)
            cv2.setWindowProperty(self.window_name, cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
            cv2.moveWindow(self.window_name, 0, 0)

            init_image = np.zeros((self.height, self.width, 3), dtype=np.uint8)
            cv2.imshow(self.window_name, init_image)
            cv2.waitKey(1)

            os.system(f'wmctrl -r "{self.window_name}" -b add,above,sticky')
            os.system(f'wmctrl -r "{self.window_name}" -b add,fullscreen')

            print("디스플레이 초기화 완료")

        except Exception as e:
            print(f"디스플레이 초기화 실패: {e}")
            raise

    def create_color_images(self):
        colors = {
            'R': (0, 0, 255),  # BGR
            'G': (0, 255, 0),  # BGR
            'Y': (0, 255, 255),  # BGR
            'Black': (0, 0, 0)  # BGR
        }

        for color_name, bgr_value in colors.items():
            try:
                img = np.full((self.height, self.width, 3), bgr_value, dtype=np.uint8)
                self.images[color_name] = img.copy()
                print(f'{color_name} 색상 이미지 생성 완료')
            except Exception as e:
                print(f'{color_name} 색상 이미지 생성 실패: {e}')

    def set_color(self, color):
        if color not in self.images:
            print(f"잘못된 색상: {color}")
            return False

        try:
            with self.window_lock:
                cv2.destroyAllWindows()
                time.sleep(0.5)

                # 창 다시 생성
                cv2.namedWindow(self.window_name, cv2.WINDOW_NORMAL)
                cv2.setWindowProperty(self.window_name, cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
                cv2.moveWindow(self.window_name, 0, 0)

                # 이미지 표시
                cv2.imshow(self.window_name, self.images[color])
                cv2.waitKey(1)

                # 화면 강제 on 및 창 속성 설정
                os.system('xset -display :0 dpms force on')
                os.system(f'wmctrl -r "{self.window_name}" -b add,above,sticky')
                os.system(f'wmctrl -r "{self.window_name}" -b add,fullscreen')

                self.current_color = color
                return True

        except Exception as e:
            print(f"색상 변경 실패: {e}")
            return False

    def cleanup(self):
        with self.window_lock:
            try:
                if 'Black' in self.images:
                    cv2.imshow(self.window_name, self.images['Black'])
                    cv2.waitKey(1)
                cv2.destroyAllWindows()
                print("디스플레이 정리 완료")
            except Exception as e:
                print(f"정리 중 에러: {e}")