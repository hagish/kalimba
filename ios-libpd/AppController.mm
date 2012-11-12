#import "AppController.h"

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <Availability.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/glext.h>

#include <mach/mach_time.h>

// USE_DISPLAY_LINK_IF_AVAILABLE
//
// Use of the CADisplayLink class is the preferred method for controlling your
// rendering loop. CADisplayLink will link to the main display and fire every
// vsync when added to a given run-loop. Other main loop types (NSTimer, Thread,
// EventPump) are used only as fallback when running on a pre 3.1 device where
// CADisplayLink is not available.
//
// NOTE: some developers reported problems with input lag while using
// CADisplayLink, so try to disable it if this is the case for you.
//
// Note that OS version and CADisplayLink support will be determined at the
// run-time automatically and you CAN compile your application using ANY SDK.
// Your application will work succesfully on pre 3.1 device too.
//


// Fallback types (for pre 3.1 devices):

// NSTIMER_BASED_LOOP
//
// It is a common approach to use NSTimer for scheduling rendering on a pre 3.1
// device NSTimer approach is perfect for non-performance critical applications
// which favours battery life and scrupulous correct events processing over the
// rendering performance.
//
// Constants supported by this method: kThrottleFPS


// THREAD_BASED_LOOP
//
// However number of games might prefer frame-rate over battery life,
// therefore Unity provide alternate methods which allows you to run in a
// tighter rendering loop.

// Thread based loop allows to get best of two worlds - fast rendering and
// guaranteed event processing.
//


// EVENT_PUMP_BASED_LOOP
//
// Following method allows you to specify explicit time limit for OS to process
// events. Though it might lend you best rendering performance some input events
// maybe missing, therefore you must carefully tweak
// kMillisecondsPerFrameToProcessEvents to achieve desired responsivness.
//
// Constants supported by this method: kMillisecondsPerFrameToProcessEvents


// Constants:
//
// kThrottleFPS - usually you need to boost NSTimer approach a bit to get any
// decent performance. Set to 2 by default. Meaningful only if
// NSTIMER_BASED_LOOP method is used.

// kMillisecondsPerFrameToProcessEvents - allows you to specify how much time
// you allow to process events if OS event pump method is used. Set to 3ms by
// default. Settings kMillisecondsPerFrameToProcessEvents to 0 will make main
// loop to wait for OS to pump all events.
// Meaningful only if EVENT_PUMP_BASED_LOOP method is used.

#define USE_OPENGLES20_IF_AVAILABLE 1
#define USE_DISPLAY_LINK_IF_AVAILABLE 1
// MSAA_DEFAULT_SAMPLE_COUNT was moved to iPhone_GlesSupport.h

//#define FALLBACK_LOOP_TYPE NSTIMER_BASED_LOOP
#define FALLBACK_LOOP_TYPE THREAD_BASED_LOOP
//#define FALLBACK_LOOP_TYPE EVENT_PUMP_BASED_LOOP


#include "iPhone_Common.h"
#include "iPhone_GlesSupport.h"

// ENABLE_INTERNAL_PROFILER and related defines were moved to iPhone_Profiler.h
#include "iPhone_Profiler.h"


// --- CONSTANTS ---------------------------------------------------------------
//

#if FALLBACK_LOOP_TYPE == NSTIMER_BASED_LOOP
#define kThrottleFPS                            2.0
#endif

#if FALLBACK_LOOP_TYPE == EVENT_PUMP_BASED_LOOP
#define kMillisecondsPerFrameToProcessEvents    3
#endif

// kFPS define for removed
// you can use Application.targetFrameRate (30 fps by default)

// Time to process events in seconds.
// Only used when display link loop is enabled.
#define kInputProcessingTime                    0.001

extern "C" __attribute__((visibility ("default"))) NSString * const kUnityViewWillRotate = @"kUnityViewWillRotate";
extern "C" __attribute__((visibility ("default"))) NSString * const kUnityViewDidRotate = @"kUnityViewDidRotate";

// --- Unity ------------------------------------------------------------------
//

enum EnabledOrientation
{
    kAutorotateToPortrait = 1,
    kAutorotateToPortraitUpsideDown = 2,
    kAutorotateToLandscapeLeft = 4,
    kAutorotateToLandscapeRight = 8
};


enum ScreenOrientation
{
    kScreenOrientationUnknown,
    portrait,
    portraitUpsideDown,
    landscapeLeft,
    landscapeRight,
    autorotation,
    kScreenOrientationCount
};


void UnityPlayerLoop();
void UnityFinishRendering();
void UnityInitApplication(const char* appPathName);
void UnityLoadApplication();
void UnityPause(bool pause);
void UnityReloadResources();
void UnitySetAudioSessionActive(bool active);
void UnityCleanup();

void UnitySendTouchesBegin(NSSet* touches, UIEvent* event);
void UnitySendTouchesEnded(NSSet* touches, UIEvent* event);
void UnitySendTouchesCancelled(NSSet* touches, UIEvent* event);
void UnitySendTouchesMoved(NSSet* touches, UIEvent* event);
void UnitySendLocalNotification(UILocalNotification* notification);
void UnitySendRemoteNotification(NSDictionary* notification);
void UnitySendDeviceToken(NSData* deviceToken);
void UnitySendRemoteNotificationError(NSError* error);
void UnityDidAccelerate(float x, float y, float z, NSTimeInterval timestamp);
void UnityInputProcess();
bool UnityIsRenderingAPISupported(int renderingApi);
void UnitySetInputScaleFactor(float scale);
float UnityGetInputScaleFactor();
int  UnityGetTargetFPS();

