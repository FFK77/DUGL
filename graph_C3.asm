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


; rename global functions and vars to allow multi-core!
; GLOBAL Functions
%define DgSetCurSurf                DgSetCurSurf_C3
%define DgSetSrcSurf                DgSetSrcSurf_C3
%define DgGetCurSurf                DgGetCurSurf_C3
%define DgClear16                   DgClear16_C3
%define ClearSurf16                 ClearSurf16_C3
%define Bar16                       Bar16_C3
%define InBar16                     InBar16_C3
%define BarBlnd16                   BarBlnd16_C3
%define InBarBlnd16                 InBarBlnd16_C3
%define DgPutPixel16                DgPutPixel16_C3
%define DgCPutPixel16               DgCPutPixel16_C3
%define DgGetPixel16                DgGetPixel16_C3
%define DgCGetPixel16               DgCGetPixel16_C3

%define line16                      line16_C3
%define Line16                      Line16_C3
%define linemap16                   linemap16_C3
%define LineMap16                   LineMap16_C3
%define lineblnd16                  lineblnd16_C3
%define LineBlnd16                  LineBlnd16_C3
%define linemapblnd16               linemapblnd16_C3
%define LineMapBlnd16               LineMapBlnd16_C3
%define Poly16                      Poly16_C3
%define RePoly16                    RePoly16_C3
%define PutSurf16                   PutSurf16_C3
%define PutMaskSurf16               PutMaskSurf16_C3
%define PutSurfBlnd16               PutSurfBlnd16_C3
%define PutMaskSurfBlnd16           PutMaskSurfBlnd16_C3
%define PutSurfTrans16              PutSurfTrans16_C3
%define PutMaskSurfTrans16          PutMaskSurfTrans16_C3
%define ResizeViewSurf16            ResizeViewSurf16_C3
%define MaskResizeViewSurf16        MaskResizeViewSurf16_C3
%define TransResizeViewSurf16       TransResizeViewSurf16_C3
%define MaskTransResizeViewSurf16   MaskTransResizeViewSurf16_C3
%define BlndResizeViewSurf16        BlndResizeViewSurf16_C3
%define MaskBlndResizeViewSurf16    MaskBlndResizeViewSurf16_C3
%define SurfMaskCopyBlnd16          SurfMaskCopyBlnd16_C3
%define SurfMaskCopyTrans16         SurfMaskCopyTrans16_C3
%define SetCurBMFont                SetCurBMFont_C3
%define OutTextBM16                 OutTextBM16_C3

; GLOBAL vars
%define CurSurf                     CurSurf_C3
%define SrcSurf                     SrcSurf_C3
%define TPolyAdDeb                  TPolyAdDeb_C3
%define TPolyAdFin                  TPolyAdFin_C3
%define TexXDeb                     TexXDeb_C3
%define TexXFin                     TexXFin_C3
%define TexYDeb                     TexYDeb_C3
%define TexYFin                     TexYFin_C3
%define PColDeb                     PColDeb_C3
%define PColFin                     PColFin_C3
%define DebYPoly                    DebYPoly_C3
%define FinYPoly                    FinYPoly_C3
%define PolyMaxY                    PolyMaxY_C3
%define PolyMinY                    PolyMinY_C3
%define LastPolyStatus              LastPolyStatus_C3
%define PolyCheckCorners            PolyCheckCorners_C3

%define vlfb                        vlfb_C3
%define rlfb                        rlfb_C3
%define ResH                        ResH_C3
%define ResV                        ResV_C3
%define MaxX                        MaxX_C3
%define MaxY                        MaxY_C3
%define MinX                        MinX_C3
%define MinY                        MinY_C3
%define OrgY                        OrgY_C3
%define OrgX                        OrgX_C3
%define SizeSurf                    SizeSurf_C3
%define OffVMem                     OffVMem_C3
%define BitsPixel                   BitsPixel_C3
%define ScanLine                    ScanLine_C3
%define Mask                        Mask_C3
%define NegScanLine                 NegScanLine_C3

%define Svlfb                       Svlfb_C3
%define Srlfb                       Srlfb_C3
%define SResH                       SResH_C3
%define SResV                       SResV_C3
%define SMaxX                       SMaxX_C3
%define SMaxY                       SMaxY_C3
%define SMinX                       SMinX_C3
%define SMinY                       SMinY_C3
%define SOrgY                       SOrgY_C3
%define SOrgX                       SOrgX_C3
%define SSizeSurf                   SSizeSurf_C3
%define SOffVMem                    SOffVMem_C3
%define SBitsPixel                  SBitsPixel_C3
%define SScanLine                   SScanLine_C3
%define SMask                       SMask_C3
%define SNegScanLine                SNegScanLine_C3

%define CurDBMFONT                  CurDBMFONT_C3
%define SetCurBMFont                SetCurBMFont_C3

; redefine FILLRET and some jumps as renaming fail to update them
%macro  @FILLRET_C3    0
    JMP Poly16_C3.PasDrawPoly
%endmacro


%define @FILLRET                    @FILLRET_C3
%define Line16.DoLine16             Line16_C3.DoLine16
%define LineMap16.DoLine16          LineMap16_C3.DoLine16
%define LineBlnd16.DoLine16         LineBlnd16_C3.DoLine16
%define LineMapBlnd16.DoLine16      LineMapBlnd16_C3.DoLine16
%define InBar16.CommonInBar16       InBar16_C3.CommonInBar16
%define InBar16.EndInBar            InBar16_C3.EndInBar
%define InBarBlnd16.EndInBarBlnd    InBarBlnd16_C3.EndInBarBlnd
%define InBarBlnd16.CommonInBar16   InBarBlnd16_C3.CommonInBar16
%define Poly16.PasDrawPoly          Poly16_C3.PasDrawPoly

%include "graph.asm"
