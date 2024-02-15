@echo off
set rpl=ReaPerLang

@echo on
pp --output="%rpl%.exe" "%rpl%.pl"
@REM "Gets error sometimes:"
@REM "Error removing C:/Users/%USERNAME%/AppData/Local/Temp/parl%RANDOMSTRING%.exe at C:/berrybrew/instance/5.36.1_64/perl/lib/File/Temp.pm line 899, <DATA> line 1."