bool UnityIsOrientationEnabled(EnabledOrientation orientation);
void UnitySetScreenOrientation(ScreenOrientation orientation);
void OrientTo(int requestedOrient_);
ScreenOrientation UnityRequestedScreenOrientation();
ScreenOrientation       ConvertToUnityScreenOrientation(int hwOrient, EnabledOrientation* outAutorotOrient);
UIInterfaceOrientation  ConvertToIosScreenOrientation(ScreenOrientation orient);
bool UnityUseOSAutorotation();

bool UnityUse32bitDisplayBuffer();

void    UnityKeyboardOrientationStep1();
void    UnityKeyboardOrientationStep2();

int     UnityGetDesiredMSAASampleCount(int defaultSampleCount);
int     UnityGetShowActivityIndicatorOnLoading();
int     UnityGetAccelerometerFrequency();

enum TargetResolution
{
    kTargetResolutionNative = 0,
    kTargetResolutionStandard = 1,
    kTargetResolutionHD = 2
};

int UnityGetTargetResolution();


static UIViewController* sGLViewController = nil;
UIViewController* UnityGetGLViewController()
{
    return sGLViewController;
}

static UIView* sGLView = nil;
UIView* UnityGetGLView()
{
    return sGLView;
}


bool    _ios30orNewer       = false;
bool    _ios31orNewer       = false;
bool    _ios43orNewer       = false;
bool    _ios50orNewer       = false;
bool    _ios60orNewer       = false;

bool    _supportsDiscard    = false;
bool    _supportsMSAA       = false;

EAGLSurfaceDesc _surface;

ScreenOrientation   _curOrientation             = kScreenOrientationUnknown;
ScreenOrientation   _nativeRequestedOrientation = kScreenOrientationUnknown;
bool                _autorotEnableHandling      = false;
bool                _glesContextCreated         = false;
bool                _unityLevelReady            = false;
bool                _skipPresent                = false;
bool                _shouldAttemptReorientation = false;


UIActivityIndicatorView*    _activityIndicator  = nil;
UIImageView*                _splashView         = nil;

bool                        _splashPortrait     = true;
bool                        _splashShowing      = false;


class KeyboardOnScreen
{
public:
    static void Init();
};


// --- OpenGLES --------------------------------------------------------------------
//



//extern GLint gDefaultGLES2FBO;
extern GLint gDefaultFBO;


// Forward declaration of CADisplayLink for pre-3.1 SDKS
@interface NSObject(CADisplayLink)
+ (id) displayLinkWithTarget:(id)arg1 selector:(SEL)arg2;
- (void) addToRunLoop:(id)arg1 forMode:(id)arg2;
- (void) setFrameInterval:(int)interval;
- (void) invalidate;
@end


typedef EAGLContext*    MyEAGLContext;

@interface EAGLView : UIView {}
@end

@interface UnityViewController : UIViewController {}
@end

#ifdef __IPHONE_6_0
@interface UnityViewController_preIOS6 : UnityViewController {}
@end

@interface UnityViewController_IOS6 : UnityViewController {}
@end
#endif


MyEAGLContext           _context;
UIWindow *              _window;

NSTimer*                _timer;
bool                    _need_recreate_timer = false;
id                      _displayLink;
BOOL                    _accelerometerIsActive = NO;
// This is set to true when applicationWillResignActive gets called. It is here
// to prevent calling SetPause(false) from applicationDidBecomeActive without
// previous call to applicationWillResignActive
BOOL                    _didResignActive = NO;

bool CreateSurface(EAGLView *view, EAGLSurfaceDesc* surface);
void DestroySurface(EAGLSurfaceDesc* surface);

bool CreateWindowSurface(EAGLView *view, GLuint format, GLuint depthFormat, GLuint msaaSamples, bool retained, EAGLSurfaceDesc* surface)
{

    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)[view layer];

    surface->format = format;
    surface->depthFormat = depthFormat;

    surface->depthbuffer = 0;
    surface->renderbuffer = 0;
    surface->framebuffer = 0;

    surface->msaaFramebuffer = 0;
    surface->msaaRenderbuffer = 0;
    surface->msaaDepthbuffer = 0;
    surface->msaaSamples = _supportsMSAA ? msaaSamples : 0;
    surface->use32bitColor = UnityUse32bitDisplayBuffer();

    surface->eaglLayer = eaglLayer;

    return CreateSurface(view, &_surface);
}

extern "C" void InitEAGLLayer(void* eaglLayer, bool use32bitColor)
{
    CAEAGLLayer* layer = (CAEAGLLayer*)eaglLayer;

    const NSString* colorFormat = use32bitColor ? kEAGLColorFormatRGBA8 : kEAGLColorFormatRGB565;

    layer.opaque = YES;
    layer.drawableProperties =  [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                    colorFormat, kEAGLDrawablePropertyColorFormat,
                                    nil
                                ];
}
extern "C" bool AllocateRenderBufferStorageFromEAGLLayer(void* eaglLayer)
{
    return [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)eaglLayer];
}
extern "C" void DeallocateRenderBufferStorageFromEAGLLayer()
{
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:nil];
}

bool CreateSurface(EAGLView *view, EAGLSurfaceDesc* surface)
{
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)surface->eaglLayer;
    assert(eaglLayer == [view layer]);

    CGSize newSize = [eaglLayer bounds].size;
    newSize.width  = roundf(newSize.width);
    newSize.height = roundf(newSize.height);

