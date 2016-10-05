call :doBuild ram7800
call :doBuild ramE000
call :doBuild rom
exit /b

:doBuild
del %1.bin
brass %~dp0%1.asm %~dp0%1.bin -l %~dp0%1.html
