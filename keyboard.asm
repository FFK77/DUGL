;   Dust Ultimate Game Library (DUGL)
;   Copyright (C) 2023  Fakhri Feki
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
;    contact: libdugl@hotmail.com
;=============================================================================

%include "PARAM.asm"

; GLOBAL Function*************************************************************
;*** Keyboard
GLOBAL _iUninstallKeyboard,_IsKeyDown
GLOBAL _iSetKbMAP,_GetKbMAP,_iDisableCurKbMAP
GLOBAL _iPushKbDownEvent, _iPushKbReleaseEvent
GLOBAL _GetKeyNbElt,_iGetKey,_iClearKeyCircBuff
GLOBAL _GetAsciiNbElt,_iGetAscii,_iClearAsciiCircBuff
GLOBAL _GetTimedKeyNbElt,_GetCurrTimeKeyDown,_iGetTimedKeyDown,_iClearTimedKeyCircBuff

; GLOBAL DATA*****************************************************************
;*** Keyboard
GLOBAL _KbFLAG,_KbApp,_LastKey,_LastAscii,_CurKbMAP, _KbScanEvents

; EXTERN DATA

EXTERN  _DgTime

SECTION .text
ALIGN 32
[BITS 32]

;*** KEYBOARD


_iUninstallKeyboard:
            PUSH        ESI
            PUSH        EDI
            PUSH        EBX

            ; disable current keybmap
            XOR         EAX,EAX
            MOV         [_KbScanEvents],EAX
            MOV         [AsciiCBDeb],EAX
            MOV         [AsciiCBFin],EAX
            MOV         [AsciiNbElt],EAX
            MOV         [_LastAscii],AL
            MOV         [ValidCurKbMAP],EAX

            POP         EBX
            POP         EDI
            POP         ESI
    RET

_IsKeyDown:
    ARG NumKey, 4

            MOVZX       EAX,BYTE [EBP+NumKey]
            MOV         ECX,EAX
            MOV         EDX,EAX
            SHR         ECX,3
            AND         EDX,BYTE 0x7
            MOV         CL,[_KbApp+ECX]
            BT          ECX,EDX
            SETC        AL

    RETURN


_GetTimedKeyNbElt:
            MOV         EAX,[KeyTimeNbElt]
    RET

_iClearTimedKeyCircBuff:
            XOR         EAX,EAX

            ; disable feeding if activated
            MOV         ECX,[_KbScanEvents]
            MOV         [_KbScanEvents],EAX

            MOV         [KeyTimeCBDeb],EAX
            MOV         [KeyTimeCBFin],EAX
            MOV         [KeyTimeNbElt],EAX

            ; restore old kb activation
            MOV         [_KbScanEvents],ECX

    RET

_GetCurrTimeKeyDown:
    ARG TmNumKey, 4

            MOVZX       EAX,BYTE [EBP+TmNumKey]
            MOV         ECX,EAX
            MOV         EDX,EAX
            SHR         ECX,3
            AND         EDX,BYTE 0x7

            MOV         CL,[_KbApp+ECX]
            BT          ECX,EDX
            JC          .KeyDown
            SETC        AL
            JMP         SHORT .End
.KeyDown:
            MOV         EBX,[KeyFrstDownTime+EAX*4]
            MOV         EAX,[_DgTime]
            SUB         EAX,EBX
.End:
    RETURN


_iGetTimedKeyDown:
    ARG PTmKey, 4, PKeyTIME, 4

            PUSH        ESI
            PUSH        EDI
            PUSH        EBX

            XOR         EAX,EAX
            MOV         ESI,[EBP+PTmKey]
            MOV         EDI,[EBP+PKeyTIME]
            MOV         EDX,[KeyTimeNbElt]
            MOV         [ESI],AL   ; key
            MOV         [EDI],EAX  ; keyTIME
            OR          EDX,EDX
            JZ          .CircBuffEmpty

            MOV         ECX,[KeyTimeCBDeb]
            DEC         DWORD [KeyTimeNbElt]
            LEA         EBX,[ECX+1]
            MOV         EDX,[KeyTimeEvents+ECX*4]
            MOV         AL,[KeyTimeKyEvents+ECX]
            AND         EBX,BYTE 0x1f
            MOV         [EDI],EDX  ; keyFLAG
            MOV         [ESI],AL   ; key
            MOV         [KeyTimeCBDeb],EBX

