@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run.ps1" 1> "%~dp0startup_stdout.log" 2> "%~dp0startup_error.log"
if errorlevel 1 (
  echo Startup failed. See startup_error.log
  type "%~dp0startup_error.log"
  pause
)
