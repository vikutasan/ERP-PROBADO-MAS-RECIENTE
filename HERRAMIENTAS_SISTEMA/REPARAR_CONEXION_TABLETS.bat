@echo off
:: Solicitar permisos de administrador automáticamente
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Solicitando permisos de administrador para corregir la red...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

echo =======================================================
echo   REPARANDO CONEXION DE LAS TABLETS DEL ERP
echo =======================================================
echo.
echo Tu computadora principal (Servidor) habia cambiado a la IP 192.168.1.13.
echo Estamos regresandola a la IP original 192.168.1.117 para que las 
echo tablets T2, T3, T4, T5, T6 y CAJA vuelvan a conectar inmediatamente.
echo.
echo Ejecutando correccion...
netsh interface ipv4 set address name="Ethernet" static 192.168.1.117 255.255.255.0 192.168.1.1
echo.
echo [EXITO] La conexion ha sido restaurada. 
echo.
echo Por favor revisa las tablets (y refresca la pagina si es necesario).
echo El ERP ya debe estar cargando.
echo.
pause
