@echo off
title ButaAI Windows Installer
echo ==============================================================================
echo ButaAI Windows 1-Click Installer
echo ==============================================================================
echo Launching PowerShell installer with Bypass ExecutionPolicy...
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
pause
