
; Dust Ultimate Game Library (DUGL)
;   Copyright (C) 2025  Fakhri Feki
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <https://www.gnu.org/licenses/>.
;
;    contact: libdugl(at)hotmail.com
;=============================================================================


SetCurBMFont:
    ARG PSrcBMFONT, 4

            MOV         EAX,[EBP+PSrcBMFONT]
            MOV         ECX,BMFONTOctaDQSize / 2
            OR          EAX,EAX
            MOV         EDX,CurDBMFONT
            JZ          .NotSet
.BcCopyCurBMF:
            MOVDQA      xmm0,[EAX+16*0]
            MOVDQA      xmm1,[EAX+16*6]
            MOVDQA      xmm2,[EAX+16*1]
            MOVDQA      xmm3,[EAX+16*5]
            MOVDQA      xmm4,[EAX+16*2]
            MOVDQA      [EDX+16*0],xmm0
            MOVDQA      xmm5,[EAX+16*4]
            MOVDQA      [EDX+16*6],xmm1
            MOVDQA      xmm6,[EAX+16*7]
            MOVDQA      [EDX+16*1],xmm2
            MOVDQA      xmm7,[EAX+16*3]

            MOVDQA      [EDX+16*5],xmm3
            MOVDQA      [EDX+16*2],xmm4
            MOVDQA      xmm0,[EAX+16*08] ; 2
            MOVDQA      [EDX+16*4],xmm5
            MOVDQA      xmm1,[EAX+16*14] ; 2
            MOVDQA      [EDX+16*7],xmm6
            MOVDQA      xmm2,[EAX+16*09] ; 2
            MOVDQA      [EDX+16*3],xmm7

            MOVDQA      xmm3,[EAX+16*13] ; 2
            MOVDQA      xmm4,[EAX+16*10] ; 2
            MOVDQA      [EDX+16*08],xmm0 ; 3
            MOVDQA      xmm5,[EAX+16*12] ; 2
            MOVDQA      [EDX+16*14],xmm1 ; 3
            MOVDQA      xmm6,[EAX+16*15] ; 2
            MOVDQA      [EDX+16*09],xmm2 ; 3
            MOVDQA      xmm7,[EAX+16*11] ; 2

            MOVDQA      [EDX+16*13],xmm3 ; 3
            MOVDQA      [EDX+16*10],xmm4 ; 3
            MOVDQA      [EDX+16*12],xmm5 ; 3
            MOVDQA      [EDX+16*15],xmm6 ; 3
            MOVDQA      [EDX+16*11],xmm7 ; 3

            DEC         ECX
            LEA         EAX,[EAX+16*16]
            LEA         EDX,[EDX+16*16]
            JNZ         .BcCopyCurBMF

            MOVDQA      xmm0,[EAX]
            MOVDQA      xmm1,[EAX+16]
            MOVDQA      [EDX],xmm0,
            MOVDQA      [EDX+16],xmm1

.NotSet:
    RETURN

; PUT Bitmap character in SrcSurf into CurSurf at (BMCharsRendX, BMCharsRendY)  and (ECX, EDX)
;*****************

%macro  @PutBMChar16 0

            MOV         EAX,ECX
            MOV         EBX,EDX

; --- compute Put coordinates of the View inside the Surf
; EAX: MaxX, EBX; MaxY, ECX: MinX, EDX: MnY
            ADD         EAX,[SMaxX] ; EAX = PutMaxX
            ADD         ECX,[SMinX] ; ECX = PutMinX
            ADD         EBX,[SMaxY] ; EBX = PutMaxY
            ADD         EDX,[SMinY] ; EDX = PutMinY

; InView inside (MinX, MinY, MaxX, MaxY)
            CMP         EAX,[MinX]
            JL          %%PasPutSurf
            CMP         EBX,[MinY]
            JL          %%PasPutSurf
            CMP         ECX,[MaxX]
            JG          %%PasPutSurf
            CMP         EDX,[MaxY]
            JG          %%PasPutSurf

            CMP         EAX,[MaxX]
            PSHUFLW     xmm0,[SMask],0
            PUNPCKLQDQ  xmm0,xmm0
            CMOVG       EAX,[MaxX]
            CMP         EBX,[MaxY]
            MOVDQA      [DQ16Mask],xmm0
            MOV         [PutSurfMaxX],EAX
            CMOVG       EBX,[MaxY]
            CMP         ECX,[MinX]
            MOV         [PutSurfMaxY],EBX
            CMOVL       ECX,[MinX]
            CMP         EDX,[MinY]
            MOV         [PutSurfMinX],ECX
            CMOVL       EDX,[MinY]
            MOV         [PutSurfMinY],EDX
