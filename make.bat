@ECHO OFF

del BS1_patched.bs

copy BS1_original.sfc BS1_patched.bs


set BASS_ARG=
if "%~1" == "resume" set BASS_ARG=-d RESUME_EXPERIMENT

bass %BASS_ARG% -o BS1_patched.bs bsFE_testing.asm
checksumpatch.exe