#ifdef __IPHONE_4_0
    int resolution = UnityGetTargetResolution();

    if (    (resolution == kTargetResolutionNative || resolution == kTargetResolutionHD)
         && [view respondsToSelector:@selector(setContentScaleFactor:)]
         && [[UIScreen mainScreen] respondsToSelector:@selector(scale)]
       )
    {
            CGFloat scaleFactor = [UIScreen mainScreen].scale;
            [view setContentScaleFactor:scaleFactor];
            newSize.width = roundf(newSize.width * scaleFactor);
            newSize.height = roundf(newSize.height * scaleFactor);
            UnitySetInputScaleFactor(scaleFactor);
    }
#endif

    surface->w = newSize.width;
    surface->h = newSize.height;

    UNITY_DBG_LOG ("CreateWindowSurface: FBO\n");
    CreateSurfaceGLES(surface);
    GLES_CHK( glBindRenderbufferOES(GL_RENDERBUFFER_OES, surface->renderbuffer) );

    return true;
}


void DestroySurface(EAGLSurfaceDesc* surface)
{
    EAGLContext *oldContext = [EAGLContext currentContext];

    if (oldContext != _context)
        [EAGLContext setCurrentContext:_context];

    UnityFinishRendering();
    DestroySurfaceGLES(surface);

    if (oldContext != _context)
        [EAGLContext setCurrentContext:oldContext];
}

void PresentSurface(EAGLSurfaceDesc* surface)
{
    if(_skipPresent || _didResignActive)
    {
        UNITY_DBG_LOG ("SKIP PresentSurface %s\n", _didResignActive ? "due to going to background":"");
        return;
    }
    UNITY_DBG_LOG ("PresentSurface:\n");

    EAGLContext *oldContext = [EAGLContext currentContext];
    if (oldContext != _context)
        [EAGLContext setCurrentContext:_context];

    PreparePresentSurfaceGLES(surface);

    // presentRenderbuffer presents currently bound RB, so make sure we have the correct one bound
    GLES_CHK( glBindRenderbufferOES(GL_RENDERBUFFER_OES, surface->renderbuffer) );
    if(![_context presentRenderbuffer:GL_RENDERBUFFER_OES])
        printf_console("failed to present renderbuffer (%s:%i)\n", __FILE__, __LINE__ );

    AfterPresentSurfaceGLES(surface);

    if(oldContext != _context)
        [EAGLContext setCurrentContext:oldContext];
}

void PresentContext_UnityCallback(struct UnityFrameStats const* unityFrameStats)
{
    Profiler_FrameEnd();

    PresentSurface(&_surface);

    Profiler_FrameUpdate(unityFrameStats);
    Profiler_FrameStart();
}

NSString* SplashViewImage(UIInterfaceOrientation orient)
{
    bool need2xSplash = false;
#ifdef __IPHONE_4_0
    if ( [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1.0 )
        need2xSplash = true;
#endif

    bool needOrientedSplash = false;
    bool needPortraitSplash = true;

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
    {
        bool devicePortrait  = UIDeviceOrientationIsPortrait(orient);
        bool deviceLandscape = UIDeviceOrientationIsLandscape(orient);

        NSArray* supportedOrientation = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
        bool rotateToPortrait  =   [supportedOrientation containsObject: @"UIInterfaceOrientationPortrait"]
                                || [supportedOrientation containsObject: @"UIInterfaceOrientationPortraitUpsideDown"];
        bool rotateToLandscape =   [supportedOrientation containsObject: @"UIInterfaceOrientationLandscapeLeft"]
                                || [supportedOrientation containsObject: @"UIInterfaceOrientationLandscapeRight"];


        needOrientedSplash = true;
        if (devicePortrait && rotateToPortrait)
            needPortraitSplash = true;
        else if (deviceLandscape && rotateToLandscape)
            needPortraitSplash = false;
        else if (rotateToPortrait)
            needPortraitSplash = true;
        else
            needPortraitSplash = false;
    }

    const char* portraitSuffix  = needOrientedSplash ? "-Portrait" : "";
    const char* landscapeSuffix = needOrientedSplash ? "-Landscape" : "";

    const char* szSuffix        = need2xSplash ? "@2x" : "";
    const char* orientSuffix    = needPortraitSplash ? portraitSuffix : landscapeSuffix;

    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
        if([[UIScreen mainScreen] bounds].size.height == 568)
            orientSuffix = "-568h";
    }

    return [NSString stringWithFormat:@"Default%s%s", orientSuffix, szSuffix];
}

void RemoveSplashScreen()
{
    _splashShowing = false;

    [_splashView removeFromSuperview];
    [_splashView release];
    _splashView = nil;
}

void CreateActivityIndicator(UIView* parentView)
{
    int activityIndicatorStyle = UnityGetShowActivityIndicatorOnLoading();
    if( activityIndicatorStyle >= 0)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle];
        [parentView addSubview:_activityIndicator];
    }
}

CGAffineTransform TransformForOrientation( ScreenOrientation orient )
{
    static CGAffineTransform    transform[kScreenOrientationCount];
    static bool                 inited = false;

    if( !inited )
    {
        transform[portrait]             = CGAffineTransformIdentity;
        transform[portraitUpsideDown]   = CGAffineTransformMakeRotation(M_PI);
        transform[landscapeLeft]        = CGAffineTransformMakeRotation(M_PI_2);
        transform[landscapeRight]       = CGAffineTransformMakeRotation(-M_PI_2);

        inited = true;
    }

    return transform[orient];
}


