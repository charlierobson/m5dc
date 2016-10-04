SETLOCAL

SET GCBIN="C:\Program Files (x86)\Microchip\xc32\v1.21\bin"
SET COMPILER=%GCBIN%\xc32-gcc.exe -mprocessor=32MX150F128D 
SET BIN2HEX=%GCBIN%\xc32-bin2hex.exe
SET IMED=%temp%\intermediate\einsdein\pic32 firmware
SET DEFINES=-DHARDWARE03 -DWANT_SERIAL -Wall -Os
SET BASE=%~dp0einsd03
SET ELF=%BASE%.elf
SET HEX=%BASE%.hex
SET MAP=%BASE%.map

mkdir "%IMED%" 2>NUL

if exist "%HEX%" (
del "%HEX%"
)


%COMPILER% -x c -c "pp.c" -o"%IMED%\pp.o" -MMD -MF"%IMED%\pp.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "errmsgs.c" -o"%IMED%\errmsgs.o" -MMD -MF"%IMED%\errmsgs.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "serial.c" -o"%IMED%\serial.o" -MMD -MF"%IMED%\serial.d" -I"." -I".."  -g %DEFINES%
rem %COMPILER% -x c -c "diskio.c" -o"%IMED%\diskio.o" -MMD -MF"%IMED%\diskio.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "fatfs_mmc_spi.c" -o"%IMED%\fatfs_mmc_spi.o" -MMD -MF"%IMED%\fatfs_mmc_spi.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "ff.c" -o"%IMED%\ff.o" -MMD -MF"%IMED%\ff.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "main.c" -o"%IMED%\main.o" -MMD -MF"%IMED%\main.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "timer.c" -o"%IMED%\timer.o" -MMD -MF"%IMED%\timer.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "Xilinx\lenval.c" -o"%IMED%\lenval.o" -MMD -MF"%IMED%\lenval.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "Xilinx\ports.c" -o"%IMED%\ports.o" -MMD -MF"%IMED%\ports.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "xilinx\micro.c" -o"%IMED%\micro.o" -MMD -MF"%IMED%\micro.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "dirproc.c" -o"%IMED%\dirproc.o" -MMD -MF"%IMED%\dirproc.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "dsk.c" -o"%IMED%\dsk.o" -MMD -MF"%IMED%\dsk.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "einstein.c" -o"%IMED%\einstein.o" -MMD -MF"%IMED%\einstein.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "escore.c" -o"%IMED%\escore.o" -MMD -MF"%IMED%\escore.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "configfile.c" -o"%IMED%\configfile.o" -MMD -MF"%IMED%\configfile.d" -I"." -I".."  -g %DEFINES%
%COMPILER% -x c -c "mrblobby.c" -o"%IMED%\mrblobby.o" -MMD -MF"%IMED%\mrblobby.d" -I"." -I".."  -g %DEFINES%

%COMPILER% "%IMED%\pp.o" "%IMED%\errmsgs.o" "%IMED%\serial.o" "%IMED%\fatfs_mmc_spi.o" "%IMED%\ff.o" "%IMED%\main.o" "%IMED%\timer.o" "%IMED%\lenval.o" "%IMED%\ports.o" "%IMED%\micro.o" "%IMED%\dirproc.o" "%IMED%\mrblobby.o" "%IMED%\dsk.o" "%IMED%\einstein.o" "%IMED%\escore.o" "%IMED%\configfile.o" -o"%ELF%" -Wl,--script="app_32MX150F128D.ld",--defsym=__MPLAB_BUILD=1,-Map="%MAP%",--cref,--warn-section-align

%BIN2HEX% %ELF%

del %ELF%
