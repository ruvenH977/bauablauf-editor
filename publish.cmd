@echo off
REM ---------------------------------------------------------------
REM  Bauablauf Editor - publish to GitHub Pages
REM  Double-click this file to push the current state of the folder.
REM  The live site updates about a minute after a successful push.
REM ---------------------------------------------------------------
setlocal
cd /d "%~dp0"

echo.
echo  Bauablauf Editor - publish
echo  ==========================
echo.

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo  ERROR: this folder is not a git repository.
  echo.
  pause
  exit /b 1
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo  ERROR: no 'origin' remote is configured yet.
  echo.
  echo  Run this once, with your own GitHub username:
  echo    git remote add origin https://github.com/USERNAME/bauablauf-editor.git
  echo.
  pause
  exit /b 1
)

echo  Changes to publish:
echo.
git status --short
echo.

git diff --quiet && git diff --cached --quiet
if not errorlevel 1 (
  echo  Nothing has changed - there is nothing to publish.
  echo.
  pause
  exit /b 0
)

set "MSG=%~1"
if "%MSG%"=="" set /p "MSG=  Commit message (Enter for 'Update editor'): "
if "%MSG%"=="" set "MSG=Update editor"

git add -A
if errorlevel 1 goto failed

git commit -m "%MSG%"
if errorlevel 1 goto failed

echo.
echo  Pushing...
git push
if errorlevel 1 goto failed

echo.
echo  Done. The live site updates in about a minute.
echo.
pause
exit /b 0

:failed
echo.
echo  Something went wrong - see the message above.
echo  If it mentions index.lock, delete the file .git\index.lock and try again.
echo.
pause
exit /b 1