; --- compute Put coordinates of the entire Surf
; EAX: MaxX, EBX; MaxY, ECX: MinX, EDX: MnY
            MOV         EAX,[BMCharsRendX]
            MOV         EBX,[BMCharsRendY]
            MOV         ECX,EAX
            MOV         EDX,EBX
            MOV         EDI,[SOrgX]

            ADD         EAX,[SResH]
            SUB         ECX,EDI ; MinX = ECX = posXPut - SOrgX
            SUB         EAX,EDI
            DEC         EAX         ; MaxX = EAX = posXPut + (SResH -1) - SOrgX

            MOV         EDI,[SOrgY]
            ADD         EBX,[SResV]
            SUB         EDX,EDI ; MinX = ECX = posXPut - SOrgX
            SUB         EBX,EDI
            DEC         EBX         ; MaxX = EAX = posXPut + (SResH -1) - SOrgX
%%FInvVtPut:
;-----------------------------------------------
            CMP         EAX,[PutSurfMaxX]
            JG          %%PutSurfClip
            CMP         EBX,[PutSurfMaxY]
            JG          %%PutSurfClip
            CMP         ECX,[PutSurfMinX]
            JL          %%PutSurfClip
            CMP         EDX,[PutSurfMinY]
            JL          %%PutSurfClip
; PutSurf not Clipped *****************************
            MOV         EBP,[SResV]
            XOR         EAX,EAX
            MOV         ESI,[Srlfb] ; ESI : start copy adress

            MOV         EDI,EBX ; PutMaxY or the top left corner
            IMUL        EDI,[NegScanLine]
            LEA         EDI,[EDI+ECX*2] ; += PutMinX*2 top left croner
            MOV         EDX,[ScanLine]
            ADD         EDI,[vlfb]
            SUB         EDX,[SScanLine] ; EDX : dest adress plus
            MOV         [Plus2],EDX

            MOV         EDX,[SResH]
            MOV         [Plus],EAX

%%PutSurf:
            XOR         ECX,ECX
%%BcPutSurf:
            MOV         EBX,EDX
%%BcStBAv:
            TEST        EDI,6   ; dword aligned ?
            JZ          %%FPasStBAv
            MOV         AX,[ESI]
            CMP         AX,[DQ16Mask]
            LEA         ESI,[ESI+2]
            JZ          %%PasStBAv
            STOSW
            DEC         EBX
            JZ          %%FinSHLine
            JMP         %%BcStBAv

%%PasStBAv:
            DEC         EBX
            LEA         EDI,[EDI+2]
            JZ          %%FinSHLine
            JMP         %%BcStBAv
%%FPasStBAv:
;--------
            TEST        EDI, 8
            JZ          %%PasStQAv
            CMP         EBX,BYTE 4
            JL          %%StBAp
            MOVQ        xmm2,[ESI]
            MOVQ        xmm1,xmm2
            MOVQ        xmm0,xmm2
            MOVQ        xmm4,[EDI]

            PCMPEQW     xmm2,[DQ16Mask]
            PCMPEQW     xmm1,[DQ16Mask]
            PANDN       xmm2,xmm0
            PAND        xmm4,xmm1
            POR         xmm2,xmm4

            SUB         EBX, BYTE 4
            MOVQ        [EDI],xmm2
            LEA         ESI,[ESI+8]
            LEA         EDI,[EDI+8]
%%PasStQAv:
;-------
            SHLD        ECX,EBX,29
            JZ          %%StBAp
;ALIGN 4
%%StoSSE:
            MOVDQU      xmm2,[ESI]
            MOVDQA      xmm4,[EDI]
            MOVDQA      xmm1,xmm2
            MOVDQA      xmm0,xmm2

            PCMPEQW     xmm1,[DQ16Mask]
            PCMPEQW     xmm2,[DQ16Mask]
            PAND         xmm4,xmm1
            PANDN       xmm2,xmm0
            POR         xmm2,xmm4
            DEC         ECX
            MOVDQA      [EDI],xmm2
            LEA         ESI,[ESI+16]
            LEA         EDI,[EDI+16]
            JNZ         %%StoSSE
%%StBAp:
            AND         BL,BYTE 7
            JZ          %%FinSHLine
%%StQAp:
            TEST        BL,4
            JZ          %%PasStQAp
            MOVQ        xmm2,[ESI]
            MOVQ        xmm1,xmm2
            MOVQ        xmm0,xmm2
            MOVQ        xmm4,[EDI]

            PCMPEQW     xmm2,[DQ16Mask]
            PCMPEQW     xmm1,[DQ16Mask]
            PANDN       xmm2,xmm0
            PAND        xmm4,xmm1
            POR         xmm2,xmm4

            MOVQ        [EDI],xmm2
            LEA         ESI,[ESI+8]
            LEA         EDI,[EDI+8]
%%PasStQAp:
            AND         BL,BYTE 3
            JZ          SHORT %%FinSHLine

%%BcStBAp:
            MOV         AX,[ESI]
            CMP         AX,[DQ16Mask]
            LEA         ESI,[ESI+2]
            JZ          %%BPasStBAp
            DEC         BL
            STOSW
            JNZ         %%BcStBAp
            JMP         SHORT %%FinSHLine
%%BPasStBAp:
            DEC         BL
            LEA         EDI,[EDI+2]
            JNZ         %%BcStBAp
