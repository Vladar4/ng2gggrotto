#!/bin/sh
cd src
nim c --out:../gggrotto -d:release --opt:speed gggrotto.nim
cd ..

