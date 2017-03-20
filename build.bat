cd src
nim c --out:..\gggrotto.exe -d:release --opt:speed --app:gui gggrotto.nim
rmdir /s /q nimcache
cd ..

