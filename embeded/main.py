from thread_manager import ThreadManager
import time
import os
from dotenv import load_dotenv


def setup_environment():
    """환경 변수 설정 및 검증"""
    load_dotenv()

    required_vars = [
        'END_POINT',
        'CERT_FILE_PATH',
        'CA_FILE_PATH',
        'PRI_KEY_FILE_PATH'
    ]

    # 환경 변수 존재 확인
    for var in required_vars:
        if not os.environ.get(var):
            raise EnvironmentError(f"Missing required environment variable: {var}")

    # 인증서 파일 존재 확인
    cert_files = [
        os.environ.get('CERT_FILE_PATH'),
        os.environ.get('CA_FILE_PATH'),
        os.environ.get('PRI_KEY_FILE_PATH')
    ]

    for file_path in cert_files:
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Certificate file not found: {file_path}")


def main():
    try:
        # 환경 설정
        print("Initializing system...")
        setup_environment()

        # 스레드 매니저 초기화
        print("Starting thread manager...")
        manager = ThreadManager()

        print("\n================= Starting All Threads =================")
        manager.start_threads()

        # 메인 스레드 유지 및 상태 모니터링
        while True:
            # 여기에 필요한 모니터링 로직 추가 가능
            time.sleep(1)

    except KeyboardInterrupt:
        print("\nShutdown signal received...")
    except Exception as e:
        print(f"\nCritical error occurred: {e}")
    finally:
        if 'manager' in locals():
            print("\nStopping all threads...")
            manager.stop_threads()
            print("================= All Threads Stopped =================\n")


if __name__ == "__main__":
    main()