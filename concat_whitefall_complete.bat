@echo off
REM Script para concatenar os 3 episódios de Whitefall em um áudio final completo
REM Usage: concat_whitefall_complete.bat

setlocal enabledelayedexpansion

echo ========================================
echo  Whitefall - Concatenacao Completa
echo ========================================
echo.

REM Diretórios
set FINAL_AUDIO_DIR=E:\api_tts\final_audio
set OUTPUT_FILE=%FINAL_AUDIO_DIR%\whitefall_complete_final.wav
set TEMP_DIR=E:\api_tts\temp

REM Criar diretórios se não existirem
if not exist "%FINAL_AUDIO_DIR%" mkdir "%FINAL_AUDIO_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo Verificando episodios...
echo.

REM Verificar se os 3 episódios existem
set EP1=%FINAL_AUDIO_DIR%\whitefall_ep1_final.wav
set EP2=%FINAL_AUDIO_DIR%\whitefall_ep2_final.wav
set EP3=%FINAL_AUDIO_DIR%\whitefall_ep3_final.wav

set ALL_EXIST=1

if not exist "%EP1%" (
    echo [ERRO] Episodio 1 nao encontrado: %EP1%
    set ALL_EXIST=0
)

if not exist "%EP2%" (
    echo [ERRO] Episodio 2 nao encontrado: %EP2%
    set ALL_EXIST=0
)

if not exist "%EP3%" (
    echo [ERRO] Episodio 3 nao encontrado: %EP3%
    set ALL_EXIST=0
)

if %ALL_EXIST%==0 (
    echo.
    echo Por favor, gere todos os 3 episodios primeiro:
    echo 1. Rode whitefall_episode1.json no n8n
    echo 2. Rode whitefall_episode2.json no n8n
    echo 3. Rode whitefall_episode3.json no n8n
    echo.
    echo Depois execute este script novamente.
    pause
    exit /b 1
)

echo [OK] Episodio 1 encontrado
echo [OK] Episodio 2 encontrado
echo [OK] Episodio 3 encontrado
echo.

REM Criar arquivo de concatenação para FFmpeg
set CONCAT_FILE=%TEMP_DIR%\whitefall_concat.txt

echo Criando lista de concatenacao...
(
    echo file '%EP1%'
    echo file '%EP2%'
    echo file '%EP3%'
) > "%CONCAT_FILE%"

echo [OK] Lista criada: %CONCAT_FILE%
echo.

REM Concatenar com FFmpeg
echo Concatenando episodios...
echo Isso pode levar alguns minutos...
echo.

ffmpeg -f concat -safe 0 -i "%CONCAT_FILE%" ^
    -filter_complex "[0:a]apad=pad_dur=1.0[a]" ^
    -map "[a]" ^
    -y "%OUTPUT_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  SUCESSO!
    echo ========================================
    echo.
    echo Audio final criado em:
    echo   %OUTPUT_FILE%
    echo.

    REM Obter informações do arquivo
    for %%A in ("%OUTPUT_FILE%") do (
        set FILE_SIZE=%%~zA
    )
    set /a FILE_SIZE_KB=!FILE_SIZE! / 1024
    set /a FILE_SIZE_MB=!FILE_SIZE_KB! / 1024

    echo Tamanho: !FILE_SIZE_MB! MB ^(!FILE_SIZE_KB! KB^)
    echo.

    REM Obter duração com FFprobe (se disponível)
    ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%OUTPUT_FILE%" > "%TEMP_DIR%\duration.txt" 2>nul
    if exist "%TEMP_DIR%\duration.txt" (
        set /p DURATION=<"%TEMP_DIR%\duration.txt"
        echo Duracao: !DURATION! segundos
        del "%TEMP_DIR%\duration.txt"
    )

    echo.
    echo Episodios concatenados:
    echo   1. A Partida ^(12 segmentos^)
    echo   2. A Jornada ^(12 segmentos^)
    echo   3. O Isolamento ^(11 segmentos^)
    echo   Total: 35 segmentos
    echo.

    REM Limpar arquivo temporário
    del "%CONCAT_FILE%"

    echo Arquivo temporario removido.
    echo.
) else (
    echo.
    echo ========================================
    echo  ERRO!
    echo ========================================
    echo.
    echo FFmpeg falhou ao concatenar os arquivos.
    echo.
    echo Verifique se:
    echo   1. FFmpeg esta instalado
    echo   2. Os arquivos de episodio estao corretos
    echo   3. Ha espaco em disco suficiente
    echo.
    exit /b 1
)

echo Processo concluido!
echo.
pause

endlocal