.CircBuffEmpty:
            POP         EBX
            POP         EDI
            POP         ESI
    RETURN

_iGetKey:
    ARG PKey, 4, PKeyFLAG, 4

            PUSH        ESI
            PUSH        EDI
            PUSH        EBX

            XOR         EAX,EAX
            MOV         ESI,[EBP+PKey]
            MOV         EDI,[EBP+PKeyFLAG]
            MOV         EDX,[KeyNbElt]
            MOV         [ESI],AL   ; key
            MOV         [EDI],EAX  ; keyFLAG
            OR          EDX,EDX
            JZ          .CircBuffEmpty

            MOV         ECX,[KeyCBDeb]
            DEC         DWORD [KeyNbElt]
            LEA         EBX,[ECX+1]
            MOV         EDX,[KeyKbFLAG+ECX*4]
            MOV         AL,[KeyCircBuff+ECX]
            AND         EBX,BYTE 0x1f
            MOV         [EDI],EDX  ; keyFLAG
            MOV         [ESI],AL   ; key
            MOV         [KeyCBDeb],EBX

.CircBuffEmpty:
            POP         EBX
            POP         EDI
            POP         ESI
            
    RETURN


_GetKeyNbElt:
            MOV         EAX,[KeyNbElt]
    RET

_iClearKeyCircBuff:
            XOR         EAX,EAX ; Initialisation des vars
            MOV         [KeyCBDeb],EAX
            MOV         [KeyCBFin],EAX
            MOV         [KeyNbElt],EAX
            MOV         [_LastKey],AL
    RET

;-------------------------------------
_iSetKbMAP:
    ARG PSetKM, 4
            PUSH        ESI
            PUSH        EDI
            ;PUSH       EBX

            XOR         EAX,EAX
            MOV         [AsciiCBDeb],EAX
            MOV         [AsciiCBFin],EAX
            MOV         [AsciiNbElt],EAX
            MOV         [_LastAscii],AL
            MOV         ESI,[EBP+PSetKM]
            MOV         EDI,_CurKbMAP
            MOV         ECX,16
            REP         MOVSD
            MOV         [ValidCurKbMAP],BYTE 1

            ;POP        EBX
            POP         EDI
            POP         ESI
    RETURN

_GetKbMAP:
    ARG PGetKM, 4
            PUSH        ESI
            PUSH        EDI

            MOV         ESI,_CurKbMAP
            MOV         EDI,[EBP+PGetKM]
            MOV         ECX,16
            REP         MOVSD

            POP         EDI
            POP         ESI
    RETURN

_iDisableCurKbMAP:
        PUSH        ESI
        PUSH        EDI
        PUSH        EBX

        XOR     EAX,EAX
        CMP     [ValidCurKbMAP],EAX
        JE      .PasExistOthMp
        MOV     [ValidCurKbMAP],EAX
.PasExistOthMp:
        MOV     [AsciiCBDeb],EAX
        MOV     [AsciiCBFin],EAX
        MOV     [AsciiNbElt],EAX
        MOV     [_LastAscii],AL

        POP     EBX
        POP     EDI
        POP     ESI
        RET

_iGetAscii:
    ARG PAscii, 4, PAsciiFLAG, 4
        CMP     DWORD [ValidCurKbMAP],BYTE 0
        JNE     .KbMapActv
        XOR     EDX,EDX
        MOV     EAX,[EBP+PAscii]
        MOV     [EAX],DL
        MOV     EAX,[EBP+PAsciiFLAG]
        MOV     [EAX],EDX
        RETURN
