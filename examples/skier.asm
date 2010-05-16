; Skier for 6502asm.com by ern0@linkbroker.hu
; Beta Release 2008.11.29
; (Send e-mail for emulator version)

; Instructions:
;  Try to don\'t hit the trees
;  There are 4 game levels, 
;  (the last one is endless - yet)
; Game keys: 
;  \"n\" or \"j\" - left, 
;  \"m\" or \"k\" - right
; End keys: 
;  \'`\' - exit (left to \'1\', no ESC support)
;  other - restart game  
;
; TODO list:
;  Scroll speedup
;  On-screen instructions
;   - start 
;   - game over
;  Scoring (completion percent)
;  \"Game Completed\" situation
;  Some gameplay enhancments


; splash screen -------------------------------

; \'S\'
*=$224     
  dcb 1,1,1,1
*=$243
  dcb 1,1
*=$263
  dcb 1,1
*=$284
  dcb 1,1,1
*=$2a6
  dcb 1,1
*=$2c6
  dcb 1,1
*=$2e3
  dcb 1,1,1,1

; \'k\'
*=$229
  dcb 1,1
*=$249
  dcb 1,1
*=$269
  dcb 1,1,0,1,1
*=$289
  dcb 1,1,1
*=$2a9
  dcb 1,1,1,1
*=$2c9
  dcb 1,1,0,1,1
*=$2e9
  dcb 1,1,0,0,1

; \'i\'
*=$22f
  dcb 1,1
*=$26f
  dcb 1,1
*=$28f
  dcb 1,1
*=$2af
  dcb 1,1
*=$2cf
  dcb 1,1
*=$2ef
  dcb 1,1

; \'e\'
*=$273 
  dcb 1,1,1
*=$292
  dcb 1,1,0,1,1
*=$2b2
  dcb 1,1,1,1,1
*=$2d2
  dcb 1,1
*=$2f3
  dcb 1,1,1,1

; \'r\'
*=$278
  dcb 1,0,1,1
*=$298
  dcb 1,1,0,1
*=$2b8 
  dcb 1,1
*=$2d8
  dcb 1,1
*=$2f8
  dcb 1,1

; small \"BETA\"
*=$550
  dcb 5,5,0, 0, 5,5,5, 0, 5,5,5, 0, 0,5,0
*=$570
  dcb 5,0,5, 0, 5,0,0, 0, 0,5,0, 0, 5,0,5
*=$590
  dcb 5,5,0, 0, 5,5,5, 0, 0,5,0, 0, 5,5,5
*=$5b0
  dcb 5,0,5, 0, 5,0,0, 0, 0,5,0, 0, 5,0,5
*=$5d0
  dcb 5,5,0, 0, 5,5,5, 0, 0,5,0, 0, 5,0,5


; off-screen buffer ---------------------------

*=$600
  jmp start  ; don\'t use scroll area
  
  dcb 0,0,0,0,0        ; 1nd line (w/o jmp)
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0  ; 2nd line
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0  ; 3rd line
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0  ; 4th line
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  dcb 0,0,0,0,0,0,0,0
  
start: ;---------------------------------------

  ; delay params
  lda #40  ; inner cycle delay
  sta $d0
  lda #1   ; game delay
  sta $d1
  lda #60  ; car delay
  sta $d2
  
  jsr init
gcyc:
  jsr game
  jsr die
  cmp #$60
  bne gcyc
  jmp cleanup
  
init: ;----------------------------------------

  ; save and clear the leading jmp
  lda $601
  sta $61
  lda $602
  sta $62

  ; clear last key
  lda #0
  sta $ff
  
  jmp cls
  
cleanup: ;-------------------------------------
  
  lda #$4c  ; restore leading jmp
  sta $600
  lda $61
  sta $601
  lda $62 
  sta $602
  
  ; continue with cls

cls: ;-----------------------------------------
  
  ; clear the screen
  
  lda #0
  ldx #0
xcls:
  sta $200,x
  sta $300,x
  sta $400,x
  sta $500,x
  dex
  bne xcls

  ; clear off-screen area
  
  ldx #32
oxcls:
  sta $600,x
  dex
  bpl oxcls
  rts

