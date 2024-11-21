# -*- coding: utf-8 -*-
import board
import neopixel_spi as neopixel
import time

# LED 설정
NUM_PIXELS = 12  # LED 링의 LED 개수
SPI_PORT = board.SPI()  # SPI 포트 설정

# NeoPixel 객체 생성
pixels = neopixel.NeoPixel_SPI(
    SPI_PORT,
    NUM_PIXELS,
    brightness=0.1,  # 밝기 설정 (0.0 ~ 1.0)
    auto_write=False,
    pixel_order=neopixel.GRB
)

def wheel(pos):
    # 0에서 255 사이의 위치 값을 입력받아 색상을 반환하는 함수
    if pos < 0 or pos > 255:
        return (0, 0, 0)
    if pos < 85:
        return (255 - pos * 3, pos * 3, 0)
    if pos < 170:
        pos -= 85
        return (0, 255 - pos * 3, pos * 3)
    pos -= 170
    return (pos * 3, 0, 255 - pos * 3)

def rainbow_cycle(wait):
    for j in range(255):
        for i in range(NUM_PIXELS):
            rc_index = (i * 256 // NUM_PIXELS) + j
            pixels[i] = wheel(rc_index & 255)
        pixels.show()
        time.sleep(wait)

try:
    while True:
        print("Rainbow cycle")
        rainbow_cycle(0.01)  # 레인보우 효과 (숫자는 딜레이 시간)

except KeyboardInterrupt:
    # 프로그램 종료 시 LED 끄기
    pixels.fill((0, 0, 0))
    pixels.show()