.KbMapActv:
        PUSH        ESI
        PUSH        EDI
        PUSH        EBX
        MOV     ESI,[EBP+PAscii]
        MOV     EDI,[EBP+PAsciiFLAG]
        MOV     EDX,[AsciiNbElt]
        XOR     EAX,EAX
        MOV     [EDI],EAX  ; AsciiFLAG 0
        MOV     [ESI],AL   ; Ascii 0
        OR      EDX,EDX
        JZ      .CircBuffFree
        PUSH        EBX
        MOV     ECX,[AsciiCBDeb]
        DEC     DWORD [AsciiNbElt]
        MOV     EBX,ECX
        MOV     EDX,[AsciiKbFLAG+ECX*4]
        MOV     AL,[AsciiCircBuff+ECX]
        MOV     [EDI],EDX  ; AsciiFLAG
        MOV     [ESI],AL   ; Ascii
        INC     EBX
        AND     EBX,BYTE 0x1f
        MOV     [AsciiCBDeb],EBX
        POP     EBX
.CircBuffFree:
        POP     EBX
        POP     EDI
        POP     ESI
        RETURN


_GetAsciiNbElt:
        MOV     EAX,[AsciiNbElt]
        RET

_iClearAsciiCircBuff:
        XOR     EAX,EAX ; Initialisation des vars
        MOV     [AsciiCBDeb],EAX
        MOV     [AsciiCBFin],EAX
        MOV     [AsciiNbElt],EAX
        MOV     [_LastAscii],AL
        RET

_iPushKbDownEvent:
    ARG KeyCodeDownEvent, 4
        PUSH    ESI
        MOV     EAX,[EBP+KeyCodeDownEvent]
        PUSH    EDI
        AND     EAX,BYTE 0xFF
        PUSH    EBX

        MOV     [_LastKey],AL
        XOR     EBX,EBX
        MOV     EDX,EAX
        MOV     ECX,EAX
        AND     EDX,BYTE 0x7
        SHR     ECX,3
        BTS     EBX,EDX

        TEST    BL,[_KbApp+ECX]
        JNZ     .AlreadyApp
        MOV     EDX,[_DgTime]
        OR      [_KbApp+ECX],BL
        MOV     [KeyFrstDownTime+EAX*4],EDX
.AlreadyApp:
        CALL    TraitApp
        CALL    TraitKey
        CALL    TraitAscii

        POP     EBX
        POP     EDI
        POP     ESI
        RETURN

_iPushKbReleaseEvent:
    ARG KeyCodeReleaseEvent, 4
        PUSH    ESI
        MOV     EAX,[EBP+KeyCodeReleaseEvent]
        PUSH    EDI
        AND     EAX,BYTE 0xFF
        PUSH    EBX

        XOR     EBX,EBX
        MOV     EDX,EAX
        MOV     ECX,EAX
        MOV     BYTE [_LastKey],BL
        AND     EDX,BYTE 0x7
        SHR     ECX,3
        BTS     EBX,EDX
        NOT     EBX

        AND     [_KbApp+ECX],BL
        CALL    TraitTimeKey
        CALL    TraitRel

        POP     EBX
        POP     EDI
        POP     ESI
        RETURN



;---- Traitement Ascii ---------------***************************************
;****************************************************************************

        struc NormKeyb
.MaskYes        resd    1
.MaskNo         resd    1
.DefActiv       resd    1
.NbAscii        resd    1
.Ptr            resd    1
.Size
        endstruc

        struc PrefixKeyb
.MaskYes        resd    1
.MaskNo         resd    1
.DefActiv       resd    1
.NbKeybNorm     resd    1
.TabNormKeyb    resd    1
.resv2          resd    1
.DefaultAscii   resb    1
.code           resb    1
.resv           resb    2
.Size
        endstruc

TraitAscii:
        PUSH        EAX
        CMP     DWORD [ValidCurKbMAP],0
        JE      .PasTraitAscii ;-----------------------

        ; test si Code Key Ascii ----------
        MOV     ESI,TbNonAscii
        MOV     ECX,[NbKbNonAscii]
        XOR     EDX,EDX
        MOV     DL,AL