game: ;----------------------------------------

  jsr rstlevel
  lda #$10
  sta $f0  ; skier position
  lda #0
  sta $f1  ; collision flag

  jsr cls
    
cycle: ;---------------------------------------

  lda $d4  ; generating freq
  sta $e1  ; scroll counter
  jsr nexttree

nogencyc:
  jsr scroll
  jsr skier
  lda $f1  ; collision
  beq noc
  rts
noc:  
  ldx #10
  jsr gdelay

  dec $d6
  bne nolevchg
  dec $d7
  bne nolevchg
  jsr inclevel

nolevchg:
  dec $e1
  bpl nogencyc
  
  jmp cycle
  
die: ;-------------------------------------

  ; bleeding
  
  lda #4
  sta $e1
locyc:
  jsr nexttree
  jsr scroll
  jsr skier
  jsr gdelay
  jsr scroll
  jsr skier
  jsr gdelay
  jsr scroll
  jsr skier
  jsr gdelay
  dec $e1
  bpl locyc
  
  ; car
  
  jsr cdelay
  jsr cdelay
  jsr cdelay
  jsr cdelay
  jsr cdelay
  jsr cdelay
  jsr cdelay
  
  lda #$6  ; blinker color
  sta $e2
  lda #0  ; start position
  sta $e3
  
  lda $f0  ; skier position
  clc
  adc #5
  sta $f2  ; as stop position
  cmp #25
  bvc carcyc
  lda #25
  sta $f2
  
carcyc:
  ldx $e3
  lda #1
  
  sta $320,x  ; column 1: front
  sta $340,x
  sta $360,x
  sta $380,x
  sta $3a0,x
  
  cpx #1
  bmi qdraw1
  
  sta $31f,x  ; column 2: window, blinker
  sta $37f,x
  sta $39f,x
  lda #$c
  sta $3bf,x
  lda #0
  sta $33f,x
  sta $35f,x
  
  lda $e2  ; blinker of column 2
  eor #4  ; blinker color change
  sta $e2
  sta $2ff,x
  ldy $f0
  lda #$a
  sta $300,y
  lda #$2
  sta $2ff,y
  sta $301,y

  cpx #2
  bmi qdraw1

  lda #0  ; column 3: window end
  sta $33e,x
  sta $35e,x
  sta $2fe,x
  lda #$c
  sta $3be,x
  lda #1   
  sta $31e,x
  sta $37e,x
  sta $39e,x
  
  cpx #3
  bmi qdraw1
  
  lda #0  ; column 4: pure white
  sta $3bd,x  ; erase wheel
  lda #1
  sta $31d,x  
  sta $33d,x
  sta $35d,x
  sta $37d,x
  sta $39d,x
  
  cpx #4
  bpl nqdraw1
qdraw1:  
  jmp qdraw
  
nqdraw1:
  lda #2  ; column 5: cross begins
  sta $35c,x
  lda #1
  sta $31c,x
  sta $33c,x
  sta $37c,x
  sta $39c,x
  
  cpx #5
  bmi qdraw
  
  lda #2  ; column 6: cross middle
  sta $33b,x
  sta $35b,x
  sta $37b,x
  lda #$c
  sta $3bb,x
  lda #1
  sta $31b,x
  sta $39b,x
  
  cpx #6
  bmi qdraw
  
  lda #2  ; column 7: cross ends
  sta $35a,x
  lda #$c
  sta $3ba,x
  lda #1
  sta $31a,x
  sta $33a,x
  sta $37a,x
  sta $39a,x
  
  cpx #7
  bmi qdraw
  
  lda #1  ; column 8: pure white
  sta $319,x  
  sta $339,x
  sta $359,x
  sta $379,x
  sta $399,x
  lda #0  
  sta $3b9,x  ; erase wheel

  cpx #8
  bmi qdraw
  
  sta $318,x  ; column 9: erase  
  sta $338,x
  sta $358,x
  sta $378,x
  sta $398,x

qdraw:  
  jsr cdelay
  inc $e3
  ldx $e3
  cpx $f2
  beq blinkin
  jmp carcyc
  
blinkin:
  lda #0
  sta $ff
  ldx $e3
  lda $e2  ; blinker of column 2
  eor #4  ; blinker color change
  sta $e2
  sta $2fe,x
  jsr cdelay
  jsr cdelay
  
  lda $ff  
  beq blinkin
  ldx #0
  stx $ff
  
  rts
  
