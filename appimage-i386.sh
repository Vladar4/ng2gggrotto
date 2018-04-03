#!/bin/sh

# Configured for Ubuntu 16.04 LTS (i386)

NAME="Glorious Glacier Grotto"
PROJ="gggrotto"
ARCH="i386"
DATA="data"
DEPS="\
/usr/local/lib/libSDL2.so \
/usr/local/lib/libSDL2_gfx.so \
/usr/local/lib/libSDL2_image.so \
/usr/local/lib/libSDL2_mixer.so \
/usr/local/lib/libSDL2_ttf.so \
/lib/$ARCH-linux-gnu/libpng16.so.16 \
/usr/lib/$ARCH-linux-gnu/libogg.so.0 \
/usr/lib/$ARCH-linux-gnu/libsndio.so.6.1 \
/usr/lib/$ARCH-linux-gnu/libvorbis.so.0 \
/usr/lib/$ARCH-linux-gnu/libvorbisfile.so.3"

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

wget -O AppRun https://github.com/probonopd/AppImageKit/releases/download/10/AppRun-i686
chmod +x AppRun

cd ..
wget -N https://github.com/probonopd/AppImageKit/releases/download/10/appimagetool-i686.AppImage
chmod +x appimagetool-i686.AppImage
./appimagetool-i686.AppImage "$PROJ.AppDir" "$PROJ-$ARCH.AppImage"