.BcSrNonAscii:  LODSB
        CMP     AL,DL
        JE      .PasTraitAscii
        DEC     ECX
        JNZ     .BcSrNonAscii
        MOV     AL,DL

        CMP     DWORD [CurPrefixKb],0
        JNE     .TraitPrefix

;***************************************************************************
;-DEB---------- Traitement Normal ------------------------------------------
.NormScan:
        MOV     ECX,[NbNrmKb]
        XOR     EAX,EAX
        MOV     EDI,[TabNrmKb]
        OR      ECX,ECX
        JZ      .PasAddAscii
.BcScanNormKb:
        MOV     EBX,[_KbFLAG]
        TEST    EBX,[EDI+NormKeyb.MaskNo]
        JNZ     .PasScanNormKb

        AND     EBX,[EDI+NormKeyb.MaskYes]
        MOV     EBP,[EDI+NormKeyb.DefActiv]
.BcTestMYes:    TEST        EBX,1
        JZ      .PasIncActiv
        INC     EBP
.PasIncActiv:   SHR     EBX,1
        JNZ     .BcTestMYes
        TEST        EBP,1
        JZ      .PasScanNormKb
.PasTestKbMYes:
        CALL        ScanNormKb
        OR      EAX,EAX
        JNZ     .FinScanNormKb
.PasScanNormKb:
        ADD     EDI,NormKeyb.Size
        DEC     ECX
        JNZ     .BcScanNormKb
.FinScanNormKb:
        OR      EAX,EAX
        JZ      .PasAddAscii
        CALL    AddAsciiCB
        JMP     .PasTraitAscii
.PasAddAscii:
        ;--- Test si Bouton Prefix ---------------------------------
        MOV     ECX,[NbPrefixKb]
        MOV     EDI,[TabPrefixKb]
        OR      ECX,ECX
        JZ      .PasTraitAscii
.BcScanPrefix:
        CMP     DL,[EDI+PrefixKeyb.code]
        JNE     .PasTstPrefix
        MOV     EBX,[_KbFLAG]
        TEST    EBX,[EDI+PrefixKeyb.MaskNo]
        JNZ     .PasTstPrefix
        AND     EBX,[EDI+PrefixKeyb.MaskYes]
        MOV     EBP,[EDI+PrefixKeyb.DefActiv]
.BcTestMYes2:
        TEST        EBX,1
        JZ      .PasIncActiv2
        INC     EBP
.PasIncActiv2:
        SHR     EBX,1
        JNZ     .BcTestMYes2
        TEST    EBP,1
        JZ      .PasTstPrefix
        MOV     [CurPrefixKb],EDI
        JMP     .PasTraitAscii
.PasTstPrefix:
        ADD     EDI,PrefixKeyb.Size
        DEC     ECX
        JNZ     .BcScanPrefix

        JMP     .PasTraitAscii

;-FIN---------- Traitement Normal ------------------------------------------
;***************************************************************************
.TraitPrefix:
;-----------------------------------------------
        XOR     EAX,EAX
        MOV     ESI,[CurPrefixKb]
        MOV     [CurPrefixKb],EAX
        MOV     ECX,[ESI+PrefixKeyb.NbKeybNorm]
        OR      ECX,ECX
        JZ      .PPasAddAscii
        MOV     EDI,[ESI+PrefixKeyb.TabNormKeyb]
        MOV     DH,[ESI+PrefixKeyb.DefaultAscii]
.PBcScanNormKb:
        MOV     EBX,[_KbFLAG]
        TEST        EBX,[EDI+NormKeyb.MaskNo]
        JNZ     .PPasScanNormKb

        AND     EBX,[EDI+NormKeyb.MaskYes]
        MOV     EBP,[EDI+NormKeyb.DefActiv]
.PBcTestMYes:   TEST        EBX,1
        JZ      .PPasIncActiv
        INC     EBP
.PPasIncActiv:  SHR     EBX,1
        JNZ     .PBcTestMYes
        TEST        EBP,1
        JZ      .PPasScanNormKb
.PPasTestKbMYes:
        CALL        ScanNormKb
        OR      EAX,EAX
        JNZ     .PFinScanNormKb
