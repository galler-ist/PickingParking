# -*- coding: utf-8 -*-
import board
import neopixel_spi as neopixel
import time

# LED ����
NUM_PIXELS = 12  # LED ���� LED ����
SPI_PORT = board.SPI()  # SPI ��Ʈ ����

# NeoPixel ��ü ����
pixels = neopixel.NeoPixel_SPI(
    SPI_PORT,
    NUM_PIXELS,
    brightness=0.1,  # ��� ���� (0.0 ~ 1.0)
    auto_write=False,
    pixel_order=neopixel.GRB
)

def wheel(pos):
    # 0���� 255 ������ ��ġ ���� �Է¹޾� ������ ��ȯ�ϴ� �Լ�
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
        rainbow_cycle(0.01)  # ���κ��� ȿ�� (���ڴ� ������ �ð�)

except KeyboardInterrupt:
    # ���α׷� ���� �� LED ����
    pixels.fill((0, 0, 0))
    pixels.show()