int OpenEAGL_UnityCallback(UIWindow** window, int* screenWidth, int* screenHeight,  int* openglesVersion)
{
    CGRect rect = [[UIScreen mainScreen] bounds];

    // Create a full-screen window
    _window = [[UIWindow alloc] initWithFrame:rect];
    EAGLView* view = [[EAGLView alloc] initWithFrame:rect];

#ifdef __IPHONE_6_0
    UnityViewController *controller = _ios60orNewer ? [[UnityViewController_IOS6 alloc] init] : [[UnityViewController_preIOS6 alloc] init];
#else
    UnityViewController *controller = [[UnityViewController alloc] init];
#endif

    _splashView = [ [UIImageView alloc] initWithFrame: [[UIScreen mainScreen] bounds] ];

    if(   [_splashView respondsToSelector:@selector(setContentScaleFactor:)]
       && [[UIScreen mainScreen] respondsToSelector:@selector(scale)]
      )
        [ _splashView setContentScaleFactor: [UIScreen mainScreen].scale ];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
    {
        _splashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _splashView.autoresizesSubviews = YES;
    }

    sGLViewController = controller;
    sGLView = view;

#if defined(__IPHONE_3_0)
    if( _ios30orNewer )
        controller.wantsFullScreenLayout = TRUE;
#endif

    controller.view = view;

    [view addSubview:_splashView];
    CreateActivityIndicator(_splashView);

    // add only now so controller have chance to reorient *all* added views
    [_window addSubview:view];
    if( [_window respondsToSelector:@selector(rootViewController)] )
        _window.rootViewController = controller;

    [_window bringSubviewToFront: _splashView];

    _autorotEnableHandling = true;
    [[NSNotificationCenter defaultCenter] postNotificationName: UIDeviceOrientationDidChangeNotification object: [UIDevice currentDevice]];

#ifdef __IPHONE_5_0
    if(_ios50orNewer)
        [UIViewController attemptRotationToDeviceOrientation];
#endif

    // on pre-ios6 we would reorient everything already
    if(_curOrientation == kScreenOrientationUnknown)
    {
        NSString* initialOrientation = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIInterfaceOrientation"];
        if( [initialOrientation isEqualToString: @"UIInterfaceOrientationPortrait"] == YES )
            _curOrientation = portrait;
        else if( [initialOrientation isEqualToString: @"UIInterfaceOrientationPortraitUpsideDown"] == YES )
            _curOrientation = portraitUpsideDown;
        else if( [initialOrientation isEqualToString: @"UIInterfaceOrientationLandscapeLeft"] == YES )
            _curOrientation = landscapeRight;
        else if( [initialOrientation isEqualToString: @"UIInterfaceOrientationLandscapeRight"] == YES )
            _curOrientation = landscapeLeft;

        if(_curOrientation == kScreenOrientationUnknown)
        {
            // we started with autorotation. On pre-ios6 we will start in portrait and will be reoriented later
            _curOrientation = portrait;
            if( [controller respondsToSelector:@selector(interfaceOrientation)] )
                _curOrientation = ConvertToUnityScreenOrientation(controller.interfaceOrientation,0);
        }
    }

    _splashView.image = [UIImage imageNamed:SplashViewImage(ConvertToIosScreenOrientation(_curOrientation))];

    UnitySetScreenOrientation(_curOrientation);
    if(_curOrientation != portrait)
    {
        OrientTo(_curOrientation);
        // force splash orientation here too for phone-like devices
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
        {
            CGRect rect  = [[UIScreen mainScreen] bounds];

            // in case of landscape we want to rotate *back*
            if( _curOrientation == landscapeLeft || _curOrientation == landscapeRight )
            {
                _splashView.transform = TransformForOrientation(_curOrientation == landscapeRight ? landscapeLeft : landscapeRight);
                _splashView.center    = CGPointMake(rect.size.height/2, rect.size.width/2);
            }
            else
            {
                _splashView.transform = TransformForOrientation(_curOrientation);
                _splashView.center    = CGPointMake(rect.size.width/2, rect.size.height/2);
            }
            _splashView.bounds    = rect;
        }
    }


    // reposition activity indicator after we rotated views
    if (_activityIndicator)
        _activityIndicator.center = CGPointMake([_splashView bounds].size.width/2, [_splashView bounds].size.height/2);

    int openglesApi =
#if defined(__IPHONE_3_0) && USE_OPENGLES20_IF_AVAILABLE
    kEAGLRenderingAPIOpenGLES2;
#else
    kEAGLRenderingAPIOpenGLES1;
#endif

    for (; openglesApi >= kEAGLRenderingAPIOpenGLES1 && !_context; --openglesApi)
    {
        if (!UnityIsRenderingAPISupported(openglesApi))
            continue;

        _context = [[EAGLContext alloc] initWithAPI:openglesApi];
    }

    if (!_context)
        return false;

    if (![EAGLContext setCurrentContext:_context]) {
        _context = 0;
        return false;
    }

    const GLuint colorFormat = UnityUse32bitDisplayBuffer() ? GL_RGBA8_OES : GL_RGB565_OES;

    if (!CreateWindowSurface(view, colorFormat, GL_DEPTH_COMPONENT16_OES, UnityGetDesiredMSAASampleCount(MSAA_DEFAULT_SAMPLE_COUNT), NO, &_surface)) {
        return false;
    }

    glViewport(0, 0, _surface.w, _surface.h);
    [_window makeKeyAndVisible];
    [view release];

    *window = _window;
    *screenWidth = _surface.w;
    *screenHeight = _surface.h;
    *openglesVersion = _context.API;

    _glesContextCreated = true;

    return true;
}

