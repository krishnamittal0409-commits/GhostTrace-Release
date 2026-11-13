@echo off
title GhostTrace License Manager
cd /d "%~dp0"
start "" powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0license-gui.ps1"
exit
