@echo off
REM Script para iniciar ComfyUI no Windows
REM Ajuste os caminhos conforme sua instalação

echo Iniciando ComfyUI...
echo.

REM Caminho do ComfyUI (ajuste conforme necessário)
set COMFYUI_PATH=E:\CONFY\ComfyUI\resources\ComfyUI
set VENV_PATH=E:\CONFY\.venv

REM Ativar ambiente virtual
call "%VENV_PATH%\Scripts\activate.bat"

REM Iniciar ComfyUI
cd /d "%COMFYUI_PATH%"
python main.py --user-directory "E:\CONFY\user" --input-directory "E:\CONFY\input" --output-directory "E:\CONFY\output" --listen 127.0.0.1 --port 8000

pause
