# MPLAB IDE generated this makefile for use with GNU make.
# Project: firmware-03.mcp
# Date: Mon Dec 09 16:27:03 2013

AS = xc32-as.exe
CC = xc32-gcc.exe
LD = xc32-ld.exe
AR = xc32-ar.exe
HX = xc32-bin2hex.exe
RM = rm

einsd03.hex : einsd03.elf
	$(HX) "einsd03.elf"

einsd03.elf : E:/intermediate/einsdein/pic32\ firmware/pp.o E:/intermediate/einsdein/pic32\ firmware/errmsgs.o E:/intermediate/einsdein/pic32\ firmware/serial.o E:/intermediate/einsdein/pic32\ firmware/diskio.o E:/intermediate/einsdein/pic32\ firmware/fatfs_mmc_spi.o E:/intermediate/einsdein/pic32\ firmware/ff.o E:/intermediate/einsdein/pic32\ firmware/main.o E:/intermediate/einsdein/pic32\ firmware/timer.o E:/intermediate/einsdein/pic32\ firmware/lenval.o E:/intermediate/einsdein/pic32\ firmware/ports.o E:/intermediate/einsdein/pic32\ firmware/micro.o E:/intermediate/einsdein/pic32\ firmware/dirproc.o E:/intermediate/einsdein/pic32\ firmware/dsk.o E:/intermediate/einsdein/pic32\ firmware/einstein.o E:/intermediate/einsdein/pic32\ firmware/escore.o
	$(CC) -mprocessor=32MX150F128D "E:\intermediate\einsdein\pic32 firmware\pp.o" "E:\intermediate\einsdein\pic32 firmware\errmsgs.o" "E:\intermediate\einsdein\pic32 firmware\serial.o" "E:\intermediate\einsdein\pic32 firmware\diskio.o" "E:\intermediate\einsdein\pic32 firmware\fatfs_mmc_spi.o" "E:\intermediate\einsdein\pic32 firmware\ff.o" "E:\intermediate\einsdein\pic32 firmware\main.o" "E:\intermediate\einsdein\pic32 firmware\timer.o" "E:\intermediate\einsdein\pic32 firmware\lenval.o" "E:\intermediate\einsdein\pic32 firmware\ports.o" "E:\intermediate\einsdein\pic32 firmware\micro.o" "E:\intermediate\einsdein\pic32 firmware\dirproc.o" "E:\intermediate\einsdein\pic32 firmware\dsk.o" "E:\intermediate\einsdein\pic32 firmware\einstein.o" "E:\intermediate\einsdein\pic32 firmware\escore.o" -o"einsd03.elf" -Wl,-L"E:\Microchip\mplabc32\v2.02\pic32mx\lib",--script="app_32MX150F128D.ld",--defsym=__MPLAB_BUILD=1,-Map="firmware-03.map",--cref,--warn-section-align