.PPasScanNormKb:
        ADD     EDI,NormKeyb.Size
        DEC     ECX
        JNZ     .PBcScanNormKb
.PFinScanNormKb:
        OR      EAX,EAX
        JZ      .PPasAddAscii
        CALL        AddAsciiCB
        JMP     .PasTraitAscii
.PPasAddAscii:
        ;--- Test si Bouton Prefix II-------------------------------
        MOV     ECX,[NbPrefixKb]
        MOV     EDI,[TabPrefixKb]
.BcScanPrefix3:
        CMP     DL,[EDI+PrefixKeyb.code]
        JNE     .PasTstPrefix3
        MOV     EBX,[_KbFLAG]
        TEST    EBX,[EDI+PrefixKeyb.MaskNo]
        JNZ     .PasTstPrefix3
        AND     EBX,[EDI+PrefixKeyb.MaskYes]
        MOV     EBP,[EDI+PrefixKeyb.DefActiv]
.BcTestMYes3:   TEST        EBX,1
        JZ      .PasIncActiv3
        INC     EBP
.PasIncActiv3:  SHR     EBX,1
        JNZ     .BcTestMYes3
        TEST        EBP,1
        JZ      .PasTstPrefix3
        XOR     EAX,EAX
        MOV     AL,DH
        PUSH        EDI
        CALL        AddAsciiCB
        XOR     EAX,EAX
        POP     EDI
        MOV     AL,[EDI+PrefixKeyb.DefaultAscii]
        CALL        AddAsciiCB

        JMP     .PasTraitAscii
.PasTstPrefix3:
        ADD     EDI,PrefixKeyb.Size
        DEC     ECX
        JNZ     .BcScanPrefix3
        ; si aucun alors ajout ascii defaut -----------------------
        XOR     EAX,EAX
        MOV     AL,DH
        PUSH    EDX
        CALL    AddAsciiCB
        POP     EDX
        JMP     .NormScan ; et cherche normal ascii -------
;-------------------------------------------------------------------

.PasTraitAscii:
        POP     EAX

        RET

;IN  : EDX code butt,EDI Ptr NrmKb
;OUT : EAX Ascii ou 0 ------------

ScanNormKb:
        PUSH    ECX
        PUSH    ESI
        MOV     ECX,[EDI+NormKeyb.NbAscii]
        MOV     ESI,[EDI+NormKeyb.Ptr]
        XOR     EAX,EAX
.BcScan:
        LODSW
        CMP     AL,DL
        JE      .TrouvAscii
        DEC     ECX
        JNZ     .BcScan
.PasTrouv:
        XOR     EAX,EAX
        POP     ESI
        POP     ECX
        RET     ; Pas trouve
.TrouvAscii:
        XOR     AL,AL
        MOV     AL,AH
        POP     ESI
        POP     ECX

        RET

;---------------------------------
AddAsciiCB:
        PUSH    EAX
        OR      AL,AL
        JZ      .FinAddAsc
        CMP     DWORD [AsciiNbElt],0
        JE      .TrtFreeCBuff
        MOV     ECX,[AsciiCBFin]
        MOV     EBX,[AsciiNbElt]
        LEA     EDX,[ECX+1]
        MOV     ESI,[_KbFLAG]
        MOV     [AsciiCircBuff+ECX],AL
        MOV     [AsciiKbFLAG+ECX*4],ESI

        AND     EDX,BYTE 0x1f
        CMP     EDX,[AsciiCBDeb]
        JNE     .PasSature

        JMP     SHORT .Sature
.PasSature:
        INC     EBX
        MOV     [AsciiCBFin],EDX
        MOV     [AsciiNbElt],EBX
.Sature:
        JMP     SHORT .FinAddAsc
.TrtFreeCBuff:
        MOV     ECX,[AsciiCBDeb]
        XOR     EBX,EBX
        LEA     EDX,[ECX+1]
        MOV     ESI,[_KbFLAG]
        MOV     [AsciiCircBuff+ECX],AL
        MOV     [AsciiKbFLAG+ECX*4],ESI
        AND     EDX,BYTE 0x1f
        OR      EBX,BYTE 1
        MOV     [AsciiCBFin],EDX
        MOV     [AsciiNbElt],EBX
