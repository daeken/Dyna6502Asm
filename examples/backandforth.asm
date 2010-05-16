;
; moves a dot back and forth
;

start:
  lda #$f
  sta $0               ; Xpos = 15
  lda #$4
  sta $1               ; Ypos = $02(0f) (top line)
  lda #$01
  sta $2               ; direction (0=left, 1=right)

mainloop:
  lda $00              ; load Xpos
  sta $03              ; save it..
  lda $01              ; load Ypos
  sta $04              ; save it..

  lda $02              ; check direction
  cmp #$00             ; left?
  bne notLeft
  inc $0               ; increment X
  jmp checkBounce
notLeft:
  dec $0               ; decrement X

checkBounce:
  ldx $02              ; regX = direction
  lda $0               ; load xpos
  cmp #$1f             ; at-most right?
  bne notBounceLeft
  ldx #$1              ; go left
  jmp draw             ; draw dot
notBounceLeft:
  cmp #$0              ; at-most right?
  bne draw
  ldx #$0              ; go right
draw:
  stx $02              ; update direction

  lda #$1              ; A=1 white color
  ldx #$0
  sta ($0,x)           ; draw dot

  lda #$0              ; A=0 black color
  ldx #$0
  sta ($3,x)           ; erase previous dot

  jmp mainloop         ; continue forever


