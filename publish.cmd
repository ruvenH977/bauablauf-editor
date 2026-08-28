@echo off
REM ---------------------------------------------------------------
REM  Bauablauf Editor - publish to GitHub Pages
REM  Double-click this file to push the current state of the folder.
REM  The live site updates about a minute after a successful push.
REM ---------------------------------------------------------------
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "REPO_URL=https://github.com/ruvenH977/bauablauf-editor.git"
set "BRANCH=main"

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

REM --- make sure the remote exists; add it automatically if not ---
git remote get-url origin >nul 2>&1
if errorlevel 1 (
  echo  No 'origin' remote yet - adding it:
  echo    %REPO_URL%
  git remote add origin "%REPO_URL%"
  if errorlevel 1 goto failed
  echo.
)

REM --- anything to publish? (covers new/untracked files too) ---
set "DIRTY="
for /f "delims=" %%i in ('git status --porcelain') do set "DIRTY=1"

if not defined DIRTY (
  echo  No local changes.
  REM  still worth pushing if commits exist that the remote does not have
  git rev-parse --abbrev-ref --symbolic-full-name @{u} >nul 2>&1
  if errorlevel 1 (
    echo  This branch has never been pushed - publishing it now.
    echo.
    goto dopush
  )
  for /f %%c in ('git rev-list --count @{u}..HEAD 2^>nul') do set "AHEAD=%%c"
  if "!AHEAD!"=="0" (
    echo  Everything is already published - nothing to do.
    echo.
    pause
    exit /b 0
  )
  echo  !AHEAD! commit^(s^) not yet pushed - publishing them now.
  echo.
  goto dopush
)

echo  Changes to publish:
echo.
git status --short
echo.

set "MSG=%~1"
if "%MSG%"=="" set /p "MSG=  Commit message (Enter for 'Update editor'): "
if "%MSG%"=="" set "MSG=Update editor"

git add -A
if errorlevel 1 goto failed

git commit -m "%MSG%"
if errorlevel 1 goto failed

:dopush
echo  Pushing...

REM  -u on the first push so later pushes need no arguments
git rev-parse --abbrev-ref --symbolic-full-name @{u} >nul 2>&1
if errorlevel 1 (
  git push -u origin %BRANCH%
) else (
  git push
)
if errorlevel 1 goto failed

echo.
echo  Done. The live site updates in about a minute:
echo    https://ruvenH977.github.io/bauablauf-editor/
echo.
pause
exit /b 0

:failed
echo.
echo  Something went wrong - see the message above.
echo.
echo  Common causes:
echo    - The repository does not exist on GitHub yet. Create an empty one
echo      named 'bauablauf-editor' (no README, no .gitignore, no licence).
echo    - A stale lock file: delete .git\index.lock and try again.
echo.
pause
exit /b 1
