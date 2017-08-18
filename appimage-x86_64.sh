#!/bin/sh

# Configured for Ubuntu 12.04.5 LTS (x86_64)

NAME="Glorious Glacier Grotto"
PROJ="gggrotto"
ARCH="x86_64"
DATA="data"
DEPS="\
/usr/local/lib/libSDL2.so \
/usr/local/lib/libSDL2_gfx.so \
/usr/local/lib/libSDL2_image.so \
/usr/local/lib/libSDL2_mixer.so \
/usr/local/lib/libSDL2_ttf.so \
/usr/lib/$ARCH-linux-gnu/libfreetype.so \
/usr/lib/$ARCH-linux-gnu/libogg.so.0 \
/lib/$ARCH-linux-gnu/libpng12.so.0 \
/usr/lib/$ARCH-linux-gnu/libvorbis.so.0 \
/usr/lib/$ARCH-linux-gnu/libvorbisfile.so.3 \
/lib/$ARCH-linux-gnu/libz.so.1"

rm -rf "$PROJ.AppDir"
mkdir -p "$PROJ.AppDir/usr/bin"
mkdir -p "$PROJ.AppDir/usr/lib"
cp "$PROJ" "$PROJ.AppDir/usr/bin"
cp "$DATA/$PROJ".png "$PROJ.AppDir"

cp -R "$DATA" "$PROJ.AppDir/usr"
cd "$PROJ.AppDir"
cp $DEPS usr/lib
strip usr/bin/* usr/lib/*

echo "[Desktop Entry]
Type=Application
Name=$NAME
Exec=$PROJ
Categories=Game;
Icon=$PROJ" > "$PROJ.desktop"

wget -O AppRun https://github.com/probonopd/AppImageKit/releases/download/8/AppRun-x86_64
chmod +x AppRun

cd ..
wget -N https://github.com/probonopd/AppImageKit/releases/download/8/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage "$PROJ.AppDir" "$PROJ-$ARCH.AppImage"