%%PasStBAp:
%%FinSHLine:
            ADD         EDI,[Plus2]
            ADD         ESI,[Plus]
            DEC         EBP
            JNZ         %%BcPutSurf

            JMP         %%PasPutSurf

%%PutSurfClip:
; PutSurf Clipped **********************************************
            XOR         EDI,EDI   ; Y Fin Source
            XOR         ESI,ESI   ; X deb Source

            MOV         EBP,[PutSurfMinX]
            CMP         ECX,EBP ; CMP minx, MinX
            JGE         %%PsInfMinX   ; XP1<MinX
            MOV         ESI,EBP
            SUB         ESI,ECX ; ESI = MinX - XP2
            MOV         ECX,EBP
%%PsInfMinX:
            MOV         EBP,[PutSurfMaxY]
            CMP         EBX,EBP ; cmp maxy, MaxY
            JLE         %%PsSupMaxY   ; YP2>MaxY
            MOV         EDI,EBP
            NEG         EDI
            ;MOV        [YP2],EBP
            ADD         EDI,EBX
            MOV         EBX,EBP
%%PsSupMaxY:
            MOV         EBP,[PutSurfMinY]
            CMP         EDX,EBP      ; YP1<MinY
            JGE         %%PsInfMinY
            MOV         EDX,EBP
%%PsInfMinY:
            MOV         EBP,[PutSurfMaxX]
            CMP         EAX,EBP      ; XP2>MaxX
            JLE         %%PsSupMaxX
            MOV         EAX,EBP
%%PsSupMaxX:
            SUB         EAX,ECX      ; XP2 - XP1
            MOV         EBP,[SScanLine]
            LEA         EAX,[EAX*2+2]
            SUB         EBP,EAX  ; EBP = SResH-DeltaX, PlusSSurf
            MOV         [Plus],EBP
            MOV         EBP,EBX
            SUB         EBP,EDX      ; YP2 - YP1
            INC         EBP   ; EBP = DeltaY
            MOV         EDX,[ScanLine]
            MOVD        xmm0,EAX ; = DeltaX
            SUB         EDX,EAX ; EDX = ResH-DeltaX, PlusDSurfS
            MOV         [Plus2],EDX
            IMUL        EDI,[SScanLine]
            XOR         EAX,EAX
            LEA         EDI,[EDI+ESI*2]
            ADD         EDI,[Srlfb]
            MOV         ESI,EDI

            MOV         EDI,EBX ; putSurf MaxY
            IMUL        EDI,[NegScanLine]
            LEA         EDI,[EDI+ECX*2] ; + XP1*2 as 16bpp
            PSRLD       xmm0,1 ; (deltaX*2) / 2
            ADD         EDI,[vlfb]

            MOVD        EDX,xmm0  ; DeltaX
            ADD         [Plus],EAX
            JMP         %%PutSurf

%%PasPutSurf:

%endmacro


ALIGN 4
OutTextBM16:
    ARG PBMStr, 4

            PUSH        ESI
            PUSH        EDI
            PUSH        EBX

            MOV         EDX,[EBP+PBMStr]
            XOR         EAX,EAX
            OR          EDX,EDX
            JZ          .End              ; NULL pointer ?
            OR          AL,[EDX]
            JNZ         .SetSrcSurfAndRend   ; not empty string ?
            JMP         .End

.RendStrLoop:
            PUSH        EDX
            MOV         ECX,[BMCharsXOffset+EAX*4]
            MOV         EDX,[BMCharY]
            ADD         ECX,[BMCharX]                ; = CurDBMFONT.CharX + myBMFont->CharsXOffset[*str];
            ADD         EDX,[BMCharsGHeight]
            MOV         [BMCharsRendX],ECX
            SUB         EDX,[BMCharsHeight+EAX*4]
            SUB         EDX,[BMCharsYOffset+EAX*4]
            MOV         [BMCharsRendY],EDX                 ; BMCharsRendY = BMCharY + CurDBMFONT.CharsGHeight - (CurDBMFONT.CharsHeight[*str] + CurDBMFONT.CharsYOffset[*str]);
            @PutBMChar16
            MOV         EAX,[BMCharCurChar]           ; current rendered char
            POP         EDX                           ; restore str pointer
            MOV         EBP,[BMCharsPlusX+EAX*4]
            INC         EDX                           ; increment str pointer
            XOR         AL,AL
            ADD         [BMCharX],EBP                 ; CurDBMFONT.CharX += CurDBMFONT.CharsPlusX[*str]
            OR          AL,[EDX]                      ; end of the string ?
            JZ          SHORT .End
            CMP         AL,[BMCharCurChar]
            JE          SHORT .NotSetSrcSurf
.SetSrcSurfAndRend:
            MOV         ESI,[BMCharsSSurfs+EAX*4]
            MOV         EDI,SrcSurf
            CopySurfDA  ; copy surf
            MOV         [BMCharCurChar],EAX
.NotSetSrcSurf:
            JMP         .RendStrLoop

.End:
            POP         EBX
            POP         EDI
            POP         ESI

    RETURN

