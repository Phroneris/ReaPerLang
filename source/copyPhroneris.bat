@echo off
pushd %~dp0..\..
set main=%cd%\
popd
set ph=JPN_Phroneris.ReaperLangPack
set mainL="%main%%ph%"

echo Main folder: %main%
echo,
echo Bring or Send? (WITHOUT overwrite warnings!)
set /p input="[b/s] > "
if aaa%input%==aaab goto Bring
if aaa%input%==aaas goto Send
goto End

:Bring
@echo on
copy /Y %mainL% %ph%
@echo off
echo,
goto End

:Send
@echo on
copy /Y "_1_%ph%" %mainL%
@echo off
set preT=template_reaper
set postT=.ReaperLangPack.txt
echo,
set /p verT="%preT%***%postT% > "
@echo on
copy /Y "_1_%preT%%verT%%postT%" "%main%%preT%%verT%%postT%"
@echo off
echo,
goto End

:End
pause
