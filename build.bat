cd src
nim c --out:..\gggrotto.exe -d:release --opt:speed gggrotto.nim
rmdir /s /q nimcache
cd ..

