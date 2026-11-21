#ifndef DAUDIO_H_INCLUDED
#define DAUDIO_H_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*daudioEventCallBack)(unsigned int);

typedef struct DSound {
    unsigned char       *data;
    unsigned int        length;
} DSound;

// DSound

typedef struct DSoundState {
    DSound              *sound;
    unsigned int        volume;
    unsigned int        position;

    daudioEventCallBack OnFinish;
    daudioEventCallBack OnLoop;
    daudioEventCallBack OnQueue;

    bool                paused;
    bool                loop;
    bool                queueInheritEvents;
    bool                stopEvents;
} DSoundState;

#define NO_SOUND_ID 0xffffffff

// initialize Audio output with frequency [11025, 48000Hz], stereo or not
bool InstallDAudio(int frequency, bool stereo);
// Unininstall audio and free allocated ressources
void UninstallDAudio();
// Start outputting audio / InstallDAudio start at paused state
void PlayDAudio();
// stop outputting audio
void PauseDAudio();
// Lock audio (Mutex) for Critical data
void LockDAudio();
// Unlock audio (Mutex) for Critical data
void UnlockDAudio();
// Load DSound WAV and convert it to the current audio output format/frequency
DSound *DgLoadWAV(char *filename);
// Destroy loaded DSound
void DestroyDSound(DSound *sound);

// Allocate a new channel or (soundID) and start playing it if paused is false, return the new channel or NO_SOUND_ID if failed
unsigned int PlayDSound(DSound *sound, unsigned char volume, bool loop, bool paused);
// free the soundID and stop playing it
void StopDSound(unsigned int soundID);
// update volume of SoundID
void SetVolumeDSound(unsigned int soundID, unsigned char volume);
// Change paused state of SoundID
void SetPausedDSound(unsigned int soundID, bool paused);
// Change looping state of SoundID
void SetLoopingDSound(unsigned int soundID, bool loop);
// Change StopEvents state of SoundID, if false will stop calling channel events callback
void SetStopEventsDSound(unsigned int soundID, bool stopEvents);
// Get soundID state
DSoundState* GetPlayingStateDSound(unsigned int soundID);
// set events callback for soundID
void SetEventsDSound(unsigned int soundID, daudioEventCallBack OnFinish, daudioEventCallBack OnLoop, daudioEventCallBack OnQueue);
// Queue a sound for soundID, will only play if the current sound finish
bool QueueDSound(unsigned int soundID, DSound *sound, unsigned char volume, bool loop, bool paused, bool inheritEvents);
// Replace current soundID with new sound as soon as possible, if the soundID already finished return false and the new channel in SoundID
bool ReplaceDSound(unsigned int *soundID, DSound *sound, unsigned char volume, bool loop, bool paused, bool inheritEvents);
// return true if the soundID has a queue sound waiting
bool IsQueuedDSound(unsigned int soundID);
// return true if the soundID is playing even if paused
bool IsPlayingDSound(unsigned int soundID);
// get current count of channels used
unsigned int GetPlayingDSoundCount();

#ifdef __cplusplus
        }  // extern "C" {
#endif


#endif // DAUDIO_H_INCLUDED
