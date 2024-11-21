
from OCR import CameraOCRManager

# OCR 매니저 생성
ocr_manager = CameraOCRManager()

# OCR 실행 및 결과 출력
result = ocr_manager.capture_and_process()
print(f"OCR 결과: {result}")





# from model import ObjectDetector
#
# detector = ObjectDetector(show_detection=True)  # show_detection=True로 하면 detection 결과를 시각화
# result = detector.detect_once()
# print(f"Detection result: {result}")
















# import cv2
#
#
# def crop_image():
#     img = cv2.imread('img.jpg')
#
#     # 원본 좌표
#     x1, y1 = 552, 229
#     x2, y2 = 812, 292
#
#     # 가로/세로 길이 계산
#     width = x2 - x1
#     height = y2 - y1
#
#     # 50% 확장
#     x_extend = int(width * 0.5)
#     y_extend = int(height * 0.5)
#
#     # 새 좌표 계산
#     new_x1 = max(0, x1 - x_extend)
#     new_y1 = max(0, y1 - y_extend)
#     new_x2 = min(img.shape[1], x2 + x_extend)
#     new_y2 = min(img.shape[0], y2 + y_extend)
#
#     # 이미지 크롭
#     cropped_img = img[new_y1:new_y2, new_x1:new_x2]
#     cv2.imwrite('img_crop.jpg', cropped_img)
#
#
# if __name__ == "__main__":
#     crop_image()