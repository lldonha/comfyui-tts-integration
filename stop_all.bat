@echo off
echo ========================================
echo  Parando Sistema TTS ComfyUI + n8n
echo ========================================
echo.

cd /d %~dp0
docker-compose down

echo.
echo Sistema parado com sucesso!
pause
