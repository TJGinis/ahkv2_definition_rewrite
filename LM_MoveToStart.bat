@echo off
copy "Installer.ahk" "%Appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
xcopy /I "pref" "%Appdata%\Microsoft\Windows\Start Menu\Programs\Startup"