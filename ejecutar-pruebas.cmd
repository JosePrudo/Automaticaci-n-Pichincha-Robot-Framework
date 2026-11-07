@echo off
REM Ejecuta todas las pruebas de Robot Framework del proyecto.
REM Doble clic sobre este archivo o ejecutarlo desde la terminal.

cd /d "%~dp0"
set "PLAYWRIGHT_BROWSERS_PATH=%LOCALAPPDATA%\ms-playwright"
set "NODE_OPTIONS=--use-system-ca"

".venv\Scripts\python.exe" -m robot --outputdir results --name "Simulacion Credito Hipotecario" tests

REM Genera/actualiza el informe ejecutivo con evidencias de la ultima ejecucion.
".venv\Scripts\python.exe" generar_informe.py

echo.
echo ============================================================
echo  Reporte: %~dp0results\report.html
echo  Log con evidencias: %~dp0results\log.html
echo  Informe ejecutivo: %~dp0Informe ejecutivo\informe_ejecutivo.html
echo ============================================================
pause
