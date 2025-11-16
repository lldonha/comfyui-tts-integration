@echo off
echo ========================================
echo  Configurar Inicialização Automática
echo ========================================
echo.
echo Este script criará um atalho na pasta de inicialização do Windows
echo para iniciar o sistema automaticamente ao ligar o PC.
echo.
echo Pressione qualquer tecla para continuar ou Ctrl+C para cancelar...
pause >nul

REM Obter caminho da pasta de inicialização
set STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup

REM Criar atalho usando PowerShell
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%STARTUP_FOLDER%\ComfyUI_TTS_System.lnk'); $Shortcut.TargetPath = '%~dp0start_all.bat'; $Shortcut.WorkingDirectory = '%~dp0'; $Shortcut.Description = 'Inicia sistema TTS ComfyUI + n8n'; $Shortcut.Save()"

if %errorlevel% equ 0 (
    echo.
    echo [SUCESSO] Atalho criado em:
    echo %STARTUP_FOLDER%\ComfyUI_TTS_System.lnk
    echo.
    echo O sistema será iniciado automaticamente quando você ligar o PC.
    echo.
    echo IMPORTANTE: Certifique-se de que o Docker Desktop também está
    echo configurado para iniciar automaticamente (Settings -^> General -^> Start Docker Desktop when you log in^)
) else (
    echo.
    echo [ERRO] Falha ao criar atalho.
)

echo.
pause
