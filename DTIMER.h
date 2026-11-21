#ifndef DTIMER_H_INCLUDED
#define DTIMER_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

// Time Support ==============================================
void DgInstallTimer(int Freq);
void DgUninstallTimer();

// Timer Synch<ronisation>

//#define SIZE_SYNCH_BUFF 168
#define SIZE_SYNCH_BUFF 284

extern unsigned int DgTime;
extern int DgTimerFreq;

int  InitSynch(void *SynchBuff,int *Pos,float Freq); // init Synch buffer and start synching
void StartSynch(void *SynchBuff,int *Pos); // Restart Synching
int  Synch(void *SynchBuff,int *Pos); // synch
float SynchAccTime(void *SynchBuff); // time "in sec" since InitSynch or StartSynch
float SynchAverageTime(void *SynchBuff); // average time "in sec" between Synch calls
float SynchLastTime(void *SynchBuff); // last non zero time "in sec" between Synch calls
int  WaitSynch(void *SynchBuff,int *Pos);
void DgDelay(unsigned int delayInMs); // wait DelayInMs

#ifdef __cplusplus
        }  // extern "C" {
#endif


#endif // DTIMER_H_INCLUDED

