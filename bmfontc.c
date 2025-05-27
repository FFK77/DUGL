/*	Dust Ultimate Game Library (DUGL)
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

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>

#include "DUGL.h"

#define BMFONT_LSIGN_INFO       "info "
#define BMFONT_LSIGN_COMMON     "common "
#define BMFONT_LSIGN_PAGE       "page "
#define BMFONT_LSIGN_CHARS      "chars "
#define BMFONT_LSIGN_CHAR       "char "
#define BMFONT_LSIGN_KERNINGS   "kernings "
#define BMFONT_LSIGN_KERNING    "kerning "

#define BMFONT_INFO_ID          0
#define BMFONT_COMMON_ID        1
#define BMFONT_PAGE_ID          2
#define BMFONT_CHARS_ID         3
#define BMFONT_CHAR_ID          4
#define BMFONT_KERNINGS_ID      5
#define BMFONT_KERNING_ID       6

bool LoadBMFONT(char *fileDescName, DgSurf *AllCharsSurf, DBMFONT **resDBMFONT) {
	DFileBuffer *FileBuffer = NULL;
    DBMFONT *newBMFont = SDL_SIMDAlloc(sizeof(DBMFONT));
    DSplitString *ListInfoLine = CreateDSplitString(0, 128);
    DSplitString *QuoteSplitter = CreateDSplitString(3, 2048);
    static char* BMMultiDelims = "= ";
    static int countLineSigns = 7;
    static char *BMFontLineSigns[] = {
        BMFONT_LSIGN_INFO,
        BMFONT_LSIGN_COMMON,
        BMFONT_LSIGN_PAGE,
        BMFONT_LSIGN_CHARS,
        BMFONT_LSIGN_CHAR,
        BMFONT_LSIGN_KERNINGS,
        BMFONT_LSIGN_KERNING
    };
    static int BMFontSignsLength[] = {
        sizeof(BMFONT_LSIGN_INFO)-1,
        sizeof(BMFONT_LSIGN_COMMON)-1,
        sizeof(BMFONT_LSIGN_PAGE)-1,
        sizeof(BMFONT_LSIGN_CHARS)-1,
        sizeof(BMFONT_LSIGN_CHAR)-1,
        sizeof(BMFONT_LSIGN_KERNINGS)-1,
        sizeof(BMFONT_LSIGN_KERNING)-1
    };

    if (newBMFont == NULL || AllCharsSurf == NULL || ListInfoLine == NULL || QuoteSplitter == NULL) {
        dgLastErrID = DG_ERSS_NO_MEM;
        return false;
    }
    FileBuffer = CreateDFileBuffer(0);
    if (FileBuffer == NULL) {
        SDL_SIMDFree(newBMFont);
        dgLastErrID = DG_ERSS_NO_MEM;
        return false;
    }

    if (!OpenFileDFileBuffer(FileBuffer, fileDescName, "rt")) {
        SDL_SIMDFree(newBMFont);
        DestroyDFileBuffer(FileBuffer);
        DestroySurf(newBMFont->CharsMainSurf);
        dgLastErrID = DG_ERSS_FILE_NOT_FOUND;
        return false;
	}

	newBMFont->CharsMainSurf = AllCharsSurf;
	// init BMFONT with dummy
	SDL_memcpy4(newBMFont, &dummyDBMFONT, sizeof(DBMFONT)/4);
	// set main source DgSurf
	newBMFont->CharsMainSurf = AllCharsSurf;

    // parse fnt description file
    char *nexBMLine = (char*)SDL_malloc(ListInfoLine->maxGlobLength+1);
    SetMultiDelimDSplitString(ListInfoLine, BMMultiDelims); // set list of delimiters for MultiDelimSplit
    bool infoLineFound = false;
    bool commonLineFound = false;
    bool pageLineFound = false;
    bool validFileFormat = true;

	while (!IsEndOfFileDFileBuffer(FileBuffer) && validFileFormat) {
        if (GetLineDFileBuffer(FileBuffer, nexBMLine, ListInfoLine->maxGlobLength) == 0)
            continue; // ignore empty line

        // detect line signature
        int LineSignIdx = -1;
        int globCharsPlus = 0;
        for (int i = 0; i < countLineSigns; i++) {
            if (SDL_strncmp(BMFontLineSigns[i], nexBMLine, BMFontSignsLength[i]) == 0) {
                LineSignIdx = i;
                globCharsPlus = BMFontSignsLength[i];
                break;
            }
        }
        if (LineSignIdx == -1) {
            // unknow line! // issue warning
        }
        else {
            // try jump "face" attribut for "info " line
            if (LineSignIdx == BMFONT_INFO_ID && !infoLineFound) {
                if (SDL_strncmp(&nexBMLine[globCharsPlus], "face", 4) == 0) {
                    int countQuotes = 0;
                    while (countQuotes < 2 && nexBMLine[globCharsPlus] != '\0') {
                        globCharsPlus++;
                        if (nexBMLine[globCharsPlus] == '"') {
                            countQuotes++;
                            globCharsPlus++;
                        }
                    }
                }
            }
            // extract attributs
            splitMultiDelimDSplitString(ListInfoLine, &nexBMLine[globCharsPlus], false);
            TrimStringsDSplitString(ListInfoLine);

            switch (LineSignIdx) {
                case BMFONT_INFO_ID:
                    // handle only once
                    if (!infoLineFound) {
                        infoLineFound = true;
                        // extract attributs
                    }
                    break;

                case BMFONT_COMMON_ID:
                    // handle only once
                    if (!commonLineFound) {
                        commonLineFound = true;
                        int commonAttsFound = 0;
                        int commonLineHeight = 0;
                        int commonBase = 0;
                        int commonScaleW = 0;
                        int commonScaleH = 0;
                        // extract attributs
                        for (int i = 0; i < ListInfoLine->countStrings; i+=2) {
                            if (!SDL_strcmp("lineHeight", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    commonAttsFound |= 1;
                                    commonLineHeight = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("base", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    commonAttsFound |= 1 << 1;
                                    commonBase = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("scaleW", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    commonAttsFound |= 1 << 2;
                                    commonScaleW = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("scaleH", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    commonAttsFound |= 1 << 3;
                                    commonScaleH = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            }
                        }
                        if (commonAttsFound != 0xf ||
                            newBMFont->CharsMainSurf->ResH != commonScaleW ||
                            newBMFont->CharsMainSurf->ResV != commonScaleH) {
                            validFileFormat = false;
                            //printf("invalid common file Format");
                        } else {
                            newBMFont->CharsGHeight = commonLineHeight;
                            newBMFont->CharsGLineHeight = commonBase;
                        }
                    }
                    break;

                case BMFONT_PAGE_ID:
                    // handle only once
                    if (!pageLineFound) {
                        pageLineFound = true;
                    }
                    break;

                case BMFONT_CHARS_ID:
                    // ignore
                    break;

                case BMFONT_CHAR_ID:
                    if (commonLineFound) {
                        int charAttsFound = 0;
                        int charID = 0;
                        int charX = 0;
                        int charY = 0;
                        int charWIDTH = 0;
                        int charHEIGHT = 0;
                        int charXOFFSET = 0;
                        int charYOFFSET = 0;
                        int charXADVANCE = 0;
                        // converted data
                        int charOrgY = 0; // from descending to ascending y axis
                        // extract attributs
                        for (int i = 0; i < ListInfoLine->countStrings; i+=2) {
                            if (!SDL_strcmp("id", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1;
                                    charID = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("x", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1 << 1;
                                    charX = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("y", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1 << 2;
                                    charY = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("width", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1 << 3;
                                    charWIDTH = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("height", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1 << 4;
                                    charHEIGHT = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("xoffset", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1 << 5;
                                    charXOFFSET = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("yoffset", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1 << 6;
                                    charYOFFSET = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            } else if (!SDL_strcmp("xadvance", ListInfoLine->ListStrings[i]) && (i+1) < ListInfoLine->countStrings) {
                                if (splitDSplitString(QuoteSplitter, ListInfoLine->ListStrings[i+1], '"', false) == 1) {
                                    charAttsFound |= 1 << 7;
                                    charXADVANCE = SDL_atoi(QuoteSplitter->ListStrings[0]);
                                }
                            }
                        }
                        if (charAttsFound != 0xff || charID == 0 || charID > 255) {
                            //printf("invalid char line %i\n", charID);
                            // invalid line, missing attributs
                        } else {
                            // convert to ascending
                            charOrgY = newBMFont->CharsMainSurf->MaxY - charY - charHEIGHT+1;

                            if (charX + (charWIDTH - 1) <= newBMFont->CharsMainSurf->MaxX && charOrgY + charHEIGHT-1 <= newBMFont->CharsMainSurf->MaxY) {
                                if (charWIDTH > 0 && charHEIGHT > 0) {
                                    DgView charView = { .OrgX = charX, .OrgY = charOrgY, .MinX = 0, .MinY = 0, .MaxX = charWIDTH-1, .MaxY = charHEIGHT-1 };
                                    CreateSurfBuffView(&newBMFont->CharsSSurfs[charID], newBMFont->CharsMainSurf->ResH, newBMFont->CharsMainSurf->ResV, 16,
                                                       (void*)newBMFont->CharsMainSurf->rlfb, &charView);
                                }
                                newBMFont->CharsPlusX[charID] = charXADVANCE;
                                newBMFont->CharsXOffset[charID] = charXOFFSET;
                                newBMFont->CharsYOffset[charID] = charYOFFSET;
                                newBMFont->CharsHeight[charID] = charHEIGHT;
                            } else {
                                //printf("Warning '%c' ignored out of Image!\n", charID);
                            }
                        }
                    } else {
                        validFileFormat = false;
                        //printf("invalid common file Format");
                    }

                    break;

                case BMFONT_KERNINGS_ID:
                    // ignore
                    break;

                case BMFONT_KERNING_ID:
                    // ignore
                    break;
                default:
                    // ignore / issue warning ?

            }
        }
	}

    SDL_free(nexBMLine);
	DestroyDFileBuffer(FileBuffer);
	DestroyDSplitString(QuoteSplitter);
	DestroyDSplitString(ListInfoLine);

	*resDBMFONT = newBMFont;
    return validFileFormat;
}

void DestroyBMFONT(DBMFONT *pBMFONT) {
    if (pBMFONT == NULL)
        return;
    if (pBMFONT->CharsMainSurf != NULL) {
        DestroySurf(pBMFONT->CharsMainSurf);
    } else {
        return;
    }
}

int  WidthBMText(DBMFONT *pBMFONT, const char *str) {
    const char *strIt = str;
    int widthText = 0;

    if (strIt == NULL || pBMFONT == NULL)
        return 0;
    while (*strIt != '\0') {
        widthText += pBMFONT->CharsPlusX[(unsigned char)(*strIt)];
        strIt ++;
    }
    return widthText;
}

int  WidthPosBMText(DBMFONT *pBMFONT, const char *str,int pos) {
    const char *strIt = str;
    int widthText = 0;

    if (strIt == NULL || pBMFONT == NULL)
        return 0;
    for (int i =0; i < pos &&  (*strIt) != '\0'; i++, strIt ++) {
        widthText += pBMFONT->CharsPlusX[(unsigned char)(*strIt)];
    }
    return widthText;
}

void OutMultiLinesTextBM16(OutTextBM16PTR OutTextBM16Func, DBMFONT *pBMFONT, int textMaxX, int MaxLines, DBMFONT_ADJUST bmfont_adjust, const char *str) {
    if (OutTextBM16Func == NULL || pBMFONT == NULL) {
        return;
    }
    DSplitString *linesSplitter = CreateStrDSplitString(MaxLines, str);
    if (linesSplitter == NULL) {
        return;
    }
    int initX = pBMFONT->CharX;
    int initY = pBMFONT->CharY;
    int widthLineText = 0;

    if (splitDSplitString(linesSplitter, NULL, '\n', true) > 0) {
        for (int i = 0; i < linesSplitter->countStrings; i++) {
            switch (bmfont_adjust) {
            case BMFONT_ADJUST_SRC:
                pBMFONT->CharX = initX;
                break;
            case BMFONT_ADJUST_DST:
                widthLineText = WidthBMText(pBMFONT, linesSplitter->ListStrings[i]);
                pBMFONT->CharX = textMaxX - widthLineText - 1;
                break;
            case BMFONT_ADJUST_MID:
                widthLineText = WidthBMText(pBMFONT, linesSplitter->ListStrings[i]);
                pBMFONT->CharX = (initX+textMaxX) /2 - widthLineText / 2;
                break;
            default:
                pBMFONT->CharX = initX;
            }
            pBMFONT->CharY = initY - (i* pBMFONT->CharsGHeight);
            OutTextBM16Func(linesSplitter->ListStrings[i]);
        }
    }
    DestroyDSplitString(linesSplitter);
}
