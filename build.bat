ECHO Starting Build! > build/buildlog.txt
tools\SNASM68K.EXE /p src/spaceten/build.asm,build/spaceten.bin,build/spaceten.map,build/spaceten.lst >> build/buildlog.txt
ECHO Finished Build! >> build/buildlog.txt
EXIT