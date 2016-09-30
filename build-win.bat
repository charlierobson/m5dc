@echo off
call "C:\Program Files\Mono\bin\setmonopath.bat"

echo Making cart tool
cd %~dp0\tools
call mcs mkcart.cs

echo Assembling test rom
cd %~dp0\testrom
brass.exe M5_test.asm

echo Make dummy menu
cd %~dp0\menu
copy /y ..\build-win.bat menu.bin

echo Building cart image
cd %~dp0\cart-binaries
%~dp0\tools\mkcart list.txt %~dp0\big.bin
sort %~dp0\big.txt > big.sma
echo Edit big.sma and save as big.asm or press return if already done...
pause

echo Assembling menu
cd %~dp0\menu
brass.exe M5Menu.asm -l m5menu.html

echo Re-building cart image to include updated menu
cd %~dp0\cart-binaries
%~dp0\tools\mkcart list.txt %~dp0\big.bin

cd %~dp0
dir big.bin
type cart-binaries\big.asm

pause
