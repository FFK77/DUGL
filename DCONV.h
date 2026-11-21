
#ifndef DCONV_H_INCLUDED
#define DCONV_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

// EFFECTS & CONVERSION ====================================

// thread safe functions
void ConvSurf8ToSurf16Pal(DgSurf *S16Dst, DgSurf *S8Src,void *PalBGR1024);
void Blur16(void *BuffImgDst, void *BuffImgSrc, int ImgWidth, int ImgHeight, int StartLine, int EndLine);
void BlurSurf16(DgSurf *S16Dst, DgSurf *S16Src);


#ifdef __cplusplus
        }  // extern "C" {
#endif

#endif // DCONV_H_INCLUDED

