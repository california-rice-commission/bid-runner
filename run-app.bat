@echo off 

FOR /F "tokens=* USEBACKQ" %%F IN (`Rscript --version`) DO (
SET var=%%F
)

SET R_VERSION_DETECTED=%var:~20,5%

SET PART1="C:/Program Files/R/R-
SET PART2=/bin/x64/R.exe" -e "shiny::runApp('.', launch.browser = TRUE)"

SET run_cmd=%PART1%%R_VERSION_DETECTED%%PART2%

%run_cmd%