skier: ;---------------------------------------

  ldx $f0  ; skier position
  lda $f1
  beq alive
  
  lda #$a
  sta $360,x
  sta $340,x
  lda #$2
  sta $33f,x
  sta $341,x
  rts
  
alive: 
  lda $340,x
  beq nocoll
  inc $f1
nocoll:
  lda #7
  sta $340,x
  lda #$c
  sta $33f,x
  sta $341,x

kchk:
  lda $ff
  beq nkey
  ldx #0
  stx $ff
                             
  and #1  
  bne way
  dec $f0
  dec $f0
way:
  inc $f0
  
  lda $f0 
  cmp #1 
  bpl nleft
  inc $f0
nleft:
  cmp #$1f
  bmi nkey
  dec $f0

nkey:
  lda #0
  sta $ff
  rts

rstlevel: ;------------------------------------

  ldx #0   ; easy
  stx $d3  ; store level
  jmp setlevel

inclevel: ;------------------------------------

  ldx $d3
  cpx #3  ; max level reached?
  beq rstlvlcntr
  inx
  stx $d3

setlevel: ;------------------------------------

  lda freqtab,x
  sta $d4  ; freqency of the trees
  lda colortab,x
  sta $d5  ; color of the trees

rstlvlcntr:
  lda #0
  sta $d6
  lda #2   ; level change speed (higher=slower)
  sta $d7
  
  rts
  
; level data ----------------------------------

freqtab:
  dcb 22,17,12,7
colortab:
  dcb $5,$d,$8,$4

nexttree: ;------------------------------------

  lda $fe
  lsr
  lsr
  lsr
  
  clc
  adc #2
  cmp #30
  bmi painttree
  rts

painttree:
  tax
  lda $d5
  sta $600,x  ; off-screen
  
  sta $61f,x  ; line 2
  sta $620,x
  sta $621,x
  
  sta $63e,x  ; line 3
  sta $63f,x
  sta $640,x
  sta $641,x
  sta $642,x
  
  sta $660,x  ; line 4
  rts
  
scroll: ;--------------------------------------

  ldx #$1f
scyc:
  lda $220,x
  sta $200,x
  lda $240,x
  sta $220,x
  lda $260,x
  sta $240,x
  lda $280,x
  sta $260,x
  lda $2a0,x
  sta $280,x
  lda $2c0,x
  sta $2a0,x
  lda $2e0,x
  sta $2c0,x
  lda $300,x
  sta $2e0,x
  
  lda $320,x
  sta $300,x
  lda $340,x
  sta $320,x
  lda $360,x
  sta $340,x
  lda $380,x
  sta $360,x
  lda $3a0,x
  sta $380,x
  lda $3c0,x
  sta $3a0,x
  lda $3e0,x
  sta $3c0,x
  lda $400,x
  sta $3e0,x
  
  lda $420,x
  sta $400,x
  lda $440,x
  sta $420,x
  lda $460,x
  sta $440,x
  lda $480,x
  sta $460,x
  lda $4a0,x
  sta $480,x
  lda $4c0,x
  sta $4a0,x
  lda $4e0,x
  sta $4c0,x
  lda $500,x
  sta $4e0,x
  
  lda $520,x
  sta $500,x
  lda $540,x
  sta $520,x
  lda $560,x
  sta $540,x
  lda $580,x
  sta $560,x
  lda $5a0,x
  sta $580,x
  lda $5c0,x
  sta $5a0,x
  lda $5e0,x
  sta $5c0,x
 
  ; 4-line off-screen buffer
  lda $600,x 
  sta $5e0,x
  lda $620,x
  sta $600,x
  lda $640,x
  sta $620,x
  lda $660,x
  sta $640,x
  lda #0      ; erase 4th line
  sta $660,x

  dex 
  bmi scycq
  jmp scyc
scycq:
  rts

delay: ;---------------------------------------

; remark: align to your machine/taste

dlyx:
  ldy $d0
dlyy:  
  dey
  bne dlyy
  dex
  bne dlyx
  rts

gdelay:
  rts  ; yep
  ldx $d1 
  jmp delay

cdelay:
  ldx $d2
  jmp delay