UIInterfaceOrientation
ConvertToIosScreenOrientation(ScreenOrientation orient)
{
    switch( orient )
    {
        case portrait:              return UIInterfaceOrientationPortrait;
        case portraitUpsideDown:    return UIInterfaceOrientationPortraitUpsideDown;
        // landscape left/right have switched values in device/screen orientation
        // though unity docs are adjusted with device orientation values, so swap here
        case landscapeLeft:         return UIInterfaceOrientationLandscapeRight;
        case landscapeRight:        return UIInterfaceOrientationLandscapeLeft;

        // shouldn't got there, just shutting up compiler
        default:                    return UIInterfaceOrientationPortrait;
    }

    return UIInterfaceOrientationPortrait;
}

bool
OrientationWillChangeSurfaceExtents( ScreenOrientation prevOrient, ScreenOrientation targetOrient )
{
    bool prevLandscape   = ( prevOrient == landscapeLeft || prevOrient == landscapeRight );
    bool targetLandscape = ( targetOrient == landscapeLeft || targetOrient == landscapeRight );

    return( prevLandscape != targetLandscape );
}

CGRect ContentRectForOrientation( ScreenOrientation orient )
{
    static CGRect   contentRect[kScreenOrientationCount];
    static bool     inited = false;

    if( !inited )
    {
        CGRect screenRect       = [[UIScreen mainScreen] bounds];
        CGRect flipScreenRect   = CGRectMake(screenRect.origin.y, screenRect.origin.x, screenRect.size.height, screenRect.size.width);

        contentRect[portrait]           = screenRect;
        contentRect[portraitUpsideDown] = screenRect;
        contentRect[landscapeLeft]      = flipScreenRect;
        contentRect[landscapeRight]     = flipScreenRect;

        inited = true;
    }

    return contentRect[orient];
}

void OrientTo(int requestedOrient_)
{
    ScreenOrientation requestedOrient = (ScreenOrientation)requestedOrient_;

    extern bool _glesContextCreated;
    extern bool _unityLevelReady;

    if(_unityLevelReady)
        UnityFinishRendering();

    EAGLView* view = (EAGLView*)UnityGetGLView();
    [CATransaction begin];
    {
        UnityKeyboardOrientationStep1();
        view.transform  = TransformForOrientation(requestedOrient);
        view.bounds     = ContentRectForOrientation(requestedOrient);

        [UIApplication sharedApplication].statusBarOrientation = ConvertToIosScreenOrientation(requestedOrient);

        UnitySetScreenOrientation(requestedOrient);
        if( _glesContextCreated && OrientationWillChangeSurfaceExtents(_curOrientation, requestedOrient) )
        {
            DestroySurface(&_surface);
            CreateSurface(view, &_surface);

            // seems like ios sometimes got confused about abrupt swap chain destroy
            // draw 2 times to fill both buffers
            // present only once to make sure correct image goes to CA
            _skipPresent = true;
            {
                UnityPlayerLoop();
                UnityPlayerLoop();
                UnityFinishRendering();
            }
            _skipPresent = false;

            PresentSurface(&_surface);
        }
    }
    [CATransaction commit];

    [CATransaction begin];
    UnityKeyboardOrientationStep2();
    [CATransaction commit];

    _curOrientation = requestedOrient;
}

// use it if you need to request native orientation change
// it is expected to be used with autorotation
// useful when you want to change unity orientation from overlaid view controller
void RequestNativeOrientation(int targetOrient)
{
    _nativeRequestedOrientation = (ScreenOrientation)targetOrient;
}

void CheckOrientationRequest()
{
    ScreenOrientation requestedOrient = UnityRequestedScreenOrientation();
    if(requestedOrient == autorotation)
    {
        if(_ios50orNewer && _shouldAttemptReorientation)
        {
            [UIViewController attemptRotationToDeviceOrientation];
            _shouldAttemptReorientation = false;
        }
    }

    if(_nativeRequestedOrientation != kScreenOrientationUnknown)
    {
        if(_nativeRequestedOrientation != _curOrientation)
            OrientTo(_nativeRequestedOrientation);
        _nativeRequestedOrientation = kScreenOrientationUnknown;
    }
    else if(requestedOrient != autorotation)
    {
        if(requestedOrient != _curOrientation)
            OrientTo(requestedOrient);
    }
}


void NotifyFramerateChange(int targetFPS)
{
    if( targetFPS <= 0 )
        targetFPS = 60;

#if USE_DISPLAY_LINK_IF_AVAILABLE
    if (_displayLink)
    {
        int animationFrameInterval = (60.0 / (targetFPS));
        if (animationFrameInterval < 1)
            animationFrameInterval = 1;

        [_displayLink setFrameInterval:animationFrameInterval];
    }
#endif
#if FALLBACK_LOOP_TYPE == NSTIMER_BASED_LOOP
    if (_displayLink == 0 && _timer)
        _need_recreate_timer = true;
#endif
}

void NotifyAutoOrientationChange()
{
    _shouldAttemptReorientation = true;
}



// --- AppController --------------------------------------------------------------------
//


@implementation AppController

@synthesize audioController = audioController_;

- (void) registerAccelerometer
{
    // NOTE: work-around for accelerometer sometimes failing to register (presumably on older devices)
    // set accelerometer delegate to nil first
    // work-around reported by Brian Robbins

    [[UIAccelerometer sharedAccelerometer] setDelegate:nil];
    int frequency = UnityGetAccelerometerFrequency();

    if (frequency > 0)
    {
        const float accelerometerFrequency = frequency;
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / accelerometerFrequency)];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    }
}

