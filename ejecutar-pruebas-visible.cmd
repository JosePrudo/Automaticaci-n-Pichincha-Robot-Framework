@echo off
REM Ejecuta las pruebas con el navegador VISIBLE y en camara lenta para ver el paso a paso.
REM Doble clic sobre este archivo o ejecutarlo desde la terminal.

cd /d "%~dp0"
set "PLAYWRIGHT_BROWSERS_PATH=%LOCALAPPDATA%\ms-playwright"
set "NODE_OPTIONS=--use-system-ca"

REM CAMARA_LENTA = pausa entre cada accion (formato H:MM:SS). Sube el valor para ir mas lento.
".venv\Scripts\python.exe" -m robot --outputdir results --name "Simulacion Credito Hipotecario" --variable HEADLESS:False --variable CAMARA_LENTA:0:00:01 tests

echo.
echo ============================================================
echo  Reporte: %~dp0results\report.html
echo  Log con evidencias: %~dp0results\log.html
echo ============================================================
pause
