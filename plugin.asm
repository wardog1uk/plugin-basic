// Plug-in BASIC Kernel
// Copyright (c) 2014, 2023 by
// Jim Lawless - jimbo@radiks.net
// MIT / X11 license
// See: https://github.com/jimlawless/plugin-basic/blob/main/LICENSE
//
// Written using KickAssembler

BasicUpstart2(start)

.encoding "petscii_mixed"

.const CHRGET = $0073   // get next byte
.const IGONE =  $0308   // location of pointer to GONE
.const NEWSTT = $a7ae   // new statement
.const GONE =   $a7e4   // original GONE routine
.const STROUT = $ab1e   // output string at $(a)(y)
.const CHKCOM = $aeff   // check for a comma
.const SNERR =  $af08   // display syntax error
.const GOTBYC = $b79e   // convert ascii to byte in .x



* = $c000

start:
    // display intro message
    jsr intromsg

    // patch BASIC to use newgone instead of GONE
    lda #<newgone
    sta IGONE
    lda #>newgone
    sta IGONE+1

    rts


newgone:
    // get the basic token or character
    jsr CHRGET

    // store processor state
    php

    // check if it is a @ command
    cmp #'@'
    beq !+

    // not a @ command, so restore state and jump to original GONE routine
    plp
    jmp GONE+3  // skip over CHRGET in GONE

!:  plp
    jsr dispatch

    // do interpreter inner loop
    jmp NEWSTT


dispatch:
    // get the character for the command
    jsr CHRGET

    // check if it is 'a' or greater
    cmp #'a'
    bcs !+

    // not a letter, so throw a syntax error
    jmp SNERR

    // check if it is a letter a to z
!:  cmp #'z'+1
    bcc !+

    // not a letter, so throw a syntax error
    jmp SNERR

    // convert to an index 0 to 25
!:  sec
    sbc #'a'

    // multiply by 2 as table has 2 bytes per command
    asl

    // push address of the command to the stack
    tax
    lda table+1,x
    pha
    lda table,x
    pha

    // CHRGET will get next char then jump to the command
    jmp CHRGET


notimp:
    // display not implemented message
    ldy #>msg
    lda #<msg
    jmp STROUT


intromsg:
    // display intro message
    ldy #>imsg
    lda #<imsg
    jmp STROUT


// syntax
//  @c
// clear the screen
do_cls:
    // output shift/clear screen code
    lda #147
    jmp $ffd2


// syntax
// @b border,backgnd,char
// set border, background, and
// character color
do_border:
    // get byte into .x and set border
    jsr GOTBYC
    stx $d020

    // skip comma
    jsr CHKCOM

    // get byte into .x and set background
    jsr GOTBYC
    stx $d021

    // skip comma
    jsr CHKCOM

    // get byte into .x and set text color
    jsr GOTBYC
    stx $286

    rts


// table for commands
table:
    .word notimp-1    // @a

    .word do_border-1 // @b
    .word do_cls-1    // @c

    .word notimp-1    // @d
    .word notimp-1    // @e
    .word notimp-1    // @f
    .word notimp-1    // @g
    .word notimp-1    // @h
    .word notimp-1    // @i
    .word notimp-1    // @j
    .word notimp-1    // @k
    .word notimp-1    // @l
    .word notimp-1    // @m
    .word notimp-1    // @n
    .word notimp-1    // @o
    .word notimp-1    // @p
    .word notimp-1    // @q
    .word notimp-1    // @r
    .word notimp-1    // @s
    .word notimp-1    // @t
    .word notimp-1    // @u
    .word notimp-1    // @v
    .word notimp-1    // @w
    .word notimp-1    // @x
    .word notimp-1    // @y
    .word notimp-1    // @z


msg:
    .text "plug-in basic command not implemented..."
    .byte 0


imsg:
    .text "plug-in basic kernel v 0.02a"
    .byte $0d
    .text "by jim lawless"
// please add your vanity text here for any
// customizations you make
    .byte 0
