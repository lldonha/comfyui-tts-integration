@echo off
REM Script to concatenate TTS audio segments into final output
REM Usage: concat_audio.bat <batch_id> <comfyui_output_dir>

setlocal enabledelayedexpansion

set BATCH_ID=%1
set COMFYUI_OUTPUT=%2

if "%BATCH_ID%"=="" (
    echo Error: batch_id required
    echo Usage: concat_audio.bat ^<batch_id^> ^<comfyui_output_dir^>
    exit /b 1
)

if "%COMFYUI_OUTPUT%"=="" (
    set COMFYUI_OUTPUT=E:\ComfyUI\output
)

REM Create directories
if not exist "E:\api_tts\final_audio" mkdir "E:\api_tts\final_audio"
if not exist "E:\api_tts\temp" mkdir "E:\api_tts\temp"

REM Find all audio files for this batch
set CONCAT_FILE=E:\api_tts\temp\concat_%BATCH_ID%.txt
set OUTPUT_FILE=E:\api_tts\final_audio\%BATCH_ID%_final.wav

echo Searching for audio files with pattern: %BATCH_ID%_*.wav
echo.

REM Create concat file for ffmpeg
if exist "%CONCAT_FILE%" del "%CONCAT_FILE%"

REM List all matching files and create concat list
for /f "delims=" %%f in ('dir /b /o:n "%COMFYUI_OUTPUT%\%BATCH_ID%_*.wav" 2^>nul') do (
    echo Found: %%f
    echo file '%COMFYUI_OUTPUT%\%%f' >> "%CONCAT_FILE%"
)

REM Check if we found any files
if not exist "%CONCAT_FILE%" (
    echo Error: No audio files found for batch_id: %BATCH_ID%
    exit /b 1
)

echo.
echo Concatenating audio files...
echo Output: %OUTPUT_FILE%
echo.

REM Concatenate with FFmpeg
REM Add 500ms silence between segments
ffmpeg -f concat -safe 0 -i "%CONCAT_FILE%" ^
    -filter_complex "[0:a]apad=pad_dur=0.5[a]" ^
    -map "[a]" ^
    -y "%OUTPUT_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Success! Final audio created at:
    echo   %OUTPUT_FILE%
    echo.

    REM Get file size
    for %%A in ("%OUTPUT_FILE%") do set FILE_SIZE=%%~zA
    set /a FILE_SIZE_KB=!FILE_SIZE! / 1024
    echo   File size: !FILE_SIZE_KB! KB

    REM Clean up temp file
    del "%CONCAT_FILE%"
) else (
    echo.
    echo ✗ Error: FFmpeg concatenation failed
    exit /b 1
)

endlocal
