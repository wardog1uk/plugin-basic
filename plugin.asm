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
.const STROUT = $ab1e   // output a string to BASIC
.const CHKCOM = $aeff   // check for a comma
.const SNERR =  $af08   // display syntax error
.const GOTBYC = $b79e   // convert ascii to byte in .x

* = $c000

start:
    jsr intromsg

    lda #<newgone
    sta IGONE
    lda #>newgone
    sta IGONE+1

    rts

newgone:
    jsr CHRGET
    php
    cmp #'@'
    beq !+

// not our @ token ... jmp back
// into GONE
    plp
// jump past the JSR chrget call in GONE
    jmp GONE+3

!:  plp
    jsr dispatch
    jmp NEWSTT

dispatch:
    jsr CHRGET
    cmp #'a'
    bcs !+
    jmp SNERR

!:  cmp #'z'+1
    bcc !+
    jmp SNERR

!:  sec
    sbc #'a'
    asl
    tax
    lda table+1,x
    pha
    lda table,x
    pha
    jmp CHRGET

notimp:
    ldy #>msg
    lda #<msg
    jmp STROUT

intromsg:
    ldy #>imsg
    lda #<imsg
    jmp STROUT


// syntax
//  @c
// clear the screen
do_cls:
    lda #147
    jmp $ffd2

// syntax
// @b border,backgnd,char
// set border, background, and
// character color
do_border:
    jsr GOTBYC // get byte into .x
    stx $d020 // set border
    jsr CHKCOM // skip comma

    jsr GOTBYC // get byte into .x
    stx $d021 // set background
    jsr CHKCOM // skip comma

    jsr GOTBYC // get byte into .x
    stx $286  // set text color
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

