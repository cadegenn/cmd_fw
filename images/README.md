# How to build icon

## from a linux machine

Tested on an Ubuntu 16.04 host :

* Open and modify cmd_fw.xcf as needed
* Export image as a PNG image file
* Build icon with following command line under your favorite shell (Imagemagick must be installed)

```
convert cmd_fw.png -define icon:auto-resize=128,64,48,32,16 cmd_fw.ico

# this one does not preserve background transparency
# convert cmd_fw.png -bordercolor white -border 0 \( -clone 0 -resize 16x16 \) \( -clone 0 -resize 32x32 \) \( -clone 0 -resize 48x48 \) \( -clone 0 -resize 64x64 \) -delete 0 -alpha on -colors 256 cmd_fw.ico
```
