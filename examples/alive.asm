; I'm alive
; by PJP

start:
 lda #15
 sta $0 ;xpos
 sta $1 ;ypos

loop:
 lda $fe
 and #3
 cmp #0
 beq go_left
 cmp #1
 beq go_right
 cmp #2
 beq go_down
 dec $1
draw:
 lda $1
 and #$1f
 asl
 tax
 lda ypos,x
 sta $2
 inx
 lda ypos,x
 sta $3
 lda $0
 and #$1f
 tay
 lda ($2),y
 tax
 inx
 txa
 sta ($2),y
 jmp loop
go_down:
 inc $1
 jmp draw
go_left:
 dec $0
 jmp draw
go_right:
 inc $0
 jmp draw

ypos:
 dcb $00,$02,$20,$02,$40,$02,$60,$02
 dcb $80,$02,$a0,$02,$c0,$02,$e0,$02
 dcb $00,$03,$20,$03,$40,$03,$60,$03
 dcb $80,$03,$a0,$03,$c0,$03,$e0,$03
 dcb $00,$04,$20,$04,$40,$04,$60,$04
 dcb $80,$04,$a0,$04,$c0,$04,$e0,$04
 dcb $00,$05,$20,$05,$40,$05,$60,$05
 dcb $80,$05,$a0,$05,$c0,$05,$e0,$05