.FinAddAsc:
        POP     EAX
        RET

;-------------------------------------***************************************
;****************************************************************************
;       struc TimedKeyDownEvent
;.Time      resd    1
;.KeyCode   resb    1
;.Size
;       endstruc

TraitTimeKey:
        OR      EAX,EAX
        JZ      .FinTimeTrtKey ; sature
        CMP     DWORD [KeyTimeNbElt],32
        JGE     .FinTimeTrtKey
        MOV     ESI,[_DgTime]
        MOV     ECX,[KeyTimeCBFin]
        SUB     ESI,[KeyFrstDownTime+EAX*4]
        JZ      .NoKbTime
        MOV     ECX,[KeyTimeCBFin]
        MOV     EBX,[KeyTimeNbElt]
        LEA     EDX,[ECX+1]
        MOV     DWORD [KeyFrstDownTime+EAX*4],ESI
        MOV     [KeyTimeEvents+ECX*4],ESI
        AND     EDX,BYTE 0x1f ; rotate value
        MOV     [KeyTimeKyEvents+ECX],AL
        INC     EBX
        MOV     [KeyTimeCBFin],EDX
        MOV     [KeyTimeNbElt],EBX
        JMP     SHORT .FinTimeTrtKey
.NoKbTime:
        MOV     DWORD [KeyFrstDownTime+EAX*4],0
.FinTimeTrtKey:
        RET

TraitKey:
        OR      EAX,EAX
        MOV     EBX,[KeyNbElt]
        JZ      .FinTrtKey
        CMP     EBX,BYTE 32
        JGE     .FinTrtKey ; satured
        MOV     ECX,[KeyCBFin]
        MOV     ESI,[_KbFLAG]
        LEA     EDX,[ECX+1]
        MOV     [KeyCircBuff+ECX],AL
        MOV     [KeyKbFLAG+ECX*4],ESI
        AND     EDX,BYTE 0x1f
        INC     EBX
        MOV     [KeyCBFin],EDX
        MOV     [KeyNbElt],EBX
.FinTrtKey:
        RET
;-------------------------------------
TraitApp:
        PUSH    EAX

        XOR     EDX,EDX
        MOV     DL,AL
        MOV     ECX,[NbKbFLAGLock] ; traite lock ------------
        MOV     ESI,KbFLAGLock
.BcTrtLock:
        LODSD
        CMP     EAX,EDX
        JE      .TrouveLock
        DEC     ECX
        LEA     ESI,[ESI+8]
        JNZ     .BcTrtLock
        JMP     SHORT .FinTrtLock
.TrouveLock:
        LODSD
        TEST        [_KbFLAG],EAX
        JNZ     .PasInvLock
        LODSD
        XOR     [_KbFLAG],EAX
        ;CALL       UpDateLEDS
.PasInvLock:
.FinTrtLock:
;--Deb Test INS************--
        MOV     ECX,[NbMskNoYsDefAct]
        MOV     ESI,MskNoYsDefAct

.BcTstIns:
        LEA     ESI,[ECX-1]
        IMUL    ESI,20
        ADD     ESI,MskNoYsDefAct

        LODSD
        CMP     EAX,EDX
        JNE     .PasTstIns
        MOV     EBX,[_KbFLAG]
        LODSD
        TEST        EBX,EAX   ; MaskNo
        JNZ     .PasTstIns
        LODSD
        AND     EBX,EAX   ; MaskYes
        LODSD
        MOV     EBP,EAX   ; DefActiv
.PBcTestMYes:
        TEST        EBX,1
        JZ      .PPasIncActiv
        INC     EBP
.PPasIncActiv:
        SHR     EBX,1
        JNZ     .PBcTestMYes
        LODSD
        TEST    EBP,1
        JZ      .FinTstIns
        XOR     [_KbFLAG],EAX
.PasInvIns:
        JMP     SHORT .FinTstIns
