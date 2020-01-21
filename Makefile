SOURCES := \
	updater.c \
	usb_read.c \
	usb_write.c \
	usb_context.c \
	usb_keyboard.c \
	usb_touchpad.c \
	firmware/fw_tp_update.hex.c \
	firmware/fw_iso.hex.c \
	firmware/fw_ansi.hex.c \
	firmware/fw_ansi_gui_fix.hex.c \
	firmware/fw_iso_gui_fix.hex.c \
	firmware/tpfw.bin.c \

all: updater

firmware/%.hex.c: firmware/%.hex
	xxd -i $^ $@

firmware/%.bin.c: firmware/%.bin
	xxd -i $^ $@

updater: $(SOURCES)
	gcc -o $@ $^ -lusb-1.0

usbreset: extra/usbreset.c
	gcc -o $@ $^

clean:
	rm -f updater usbreset firmware/*.c