- (void) RepaintDisplayLink
{
#if USE_DISPLAY_LINK_IF_AVAILABLE
    [_displayLink setPaused: YES];

    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kInputProcessingTime, TRUE) == kCFRunLoopRunHandledSource)
        ;

    [_displayLink setPaused: NO];
    [self Repaint];
#endif
}

- (void) Repaint
{
    if(_didResignActive)
        return;

    if( _surface.renderbuffer == 0 )
    {
        CreateSurface((EAGLView*)UnityGetGLView(), &_surface);

        // to avoid black screen creeping in - redraw once (second time + present will be in normal Repaint flow)
        _skipPresent = true;
        UnityPlayerLoop();
        UnityFinishRendering();
        _skipPresent = false;
    }

    Profiler_UnityLoopStart();

    UnityInputProcess();
    UnityPlayerLoop();

    Profiler_UnityLoopEnd();
    CheckOrientationRequest();

    if (UnityGetAccelerometerFrequency() > 0 && (!_accelerometerIsActive || ([UIAccelerometer sharedAccelerometer].delegate == nil)))
    {
        static int frameCounter = 0;
        if (frameCounter <= 0)
        {
            // NOTE: work-around for accelerometer sometimes failing to register (presumably on older devices)
            // sometimes even Brian Robbins work-around doesn't help
            // then we will try to register accelerometer every N frames until we succeed

            printf_console("-> force accelerometer registration\n");
            [self registerAccelerometer];
            frameCounter = 90; // try every ~3 seconds
        }
        --frameCounter;
    }

#if FALLBACK_LOOP_TYPE == NSTIMER_BASED_LOOP
    if (_displayLink == 0 && _timer && _need_recreate_timer)
    {
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / (UnityGetTargetFPS() * kThrottleFPS)) target:self selector:@selector(Repaint) userInfo:nil repeats:YES];

        _need_recreate_timer = false;
    }
#endif

}

- (void) startRendering
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

#if FALLBACK_LOOP_TYPE == THREAD_BASED_LOOP
    const double OneMillisecond = 1.0 / 1000.0;
    for (;;)
    {
        const double SecondsPerFrame = 1.0 / (float)UnityGetTargetFPS();
        const double frameStartTime  = (double)CFAbsoluteTimeGetCurrent();
        [self performSelectorOnMainThread:@selector(Repaint) withObject:nil waitUntilDone:YES];

        double secondsToProcessEvents = SecondsPerFrame - (((double)CFAbsoluteTimeGetCurrent()) - frameStartTime);
        // if we run considerably slower than desired framerate anyhow
        // then we should sleep for a while leaving OS some room to process events
        if (secondsToProcessEvents < -OneMillisecond)
            secondsToProcessEvents = OneMillisecond;
        if (secondsToProcessEvents > 0)
            [NSThread sleepForTimeInterval:secondsToProcessEvents];
    }

#elif FALLBACK_LOOP_TYPE == EVENT_PUMP_BASED_LOOP

    int eventLoopTimeOuts = 0;
    const double SecondsPerFrameToProcessEvents = 0.001 * (double)kMillisecondsPerFrameToProcessEvents;
    for (;;)
    {
        const double SecondsPerFrame = 1.0 / (float)UnityGetTargetFPS();
        const double frameStartTime  = (double)CFAbsoluteTimeGetCurrent();
        [self Repaint];

        if (kMillisecondsPerFrameToProcessEvents <= 0)
        {
            while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
        }
        else
        {
            double secondsToProcessEvents = SecondsPerFrame - (((double)CFAbsoluteTimeGetCurrent()) - frameStartTime);
            if(secondsToProcessEvents < SecondsPerFrameToProcessEvents)
                secondsToProcessEvents = SecondsPerFrameToProcessEvents;

            if (CFRunLoopRunInMode(kCFRunLoopDefaultMode, secondsToProcessEvents, FALSE) == kCFRunLoopRunTimedOut)
                ++eventLoopTimeOuts;
        }
    }

#endif

    [pool release];
}

- (void) prepareRunLoop
{
    UnityLoadApplication();
    Profiler_InitProfiler();
    InitGLES();

    _unityLevelReady = true;

    if( _activityIndicator )
        [_activityIndicator stopAnimating];
    RemoveSplashScreen();

    [[NSNotificationCenter defaultCenter] postNotificationName: UIDeviceOrientationDidChangeNotification object: [UIDevice currentDevice]];

    _displayLink = nil;
#if USE_DISPLAY_LINK_IF_AVAILABLE
    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
    // class is used as fallback when it isn't available.
    if (_ios31orNewer)
    {
        // Frame interval defines how many display frames must pass between each time the
        // display link fires.
        int animationFrameInterval = 60.0 / (float)UnityGetTargetFPS();
        assert(animationFrameInterval >= 1);

        _displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(RepaintDisplayLink)];
        [_displayLink setFrameInterval:animationFrameInterval];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
#endif

    if (_displayLink == nil)
    {
#if FALLBACK_LOOP_TYPE == NSTIMER_BASED_LOOP
        _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / (UnityGetTargetFPS() * kThrottleFPS)) target:self selector:@selector(Repaint) userInfo:nil repeats:YES];