.PasTstIns:
        DEC     ECX
        JNZ     .BcTstIns
.FinTstIns:
;--Fin Test INS************--
        MOV     ECX,[NbKbFLAGAppScan] ; traite Norm ---------
        MOV     ESI,KbFLAGAppScan
.BcTrtNorm:
        LODSD
        CMP     EAX,EDX
        JE      .TrouveNorm
        DEC     ECX
        LEA     ESI,[ESI+4]
        JNZ     .BcTrtNorm
        JMP     SHORT .FinTrtNorm
.TrouveNorm:
        LODSD
        OR      [_KbFLAG],EAX
        DEC     ECX
        JNZ     .BcTrtNorm
.FinTrtNorm:
        POP     EAX
        RET


TraitRel:
        XOR     EDX,EDX
        MOV     DL,AL
        MOV     ECX,[NbKbFLAGSpRel] ; traite Sp -------------
        MOV     ESI,KbFLAGSpRel
.BcTrtSp:
        LODSD
        CMP     EAX,EDX
        JE      .TrouveSp
        DEC     ECX
        LEA     ESI,[ESI+8]
        JNZ     .BcTrtSp
        JMP     SHORT .FinTrtSp
.TrouveSp:
        LODSD
        TEST        [_KbFLAG],EAX
        JNZ     .PasDesacSp
        LODSD
        AND     [_KbFLAG],EAX
.PasDesacSp:
.FinTrtSp:
        MOV     ECX,[NbKbFLAGRel] ; traite Norm -------------
        MOV     ESI,KbFLAGRel
.BcTrtNorm:
        LODSD
        CMP     EAX,EDX
        JE      .TrouveNorm
        DEC     ECX
        LEA     ESI,[ESI+4]
        JNZ     .BcTrtNorm
        JMP     SHORT .FinTrtNorm
.TrouveNorm:
        LODSD
        AND     [_KbFLAG],EAX
        DEC     ECX
        JNZ     .BcTrtNorm
.FinTrtNorm:

        RET

FinKbLockCode:;****************************************************************

SECTION .data
ALIGN 32
;*** KEYBOARD
; test KbFLAG avec 2em val si zero alors inverse etat avec XOR 3em VAL
NbKbFLAGLock    DD  3
KbFLAGLock:     DD  0x46,0x1000,0x10        ;SCROLL_ACT
                DD  0x45,0x2000,0x20    ;NUM_ACT
                DD  0x3a,0x4000,0x40    ;CAPS_ACT
; 2� Mask Yes, 3� Mask No, 4� Def Activ
NbMskNoYsDefAct DD  2
MskNoYsDefAct:  DD  0xd2,0x0000800C,0x80000000,1,0x80 ;INS_ACT
                DD  0x52,0x0080800C,0x80000020,1,0x80 ;PAD_INS_ACT

NbKbFLAGAppScan DD  30
KbFLAGAppScan:  DD  0x36,0x00000001,    0x2a,0x00000002; RG_SH, LF_SH
                DD  0x1d,0x00000004,    0x9d,0x00000004; CTRL
                DD  0x38,0x00000008,    0xb8,0x00000008; ALT
                DD  0x1d,0x00000100,    0x38,0x00000200; LF_CTRL,LF_ALT
                DD  0xb7,0x00000400            ; SYS_REQ
                DD  0x46,0x00001000,    0x45,0x00002000; SCR, NUM
                DD  0x3a,0x00004000,    0xd2,0x00008000; CAPS, INS
                DD  0x0f,0x00010000,    0x1c,0x00020000; TAB, ENTER
                DD  0x39,0x00040000,    0xc8,0x00080000; SPACE, UP
                DD  0xd0,0x00100000,    0xcd,0x00200000; DOWN, RIGHT
                DD  0xcb,0x00400000,    0x52,0x00800000; LEFT, PAD_INS
                DD  0x9d,0x01000000,    0xb8,0x02000000; RG_CTR, RG_ALT
                DD  0xc9,0x04000000,    0xd1,0x08000000; PG_UP, PG_DWN
                DD  0xc7,0x10000000,    0xcf,0x20000000; BEG, END
                DD  0xd3,0x40000000            ; SUPP
                DD  0x36,0x80000000,    0x2a,0x80000000; SHIFT

