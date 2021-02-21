#! /usr/bin/env nix-shell
#! nix-shell -i bash shell.nix
set -e

# The firmware expects a bootloader. Fake it.
mkdir -p .tmp
cat >.tmp/fake-bl.S <<"EOF"
#.section vectors
#.align 2
#.globl vectors
#vectors2:
vector_table:
.text
# odd address means thumb code
.long 0x20001000
.long resetvec+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1
.long halt+1

.globl halt
.thumb
halt:
  1: b 1b

.globl resetvec
.thumb
resetvec:
  #bx 0x0801f269
  ldr r3, =0x08010004
  ldr r3, [r3]
  bx r3
EOF
cat >.tmp/link.ld <<"EOF"
MEMORY
{
  FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 0x20000   /* 128k */
}

ENTRY(resetvec)

SECTIONS
{
  .text :
  {
    KEEP(*(.vectors))
    KEEP(*(.text))
  } > FLASH
}
EOF

set -x
arm-none-eabi-gcc .tmp/fake-bl.S -o .tmp/fake-bl -nostdlib -Wl,-T.tmp/link.ld -Wl,--no-gc-sections
#arm-none-eabi-as .tmp/fake-bl.S -o .tmp/fake-bl
#arm-none-eabi-objdump -dx .tmp/fake-bl

arm-none-eabi-objcopy -O ihex .tmp/fake-bl .tmp/jet51a_1.hex
arm-none-eabi-objcopy -I binary -O ihex --change-addresses 0x08010000 ./JET51A_V1.90.ARM .tmp/jet51a_2.hex
#srec_cat .tmp/jet51a_{1,2}.hex >.tmp/jet51a.hex

# symbols generated from Vivisect: for x in vw.getNames(): print("--add-symbol {}=.text2:0x{:04x}".format(x[1], x[0]-0x08010000))
#FIXME replace spaces in symbol names ^^
arm-none-eabi-objcopy .tmp/fake-bl .tmp/both --add-section .text2=./JET51A_V1.90.ARM --set-section-flags .text2=alloc,contents,load,readonly,code --change-section-address .text2=0x08010000 @jet51a-symbols.txt

openocd -f interface/stlink-v2-1.cfg -f target/stm32f4x.cfg -l .tmp/openocd.log &
# monitor program .tmp/jet51a.hex verify

sleep 0.2
arm-none-eabi-gdb -x openocd.gdb