E:/intermediate/einsdein/pic32\ firmware/pp.o : pp.c ../compiler.h ../hardwareprofile.h pp.h
	$(CC) -mprocessor=32MX150F128D -x c -c "pp.c" -o"e:\intermediate\einsdein\pic32 firmware\pp.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\pp.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/errmsgs.o : errmsgs.c
	$(CC) -mprocessor=32MX150F128D -x c -c "errmsgs.c" -o"e:\intermediate\einsdein\pic32 firmware\errmsgs.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\errmsgs.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/serial.o : serial.c ../compiler.h serial.h
	$(CC) -mprocessor=32MX150F128D -x c -c "serial.c" -o"e:\intermediate\einsdein\pic32 firmware\serial.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\serial.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/diskio.o : diskio.c diskio.h serial.h
	$(CC) -mprocessor=32MX150F128D -x c -c "diskio.c" -o"e:\intermediate\einsdein\pic32 firmware\diskio.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\diskio.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/fatfs_mmc_spi.o : fatfs_mmc_spi.c ../HardwareProfile.h diskio.h ff.h ffconf.h timer.h serial.h
	$(CC) -mprocessor=32MX150F128D -x c -c "fatfs_mmc_spi.c" -o"e:\intermediate\einsdein\pic32 firmware\fatfs_mmc_spi.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\fatfs_mmc_spi.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/ff.o : ff.c ff.h ffconf.h diskio.h
	$(CC) -mprocessor=32MX150F128D -x c -c "ff.c" -o"e:\intermediate\einsdein\pic32 firmware\ff.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\ff.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/main.o : main.c ../compiler.h ../hardwareprofile.h ../config.h ff.h ffconf.h pp.h command.h ../commandIDs.h serial.h dsk.h diskio.h xilinx/micro.h
	$(CC) -mprocessor=32MX150F128D -x c -c "main.c" -o"e:\intermediate\einsdein\pic32 firmware\main.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\main.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/timer.o : timer.c ../hardwareprofile.h
	$(CC) -mprocessor=32MX150F128D -x c -c "timer.c" -o"e:\intermediate\einsdein\pic32 firmware\timer.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\timer.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/lenval.o : Xilinx/lenval.c Xilinx/lenval.h Xilinx/ports.h
	$(CC) -mprocessor=32MX150F128D -x c -c "Xilinx\lenval.c" -o"e:\intermediate\einsdein\pic32 firmware\lenval.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\lenval.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/ports.o : Xilinx/ports.c Xilinx/ports.h ../compiler.h ../hardwareprofile.h
	$(CC) -mprocessor=32MX150F128D -x c -c "Xilinx\ports.c" -o"e:\intermediate\einsdein\pic32 firmware\ports.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\ports.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/micro.o : xilinx/micro.c xilinx/micro.h xilinx/lenval.h xilinx/ports.h
	$(CC) -mprocessor=32MX150F128D -x c -c "xilinx\micro.c" -o"e:\intermediate\einsdein\pic32 firmware\micro.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\micro.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/dirproc.o : dirproc.c ff.h ffconf.h command.h ../commandIDs.h serial.h
	$(CC) -mprocessor=32MX150F128D -x c -c "dirproc.c" -o"e:\intermediate\einsdein\pic32 firmware\dirproc.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\dirproc.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/dsk.o : dsk.c dsk.h ff.h ffconf.h
	$(CC) -mprocessor=32MX150F128D -x c -c "dsk.c" -o"e:\intermediate\einsdein\pic32 firmware\dsk.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\dsk.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/einstein.o : einstein.c
	$(CC) -mprocessor=32MX150F128D -x c -c "einstein.c" -o"e:\intermediate\einsdein\pic32 firmware\einstein.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\einstein.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

E:/intermediate/einsdein/pic32\ firmware/escore.o : escore.c include/einSDein.h ../compiler.h ../hardwareprofile.h ff.h ffconf.h pp.h command.h ../commandIDs.h serial.h dsk.h ff.h diskio.h xilinx/micro.h
	$(CC) -mprocessor=32MX150F128D -x c -c "escore.c" -o"e:\intermediate\einsdein\pic32 firmware\escore.o" -MMD -MF"e:\intermediate\einsdein\pic32 firmware\escore.d" -I"." -I".." -g -DHARDWARE03 -DWANT_SERIAL -Os

clean : 
	$(RM) "E:\intermediate\einsdein\pic32 firmware\pp.o" "E:\intermediate\einsdein\pic32 firmware\errmsgs.o" "E:\intermediate\einsdein\pic32 firmware\serial.o" "E:\intermediate\einsdein\pic32 firmware\diskio.o" "E:\intermediate\einsdein\pic32 firmware\fatfs_mmc_spi.o" "E:\intermediate\einsdein\pic32 firmware\ff.o" "E:\intermediate\einsdein\pic32 firmware\main.o" "E:\intermediate\einsdein\pic32 firmware\timer.o" "E:\intermediate\einsdein\pic32 firmware\lenval.o" "E:\intermediate\einsdein\pic32 firmware\ports.o" "E:\intermediate\einsdein\pic32 firmware\micro.o" "E:\intermediate\einsdein\pic32 firmware\dirproc.o" "E:\intermediate\einsdein\pic32 firmware\dsk.o" "E:\intermediate\einsdein\pic32 firmware\einstein.o" "E:\intermediate\einsdein\pic32 firmware\escore.o" "einsd03.elf" "einsd03.hex"