; test KbFLAG avec 2em val si zero alors desactive bit avec AND 3em VAL
NbKbFLAGSpRel   DD  6
KbFLAGSpRel:    DD  0x1d,0x1000000,~0x4         ;LF_CTRL
                DD  0x38,0x2000000,~0x8     ;LF_ALT
                DD  0x9d,0x100,~0x4         ;RG_CTRL
                DD  0xb8,0x200,~0x8         ;RG_ALT
                DD  0x36,0x2,~(0x80000000)      ;LF_SH
                DD  0x2a,0x1,~0x80000000        ;RG_SH

NbKbFLAGRel     DD  25
KbFLAGRel:      DD  0x36,~0x00000001,    0x2a,~0x00000002 ;RG_SH, LF_SH
                DD  0x1d,~0x00000100,    0x38,~0x00000200; LF_CTRL,LF_ALT
                DD  0xb7,~0x00000400             ; SYS_REQ
                DD  0x46,~0x00001000,    0x45,~0x00002000; SCR, NUM
                DD  0x3a,~0x00004000,    0xd2,~0x00008000; CAPS, INS
                DD  0x0f,~0x00010000,    0x1c,~0x00020000; TAB, ENTER
                DD  0x39,~0x00040000,    0xc8,~0x00080000; SPACE, UP
                DD  0xd0,~0x00100000,    0xcd,~0x00200000; DOWN, RIGHT
                DD  0xcb,~0x00400000,    0x52,~0x00800000; LEFT, PAD_INS
                DD  0x9d,~0x01000000,    0xb8,~0x02000000; RG_CTR, RG_ALT
                DD  0xc9,~0x04000000,    0xd1,~0x08000000; PG_UP, PG_DWN
                DD  0xc7,~0x10000000,    0xcf,~0x20000000; BEG, END
                DD  0xd3,~0x40000000,    0x0e,~0x80000000; SUPP, BACK

NbKbNonAscii    DD  14
TbNonAscii:     DB  0x36,0x2a,0x1d,0x38, 0xb7,0x46,0x45,0x3a
                DB  0xd2,0x9d,0xb8,0xdb, 0xdc,0xdd,0,0

_KbScanEvents   DD  0

SECTION .bss   ALIGN=32

_CurKbMAP:       ;-----------------------
SignKb          RESD    1; == 'KMAP'
SizeKb          RESD    1
KbMapPtr        RESD    1
NbPrefixKb      RESD    1
TabPrefixKb     RESD    1
NbNrmPrefixKb   RESD    1
TabNrmPrefixKb  RESD    1
NbNrmKb         RESD    1
TabNrmKb        RESD    1
resv2Kb         RESD    3
CurPrefixKb     RESD    1
ValidCurKbMAP   RESD    1
resvKb          RESD    2;-------------------
_KbFLAG         RESD    1
_KbApp          RESD    8
KeyFrstDownTime RESD    256
KeyTimeEvents   RESD    32
KeyTimeKyEvents RESB    32
AsciiCircBuff   RESD    8
AsciiKbFLAG:    RESD    32
KeyCircBuff     RESD    8
KeyKbFLAG:      RESD    32
AsciiCBDeb      RESD    1
AsciiCBFin      RESD    1
KeyCBDeb        RESD    1
KeyCBFin        RESD    1
KeyTimeCBDeb    RESD    1
KeyTimeCBFin    RESD    1
AsciiNbElt      RESD    1
KeyNbElt        RESD    1
KeyTimeNbElt    RESD    1

_LastKey        RESB    1
_LastAscii      RESB    1
ScanAscii       RESB    1
ExtKey          RESB    1
PauseKey        RESB    1
PausePressed    RESB    1
KbMyDSSelector  RESW    1
KeyPressed      RESB    1
KeyFLAG         RESB    1
KeyAlignMem     RESW    1

