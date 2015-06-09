.nolist
; .device ATTiny85 
.include "tn85def.inc"
.list

.def ri = R1
.def temp = R16
.def delay0 = R17
.def delay1 = R18
.def delay2 = R19

.equ led = 1

; stack init macro
.macro lsp 
        ldi @0, low(@1)
        out SPL, @0
        ldi @0, high(@1)
        out SPH, @0
.endmacro

; start address
.org $0000

; interrupt vectors
rjmp main; rjmp RESET ; Address 0x0000
reti; rjmp INT0_ISR ; Address 0x0001
reti; rjmp PCINT0_ISR ; Address 0x0002
reti; rjmp TIM1_COMPA_ISR ; Address 0x0003
reti; rjmp TIM1_OVF_ISR ; Address 0x0004
rjmp timer; rjmp TIM0_OVF_ISR ; Address 0x0005
reti; rjmp EE_RDY_ISR ; Address 0x0006
reti; rjmp ANA_COMP_ISR ; Address 0x0007
reti; rjmp ADC_ISR ; Address 0x0008
reti; rjmp TIM1_COMPB_ISR ; Address 0x0009
reti; rjmp TIM0_COMPA_ISR ; Address 0x000A
reti; rjmp TIM0_COMPB_ISR ; Address 0x000B
reti; rjmp WDT_ISR ; Address 0x000C
reti; rjmp USI_START_ISR ; Address 0x000D
reti; rjmp USI_OVF_ISR ; Address 0x000E

timer:
        ; save flag register
        in ri, SREG
        ; work some
        rcall work
        ; restore flag register
        out SREG, ri
        reti 

main:
        ; stack init
        lsp temp, RAMEND
        ; setup timer
        ldi temp, 0b00000101
        out TCCR0B, temp
        ldi temp, 0b00000010
        out TIMSK, temp
        ; init leds port
        sbi DDRB, led
        ; enable interrupts
        sei

work:
        ; delay
        rcall delay
        ; led on
        sbi PINB, led
        ret

delay:           
        ldi delay2, $16  
        ldi delay1, $16  
        ldi delay0, $16
loop:
        subi delay0, 1 
        sbci delay1, 0 
        sbci delay2, 0
        brcc loop
        ret
