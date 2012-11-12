#import <UIKit/UIKit.h>

#import "PdAudioController.h"
#import "PdBase.h"

@interface AppController : NSObject<UIAccelerometerDelegate, UIApplicationDelegate>
{
}

@property (nonatomic, retain) PdAudioController *audioController;

- (void) startUnity:(UIApplication*)application;
- (void) startRendering;
- (void) Repaint;
- (void) RepaintDisplayLink;
- (void) prepareRunLoop;
@end

#define NSTIMER_BASED_LOOP 0
#define THREAD_BASED_LOOP 1
#define EVENT_PUMP_BASED_LOOP 2
