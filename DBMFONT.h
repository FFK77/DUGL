
/*  Dust Ultimate Game Library (DUGL)
    Copyright (C) 2025  Fakhri Feki

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    contact: libdugl(at)hotmail.com    */

#ifndef DBMFONT_H_INCLUDED
#define DBMFONT_H_INCLUDED


#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    DgSurf*     CharsSSurfs[256]; // array of pointer of DGSurf* of each char
    int         CharsPlusX[256]; // array of integer of delta x in pixels after rendering the char
    int         CharsWidth[256]; // array of integer of char width in pixels
    int         CharsHeight[256]; // array of integer of char height in pixels
    int         CharsXOffset[256]; // x position of the char Surf on the square charsWidth[i] x CharsGHeight
    int         CharsYOffset[256]; // y position of the char Surf on the square charsWidth[i] x CharsGHeight
    int         CharsGHeight; // Global Height of this list of chars or distance between lines
    int         CharsGLineHeight; // Global Height starting from ground line
    int         CharX; // X position of next char to render
    int         CharY; // Y position of next char to render
    int         CharCurChar; // current char to render
    DgSurf*     CharsMainSurf; // pointer to single DGSurf, if all chars DGSurf point/share to/same single DGSurf
    int         RendX;
    int         RendY;
} DBMFONT;

typedef enum {
    BMFONT_ADJUST_SRC = 0,
    BMFONT_ADJUST_DST = 1,
    BMFONT_ADJUST_MID = 2
} DBMFONT_ADJUST;

typedef void (*OutTextBM16PTR)(const char*);

extern DBMFONT       CurDBMFONT; // current active Bitmap FONT

bool LoadBMFONT(char *fileDescName, DgSurf *AllCharsSurf, DBMFONT **newDBMFONT);
void DestroyBMFONT(DBMFONT *pBMFONT);
void SetCurBMFont(DBMFONT *pBMFONT);
int  WidthBMText(DBMFONT *pBMFONT, const char *str); // text width in pixels
int  WidthPosBMText(DBMFONT *pBMFONT, const char *str,int pos); // text width taking only Pos characters
int  PosWidthBMText(DBMFONT *pBMFONT, const char *str,int width); // Position in *str if we progress by "width" pixels
void OutTextBM16(const char *str);
#define OutTextBM16Format(OutTextBM16, midStr, sizeMidStr, fmt, ...) snprintf(midStr, sizeMidStr, fmt, __VA_ARGS__); OutTextBM16(midStr);
void OutMultiLinesTextBM16(OutTextBM16PTR OutTextBM16Func, DBMFONT *pBMFONT, int textMaxX, int MaxLines, DBMFONT_ADJUST bmfont_adjust, const char *str);
#define OutMultiLinesTextBM16Format(OutTextBM16Func, pBMFONT, textMaxX, maxLines, BMFONT_ADJUST, midStr, sizeMidStr, fmt, ...)\
        snprintf(midStr, sizeMidStr, fmt, __VA_ARGS__);\
        OutMultiLinesTextBM16(OutTextBM16Func, pBMFONT, textMaxX, maxLines, BMFONT_ADJUST, midStr);

#ifdef __cplusplus
        }  // extern "C" {
#endif

#endif // DBMFONT_H_INCLUDED

