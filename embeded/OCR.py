
import cv2
import os
from google.cloud import vision

class CameraOCRManager:
    def __init__(self):
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = './certs/OCR_api_key.json'
        self.client = vision.ImageAnnotatorClient()

        # ==================test용 임시 코드==========================
        self.test_image_path = './test_pic/4.jpg'
        # ============================================================
        
        
    def capture_and_process(self):
        try:


            # =====================================================
            '''
            cap = cv2.VideoCapture(0)
            ret, frame = cap.read()
            cap.release()
            '''
            # 테스트 이미지 읽기 코드 추가
            frame = cv2.imread(self.test_image_path)
            if frame is None:
                raise Exception("테스트 이미지 로드 실패")
            ret = True  # 이미지 로드 성공 시
            #===================================

            if not ret:
                raise Exception("카메라 캡처 실패")
            else:
                cv2.imshow('Camera', frame)
                print('캡쳐 완료')
                cv2.waitKey(3000)

            # OCR
            success, encoded_image = cv2.imencode('.jpg', frame)
            content = encoded_image.tobytes()

            cv2.destroyAllWindows()
            
            image = vision.Image(content=content)
            image_context = vision.ImageContext(
                language_hints=['ko']
            )
            response = self.client.text_detection(image=image, image_context=image_context)
            
            if not response.text_annotations:
                print('OCR 실패')
                return ""
            else:
                result = response.text_annotations[0].description
                print(result)
                return result
            
        except Exception as e:
            print(f"카메라/OCR 에러: {e}")
            return ""