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
- The firmware contains some functions that do JTAG bitbanging.
  - PB6=TCK, PB7=TDI, PB8=TDO, PB9=TMS
  - B12 could be an active-high reset signal but it probably controls VDD.
  - There are some functions that drive non-JTAG waveforms to those pins. I think those are the "specified waveforms".
  - The software is also using channel 0 of ADC1, which is on PA0.
  - GPIO direction:
    (gdb) x/1x 0x40020014  # GPIOA: no outputs
    0x40020014:     0x00000000
    (gdb) x/1x 0x40020414  # GPIOB: PB7, PB10, PB11 are outputs
    0x40020414:     0x00000c80
    (gdb) x/1x 0x40020814  # GPIOC: PC0, PC3, PC6, PC7 are outputs
    0x40020814:     0x000000c9
  - This doesn't match my earlier assumptions about the JTAG pins.
  - 0x0801d9ea is not treating FLASH_CR.7 as reserved so this is probably for STM32F4nx with n=2 or 3 instead of 0 or 1
    (for which that bit would be reserved).
- Goal: Make that firmware work on some STM32F4, e.g. my STM32F411 Nucleo board.
  - Add some simple bootloader replacement that jumps to the application code.
  - USB is already working fine.
  - It hangs around `read_adc_dezivolt_08010b08`.
  - 0x08010340 in main jumps back to earlier code.

[datasheet]: https://raw.githubusercontent.com/jackhumbert/pinebook-pro-keyboard-updater/master/firmware/SH68F83V2.0.pdf
[sinoweb]: http://en.sinowealth.com/seach?type_id=68&a_v_type=1

Useful information:
- ARM Instructions: https://developer.arm.com/documentation/dui0489/c/arm-and-thumb-instructions/instruction-summary?lang=en
- NVIC/Systick: https://developer.arm.com/documentation/ddi0337/e/nested-vectored-interrupt-controller/nvic-programmer-s-model/nvic-register-map
- Bit-banding: https://developer.arm.com/documentation/100165/0201/Programmers-Model/Bit-banding/About-bit-banding?lang=en
- STM32F4 datasheet: https://www.st.com/resource/en/datasheet/stm32f415rg.pdf
- STM32F4 manual: https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405415-stm32f407417-stm32f427437-and-stm32f429439-advanced-armbased-32bit-mcus-stmicroelectronics.pdf
- JTAG state machine: https://www.researchgate.net/figure/JTAG-TAP-DAP-State-Machine-6_fig4_261079643
- Nucleo pinout: https://os.mbed.com/platforms/ST-Nucleo-F411RE/
- Another 8051, a lot cheaper: https://cdn.datasheetspdf.com/pdf-down/S/H/7/SH79F081A-SINOWEALTH.pdf

