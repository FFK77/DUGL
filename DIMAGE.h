#ifndef DIMAGE_H_INCLUDED
#define DIMAGE_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

// IMAGE Support ============================================

// COMPRESSION

void InRLE(void *InBuffRLE,void *Out,int LenOut);
void OutRLE(void *OutBuffRLE,void *In,int LenIn,int ResHz);
int  SizeOutRLE(void *In,int LenIn,int ResHz);
int InLZW(void *InBuffLZW,void *Out, int LenOut);

// BMP
int LoadBMP(DgSurf **S,const char *filename,void *PalBGR1024);
int LoadMemBMP16(DgSurf **S,void *In,int SizeIn); // load a 24bpp uncompressed BMP into a 16bpp Surf
int LoadBMP16(DgSurf **S,char *filename);
int SaveMemBMP16(DgSurf *S,void *Out); // save  a 16bpp surf into a 24bpp uncompressed BMP
int SaveBMP16(DgSurf *S,char *filename);
int SizeSaveBMP16(DgSurf *S);
int LoadBMP8To16(DgSurf **S16,char *filename); // load a 8bpp BMP and convert it to 16 bpp
// GIF
int LoadMemGIF(DgSurf **S,void *In,void *PalBGR1024,int SizeIn);
int LoadGIF(DgSurf **S,char *filename,void *PalBGR1024);
int LoadMemGIF16(DgSurf **S16,void *In,int SizeIn); // load a 8bpp GIF and convert it to 16 bpp
int LoadGIF16(DgSurf **S16,char *filename);
// PCX
int LoadMemPCX(DgSurf **S,void *In,void *PalBGR1024,int SizeIn);
int LoadPCX(DgSurf **S,char *filename,void *PalBGR1024);
int LoadMemPCX16(DgSurf **S,void *In,int SizeIn); // load a 8bpp PCX and convert it to 16 bpp
int LoadPCX16(DgSurf **S,char *filename);
// PNG
int LoadPNG16(DgSurf **S,char *filename);
int LoadMemPNG16(DgSurf **S, void *In, int SizeIn);
// JPG
int LoadJPG16(DgSurf **S,char *filename);
int LoadMemJPG16(DgSurf **S,void *buffJpeg,int sizeBuff);
int SaveJPG16(DgSurf *S,char *filename,int quality);
int SaveMemJPG16(DgSurf *S,void **OutJpg, int *SizeOutJpg, int quality);

#ifdef __cplusplus
        }  // extern "C" {
#endif

#endif // DIMAGE_H_INCLUDED

