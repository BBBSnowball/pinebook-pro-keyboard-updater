- The [datasheet][datasheet] says that we can program via self sector programming (SSP) or JTAG. We don't want
  to rely on SSP because that requires that we can still speak to the firmware.
  - There might be a way to activate the bootloader by applying the right values at power on. We don't know
    because we only know the main application from the firmware update files.
  - JTAG would be great because that should work in all cases.
  - If we have JTAG, we can extract the complete firmware (unless the memory is read-protected).
- The datasheet says: "The SH68F83 will enter ICP mode once specified waveform of TCK, TDI, TMS and TDO pins
  is detected within a limited period after system POR. To get more details, please refer Flash Programmer’s user manual."
  - I couldn't find that document.
  - You can download ProWriter on the vendor's [website][sinoweb]. It does include a PDF that describes the flashing process
    but only for "connect this probe, click here in the GUI".
- ProWriter does include the firmware for several of the USB-to-JTAG adapters.
  - Most of them are in an unknown format but JET51A seems to be a raw binary file for STM32F4 or similar.
  - It is for an ARM process, little endian, only thumb instructions, loaded at 0x08010000.
  - I assume that the flash starts at 0x08000000 but there is a bootloader in the first 64 kB. The firmware is also
    64 kB so that would be a 128 kB device, which is quite small for an STM32F4. The RAM starts at 0x2000000 and the stack
    base suggests that there are 64 kB of RAM.

[datasheet]: https://raw.githubusercontent.com/jackhumbert/pinebook-pro-keyboard-updater/master/firmware/SH68F83V2.0.pdf
[sinoweb]: http://en.sinowealth.com/seach?type_id=68&a_v_type=1

