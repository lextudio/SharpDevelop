@set PROGFILES=%PROGRAMFILES%
@if exist "%PROGRAMFILES(x86)%" set PROGFILES=%PROGRAMFILES(x86)%
@if not exist "src\Libraries\AvalonEdit\ICSharpCode.AvalonEdit.sln" (
	git submodule update --init || exit /b 1
)

:: Locate vswhere (prefer Program Files (x86)) and try to find VS installation with MSBuild
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" set "VSWHERE=%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"

set "MSBUILD="
if exist "%VSWHERE%" (
	for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
		set "MSBUILD=%%i\MSBuild\Current\Bin\MSBuild.exe"
		goto :found_msbuild
	)
)
:: label used to break out once msbuild path is found
:found_msbuild

:: Fallbacks if vswhere or MSBuild not found
if not defined MSBUILD (
	if exist "%PROGFILES%\MSBuild\Current\Bin\MSBuild.exe" set "MSBUILD=%PROGFILES%\MSBuild\Current\Bin\MSBuild.exe"
)
if not defined MSBUILD (
	if exist "%PROGFILES%\MSBuild\12.0\Bin\msbuild.exe" set "MSBUILD=%PROGFILES%\MSBuild\12.0\Bin\msbuild.exe"
)

if not defined MSBUILD (
	echo MSBuild not found. Install Visual Studio 2022 or ensure vswhere is available.
	goto err
)

"%MSBUILD%" /m SharpDevelop.sln /p:Configuration=Release "/p:Platform=Any CPU" %*
@IF %ERRORLEVEL% NEQ 0 GOTO err
@exit /B 0
:err
echo @PAUSE
@exit /B 1