#endif
    }

    [self registerAccelerometer];

    KeyboardOnScreen::Init();

    if (_displayLink == nil)
    {
#if FALLBACK_LOOP_TYPE == THREAD_BASED_LOOP
        [NSThread detachNewThreadSelector:@selector(startRendering) toTarget:self withObject:nil];
#elif FALLBACK_LOOP_TYPE == EVENT_PUMP_BASED_LOOP
        [self performSelectorOnMainThread:@selector(startRendering) withObject:nil waitUntilDone:NO];
#endif
    }

    // immediately render 1st frame in order to avoid occasional black screen
    // we do it twice to fill both buffers with meaningful contents.
    // set proper orientation right away?
    [self Repaint];
    [self Repaint];
}


- (void) startUnity:(UIApplication*)application
{
    if( [ [[UIDevice currentDevice] systemVersion] compare: @"3.0" options: NSNumericSearch ] != NSOrderedAscending )
        _ios30orNewer = true;

    if( [ [[UIDevice currentDevice] systemVersion] compare: @"3.1" options: NSNumericSearch ] != NSOrderedAscending )
        _ios31orNewer = true;

    if( [ [[UIDevice currentDevice] systemVersion] compare: @"4.3" options: NSNumericSearch ] != NSOrderedAscending )
        _ios43orNewer = true;

    if( [ [[UIDevice currentDevice] systemVersion] compare: @"5.0" options: NSNumericSearch ] != NSOrderedAscending )
        _ios50orNewer = true;

    if( [ [[UIDevice currentDevice] systemVersion] compare: @"6.0" options: NSNumericSearch ] != NSOrderedAscending )
        _ios60orNewer = true;

    char const* appPath = [[[NSBundle mainBundle] bundlePath]UTF8String];
    UnityInitApplication(appPath);

    if( _activityIndicator )
        [_activityIndicator startAnimating];

    [self performSelector:@selector(prepareRunLoop) withObject:nil afterDelay:0.1];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return   (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
           | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
}

- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    UnitySendLocalNotification(notification);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    UnitySendRemoteNotification(userInfo);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    UnitySendDeviceToken(deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    UnitySendRemoteNotificationError(error);
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    printf_console("-> applicationDidFinishLaunching()\n");
    // get local notification
    if (&UIApplicationLaunchOptionsLocalNotificationKey != nil)
    {
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (notification)
        {
            UnitySendLocalNotification(notification);
        }
    }

    // get remote notification
    if (&UIApplicationLaunchOptionsRemoteNotificationKey != nil)
    {
        NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (notification)
        {
            UnitySendRemoteNotification(notification);
        }
    }

    if ([UIDevice currentDevice].generatesDeviceOrientationNotifications == NO)
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    [self startUnity:application];

    self.audioController = [[[PdAudioController alloc] init] autorelease];
    [self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:YES mixingEnabled:NO];
    
    [self.audioController configureTicksPerBuffer:128];
    
    [PdBase openFile:@"main.pd" path:[[NSBundle mainBundle] resourcePath]];
    [self.audioController setActive:YES];
    [self.audioController print];
    
    
    return NO;
}

// For iOS 4
// Callback order:
//   applicationDidResignActive()
//   applicationDidEnterBackground()
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    printf_console("-> applicationDidEnterBackground()\n");
}

// For iOS 4
// Callback order:
//   applicationWillEnterForeground()
//   applicationDidBecomeActive()
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    printf_console("-> applicationWillEnterForeground()\n");
}

- (void) applicationDidBecomeActive:(UIApplication*)application
{
    printf_console("-> applicationDidBecomeActive()\n");
    if (_didResignActive)
    {
        UnityPause(false);
    }

    _didResignActive = NO;
}

- (void) applicationWillResignActive:(UIApplication*)application
{
    printf_console("-> applicationWillResignActive()\n");
    UnityPause(true);

    _didResignActive = YES;
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    printf_console("WARNING -> applicationDidReceiveMemoryWarning()\n");
}

- (void) applicationWillTerminate:(UIApplication*)application
{
    printf_console("-> applicationWillTerminate()\n");

    Profiler_UninitProfiler();

    UnityCleanup();
}

- (void) dealloc
{
    DestroySurface(&_surface);
    [_context release];
    _context = nil;

    self.audioController = nil;
    
    [_window release];
    [super dealloc];
}

- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
    UnityDidAccelerate(acceleration.x, acceleration.y, acceleration.z, acceleration.timestamp);
    _accelerometerIsActive = YES;
}

@end

@implementation UnityViewController
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _curOrientation = ConvertToUnityScreenOrientation(toInterfaceOrientation, 0);
    [[NSNotificationCenter defaultCenter] postNotificationName:kUnityViewWillRotate object:self];

    if(_splashView || !UnityUseOSAutorotation())
        [UIView setAnimationsEnabled:NO];

    if(_splashView && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
        _splashView.image = [UIImage imageNamed:SplashViewImage(toInterfaceOrientation)];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if( _splashView )
    {
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
        {
            CGRect rect  = [[UIScreen mainScreen] bounds];

            // in case of landscape we want to rotate *back*
            if( _curOrientation == landscapeLeft || _curOrientation == landscapeRight )
            {
                _splashView.transform = TransformForOrientation(_curOrientation == landscapeRight ? landscapeLeft : landscapeRight);
                _splashView.center    = CGPointMake(rect.size.height/2, rect.size.width/2);
            }
            else
            {
                _splashView.transform = TransformForOrientation(_curOrientation);
                _splashView.center    = CGPointMake(rect.size.width/2, rect.size.height/2);
            }
            _splashView.bounds    = rect;
        }
    }

    if (_activityIndicator)
        _activityIndicator.center = CGPointMake([self.view bounds].size.width/2, [self.view bounds].size.height/2);

    UnitySetScreenOrientation(_curOrientation);
    if( OrientationWillChangeSurfaceExtents( ConvertToUnityScreenOrientation(fromInterfaceOrientation,0), _curOrientation ) )
    {
        if( _glesContextCreated )
        {
            DestroySurface(&_surface);
            CreateSurface((EAGLView*)UnityGetGLView(), &_surface);

            if(_unityLevelReady)
            {
                _skipPresent = true;
                UnityPlayerLoop();
                UnityPlayerLoop();
                UnityFinishRendering();
                _skipPresent = false;
                PresentSurface(&_surface);
            }
        }
    }

    if( _splashView || !UnityUseOSAutorotation() )
        [UIView setAnimationsEnabled:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:kUnityViewDidRotate object:self];
}

