#import "ViewController.h"
#import "IronSource/IronSource.h"
#import "LoopMeUnitedSDK/LoopMeSDK.h"
#import "ISLoopmeCustomInterstitial.h"

#define USERID @"siok"
#define APPKEY @"127d76565"
#define rewardedAppKey @"c0b76339a2"
#define interstitialVideoAppKey @"dafa602ab1"
#define interstitialBannerAppKey @"aefab282dd"
#define banner_320x50_AppKey @"3ae8c26803"
#define banner_300x250_AppKey @"f5826542ae"
#define banner_728x90_AppKey @"2225d74ea9"

@interface ViewController () <LevelPlayRewardedVideoManualDelegate ,LevelPlayInterstitialDelegate>
@property (weak, nonatomic) IBOutlet UIButton *loadInterstitial;
@property (weak, nonatomic) IBOutlet UIButton *showInterstitial;
@property (weak, nonatomic) IBOutlet UIButton *loadRewarded;
@property (weak, nonatomic) IBOutlet UIButton *showRewarded;
@property (weak, nonatomic) IBOutlet ISBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // register delegate
    //[IronSource setLevelPlayRewardedVideoDelegate:self];
    [IronSource setLevelPlayRewardedVideoManualDelegate:self];
    [IronSource setLevelPlayInterstitialDelegate:self];
    [IronSource setLevelPlayBannerDelegate:self];
    
    // initialize LoopMe SDK
    [[LoopMeSDK shared] initSDKFromRootViewController:self completionBlock:^(BOOL success, NSError *error) {
        if (!success) {NSLog(@"ironSource LoopMe %@", error);}
        else {NSLog(@"Loopme sdk initialized");}
    }];
    
    // initialize Ironsource SDK
    [IronSource setUserId:USERID];
    [IronSource initWithAppKey:APPKEY delegate:self];
    
    // add IS integration helper
    [ISIntegrationHelper validateIntegration];
    
    //disable button before load
    _showInterstitial.enabled = NO;
    _showRewarded.enabled = NO;
    
    //add SDK version info
    NSString *ISversion = [IronSource sdkVersion];
    NSString *LMversion = [LoopMeSDK version];
    NSString *info = [NSString stringWithFormat:@"IS SDK: v%@; LoopMeSDK: v%@", ISversion, LMversion];
    self.versionLabel.text = info;
    
}

/// IS SDK initialized complete
- (void)initializationDidComplete {
    NSLog(@"Ironsource SDK initialized");
}

/// when load button pressed
- (IBAction)loadInterstitial:(UIButton *)sender {
    //load LoopMe app key
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    if (standardUserDefaults) {
        [standardUserDefaults setObject:interstitialVideoAppKey forKey:@"LOOPME_INTERSTITIAL"];
        [standardUserDefaults synchronize];
    }
    
    // Load Interstital
    dispatch_async(dispatch_get_main_queue(), ^{
        [IronSource loadInterstitial];
    });
}

/// [ironSource SDK] API: UITHREAD: true [IronSourceSdk loadRewardedVideo] - Rewarded Video is not initiated with manual load
- (IBAction)loadRewarded:(UIButton *)sender {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:rewardedAppKey forKey:@"LOOPME_REWARDED"];
        [standardUserDefaults synchronize];
    }
    
    [IronSource loadRewardedVideo];
}

- (IBAction)loadBanner:(UIButton *)sender {
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    if (standardUserDefaults) {
        [standardUserDefaults setObject:banner_320x50_AppKey forKey:@"LOOPME_BANNER"];
        [standardUserDefaults synchronize];
    }
    
    [IronSource loadBannerWithViewController:self size:ISBannerSize_BANNER];
}


/// when show button pressed
- (IBAction)showInterstitial:(UIButton *)sender {
    [IronSource showInterstitialWithViewController:self];
}

- (IBAction)showRewarded:(UIButton *)sender {
    [IronSource showRewardedVideoWithViewController:self];
}

/// DELEGATE
- (void)didClick:(ISPlacementInfo *)placementInfo withAdInfo:(ISAdInfo *)adInfo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didCloseWithAdInfo:(ISAdInfo *)adInfo { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didFailToShowWithError:(NSError *)error andAdInfo:(ISAdInfo *)adInfo { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didOpenWithAdInfo:(ISAdInfo *)adInfo { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo withAdInfo:(ISAdInfo *)adInfo { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didFailToLoadWithError:(NSError *)error { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didLoadWithAdInfo:(ISAdInfo *)adInfo { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([adInfo.ad_unit isEqual:@"interstitial"]) {
        _showInterstitial.enabled = YES;
    } else {
        _showRewarded.enabled = YES;
    }
    
}

- (void)didClickWithAdInfo:(ISAdInfo *)adInfo { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)didShowWithAdInfo:(ISAdInfo *)adInfo { 
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

/// REWARDED DELEGATE
- (void)hasAdAvailableWithAdInfo:(ISAdInfo *)adInfo{
    _showRewarded.enabled = YES;
    NSLog(@"Rewarded ad loaded");
}

- (void)hasNoAvailableAd{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

/// Banner delegate
- (void)didLoad:(ISBannerView *)bannerView withAdInfo:(ISAdInfo *)adInfo{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
       self.bannerView = bannerView;
        if (@available(iOS 11.0, *)) {
           [self.bannerView setCenter:CGPointMake(self.view.center.x,self.view.frame.size.height - (self.bannerView.frame.size.height/2.0) - self.view.safeAreaInsets.bottom)]; // safeAreaInsets is available from iOS 11.0
       } else {
           [self.bannerView setCenter:CGPointMake(self.view.center.x,self.view.frame.size.height - (self.bannerView.frame.size.height/2.0))];
       }
       [self.view addSubview:self.bannerView];
   });
}

@end
