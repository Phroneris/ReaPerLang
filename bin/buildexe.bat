@echo off
pushd %~dp0..
set src=%cd%\
popd
set rpl=ReaPerLang

@echo on
pp -o %rpl%.exe %src%%rpl%.pl