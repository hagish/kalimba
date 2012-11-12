* drag the directories from this folder (libpd_wrapper, objc, src) into a fresh ios unity xcode project
* project -> build setting -> targets: unity-iphone -> other c flags

-mno-thumb -DHAVE_UNISTD_H -DHAVE_LIBDL -DPD

* if there is a compile error try clean and rebuild
* create new group in the project for ressources (eg. pd)
* drag content from StreamingAssets/pd into this group
* everything should compile without an error
* adjust unity-iphone -> classes -> AppController.h

#import <UIKit/UIKit.h>

#import "PdAudioController.h"	<------------------------ add this
#import "PdBase.h"		<------------------------ add this

@interface AppController : NSObject<UIAccelerometerDelegate, UIApplicationDelegate>
{
}

@property (nonatomic, retain) PdAudioController *audioController;	<------- add this

- (void) startUnity:(UIApplication*)application;
- (void) startRendering;
- (void) Repaint;
- (void) RepaintDisplayLink;
- (void) prepareRunLoop;
@end

#define NSTIMER_BASED_LOOP 0
#define THREAD_BASED_LOOP 1
#define EVENT_PUMP_BASED_LOOP 2

* adjust unity-iphone -> classes -> AppController.mm : after startUnity

    if ([UIDevice currentDevice].generatesDeviceOrientationNotifications == NO)
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [self startUnity:application];


  self.audioController = [[[PdAudioController alloc] init] autorelease];	<---------- add this start
  [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:NO];

  [self.audioController configureTicksPerBuffer:128];

  [PdBase openFile:@"main.pd" path:[[NSBundle mainBundle] resourcePath]];
  [self.audioController setActive:YES];
  [self.audioController print];		<--------- add this end


    return NO;
}

* adjust unity-iphone -> classes -> AppController.mm : dealloc

    DestroySurface(&_surface);
    [_context release];
    _context = nil;

    self.audioController = nil;		<------ add this

    [_window release];
    [super dealloc];

* adjust unity-iphone -> classes -> AppController.mm : after @implementation AppController

@implementation AppController

@synthesize audioController = audioController_;		<----- add this

- (void) registerAccelerometer

* build and deploy
* now pd should work on iphone with unity
