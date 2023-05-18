@echo off 

pushd C:\Program Files
for /f "delims=" %%F in ('dir /s /b R.exe') do set "Rpath=%%F"
popd

echo %Rpath%

SET PART2=" -e "shiny::runApp('.', launch.browser = TRUE)"

SET run_cmd="%Rpath%%PART2%

echo %run_cmd%

%run_cmd%

pause