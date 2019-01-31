grep "CC_FLAGS :=" pmufw/Makefile | grep -e "-Os" || sed -i '/-mxl-soft-mul/ s/$/ -Os -flto -ffat-lto-objects/' pmufw/Makefile
cd pmufw
make