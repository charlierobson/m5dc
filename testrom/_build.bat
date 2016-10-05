del ram7800.bin
del rom.bin
brass %~dp0ram7800.asm %~dp0ram7800.bin -l %~dp0ram7800.html
brass %~dp0rom.asm     %~dp0rom.bin     -l %~dp0rom.html