// if on ios6 sdk - start old-school controller
#ifdef __IPHONE_6_0
@end
@implementation UnityViewController_preIOS6
#endif // __IPHONE_6_0

// this is part of old-school controller
// it goes for UnityViewController_preIOS6 (ios6 sdk) or to our own on older sdk
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    EnabledOrientation targetAutorot   = kAutorotateToPortrait;
    ScreenOrientation  targetOrient    = ConvertToUnityScreenOrientation(interfaceOrientation, &targetAutorot);
    ScreenOrientation  requestedOrientation = UnityRequestedScreenOrientation();

    if (requestedOrientation != autorotation)
        return (requestedOrientation == targetOrient);

    return UnityIsOrientationEnabled(targetAutorot);
}

// here goes new-style controller - only of built with ios6 sdk
#ifdef __IPHONE_6_0
@end

@implementation UnityViewController_IOS6
- (BOOL)shouldAutorotate
{
    return (UnityRequestedScreenOrientation() == autorotation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger ret = 0;
    if( UnityIsOrientationEnabled(kAutorotateToPortrait) )              ret |= (1 << UIInterfaceOrientationPortrait);
    if( UnityIsOrientationEnabled(kAutorotateToPortraitUpsideDown) )    ret |= (1 << UIInterfaceOrientationPortraitUpsideDown);
    if( UnityIsOrientationEnabled(kAutorotateToLandscapeLeft) )         ret |= (1 << UIInterfaceOrientationLandscapeRight);
    if( UnityIsOrientationEnabled(kAutorotateToLandscapeRight) )        ret |= (1 << UIInterfaceOrientationLandscapeLeft);

    return ret;
}
#endif

@end


@implementation EAGLView

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id) initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])) {
        [self setMultipleTouchEnabled:YES];
        [self setExclusiveTouch:YES];
    }
    return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UnitySendTouchesBegin(touches, event);
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UnitySendTouchesEnded(touches, event);
}
- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    UnitySendTouchesCancelled(touches, event);
}
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UnitySendTouchesMoved(touches, event);
}

@end


// --- Video --------------------------------------------------------------------
//


#import <MediaPlayer/MediaPlayer.h>

// video view controller
@interface UnityVideoViewController : MPMoviePlayerViewController
{
    ScreenOrientation  _targetOrient;
}
@end

#ifdef __IPHONE_6_0
@interface UnityVideoViewController_preIOS6 : UnityVideoViewController {}
@end

@interface UnityVideoViewController_IOS6 : UnityVideoViewController {}
@end
#endif


@implementation UnityVideoViewController

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    RequestNativeOrientation(_targetOrient);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _targetOrient = ConvertToUnityScreenOrientation(toInterfaceOrientation, 0);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        NSArray *array = touch.gestureRecognizers;

        for (UIGestureRecognizer *gesture in array)
        {
            if (gesture.enabled &&
                [gesture isMemberOfClass:[UIPinchGestureRecognizer class]])
            {
                gesture.enabled = NO;
            }
        }
    }
}

#ifdef __IPHONE_6_0
@end
@implementation UnityVideoViewController_preIOS6
#endif // __IPHONE_6_0

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    EnabledOrientation targetAutorot = kAutorotateToPortrait;
    ScreenOrientation  targetRot = ConvertToUnityScreenOrientation(interfaceOrientation, &targetAutorot);
    ScreenOrientation  requestedOrientation = UnityRequestedScreenOrientation();

    bool shouldRot = requestedOrientation == autorotation ? UnityIsOrientationEnabled(targetAutorot)
                                                          : targetRot == requestedOrientation;

    return shouldRot ? YES:NO;
}

// here goes new-style controller - only of built with ios6 sdk
#ifdef __IPHONE_6_0
@end

@implementation UnityVideoViewController_IOS6
- (BOOL)shouldAutorotate
{
    return (UnityRequestedScreenOrientation() == autorotation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger ret = 0;
    if( UnityIsOrientationEnabled(kAutorotateToPortrait) )              ret |= (1 << UIInterfaceOrientationPortrait);
    if( UnityIsOrientationEnabled(kAutorotateToPortraitUpsideDown) )    ret |= (1 << UIInterfaceOrientationPortraitUpsideDown);
    if( UnityIsOrientationEnabled(kAutorotateToLandscapeLeft) )         ret |= (1 << UIInterfaceOrientationLandscapeRight);
    if( UnityIsOrientationEnabled(kAutorotateToLandscapeRight) )        ret |= (1 << UIInterfaceOrientationLandscapeLeft);

    return ret;
}
#endif

@end


