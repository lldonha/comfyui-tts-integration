@echo off
echo ========================================
echo  Iniciando Sistema TTS ComfyUI + n8n
echo ========================================
echo.

REM Verificar se Docker está rodando
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Docker não está rodando!
    echo Por favor, inicie o Docker Desktop primeiro.
    pause
    exit /b 1
)

echo [1/3] Iniciando Docker Compose (n8n + API Wrapper)...
cd /d %~dp0
docker-compose up -d

echo.
echo [2/3] Aguardando 5 segundos...
timeout /t 5 /nobreak >nul

echo.
echo [3/3] Verificando status dos containers...
docker-compose ps

echo.
echo ========================================
echo  Sistema Iniciado!
echo ========================================
echo.
echo n8n: http://localhost:5678
echo API Wrapper: http://localhost:8001
echo ComfyUI: http://localhost:8000
echo.
echo Pressione qualquer tecla para sair...
pause >nul
