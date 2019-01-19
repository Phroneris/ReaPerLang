@echo off
pushd %~dp0..\..
set main=%cd%\
popd
set ph=JPN_Phroneris
set mainL="%main%%ph%._RLP"

echo Main folder: %main%
echo,
echo Bring or Send? (WITHOUT overwrite warnings!)
set /p input="[b/s] > "
if aaa%input%==aaab goto Bring
if aaa%input%==aaas goto Send
goto End

:Bring
set hereL="%ph%.txt"
@echo on
copy /Y %mainL% %hereL%
@echo off
echo,
goto End

:Send
set hereNewL=_1_lng_new.txt
@echo on
copy /Y %hereNewL% %mainL%
@echo off
set hereNewT=_1_tmpl_crr.txt
set preT=template_reaper
set postT=.ReaperLangPack.txt
echo,
set /p verT="%preT%***%postT% > "
set mainT="%main%%preT%%verT%%postT%"
@echo on
copy /Y %hereNewT% %mainT%
@echo off
echo,
goto End

:End
pause
