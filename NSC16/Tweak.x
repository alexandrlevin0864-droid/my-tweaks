#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *const kPrefsId = @"com.example.nsc16";

static BOOL NCIsEnabled(void) {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.example.nsc16.plist"];
    if (!prefs) prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/jb/var/mobile/Library/Preferences/com.example.nsc16.plist"];
    if (!prefs) {
        id v = [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled"];
        return (v == nil) ? YES : [v boolValue];
    }
    NSNumber *en = prefs[@"enabled"];
    return (en == nil) ? YES : en.boolValue;
}

static UIWindow *nightstandWindow = nil;
static UILabel *clockLabel = nil;
static NSTimer *clockTimer = nil;

static BOOL NCLsCharging(void) {
    return [UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging
        || [UIDevice currentDevice].batteryState == UIDeviceBatteryStateFull;
}

static BOOL NCLsHorizontal(void) {
    UIDeviceOrientation o = [UIDevice currentDevice].orientation;
    return o == UIDeviceOrientationLandscapeLeft || o == UIDeviceOrientationLandscapeRight;
}

#define NCLog(fmt, ...) NSLog(@"[NSC16] " fmt, ##__VA_ARGS__)

static void NCUpdateClockText(void) {
    if (!clockLabel) return;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"ru_RU"];
    fmt.dateFormat = @"HH:mm";
    clockLabel.text = [fmt stringFromDate:[NSDate date]];
    // подпись с датой и зарядом
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
    day.locale = [NSLocale localeWithLocaleIdentifier:@"ru_RU"];
    day.dateFormat = @"EEEE, d MMMM";
    if (!clockLabel.tag) {
        UILabel *sub = [[UILabel alloc] initWithFrame:CGRectZero];
        sub.tag = 99;
        sub.textColor = [UIColor whiteColor];
        sub.font = [UIFont monospacedDigitSystemFontOfSize:22 weight:UIFontWeightMedium];
        sub.textAlignment = NSTextAlignmentCenter;
        [clockLabel.superview addSubview:sub];
    }
    UILabel *sub = (UILabel *)[clockLabel.superview viewWithTag:99];
    sub.text = [day stringFromDate:[NSDate date]];
    sub.frame = CGRectMake(0, clockLabel.frame.origin.y + 160, clockLabel.superview.frame.size.width, 40);
}

static void NCDestroyWindow(void) {
    [clockTimer invalidate];
    clockTimer = nil;
    [nightstandWindow setHidden:YES];
    nightstandWindow = nil;
    clockLabel = nil;
}

static void NCCreateWindow(void) {
    if (nightstandWindow) return;

    UIWindow *win = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    win.windowLevel = UIWindowLevelStatusBar + 1000;
    win.backgroundColor = [UIColor blackColor];
    win.userInteractionEnabled = NO;
    win.hidden = NO;

    // Пустой контроллер, чтобы окно корректно отрисовалось поверх SB
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor blackColor];
    win.rootViewController = vc;
    [win makeKeyAndVisible];
    [win setHidden:NO];

    UILabel *label = [[UILabel alloc] initWithFrame:win.bounds];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont monospacedDigitSystemFontOfSize:110 weight:UIFontWeightLight];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.5;
    [vc.view addSubview:label];
    clockLabel = label;

    nightstandWindow = win;
    NCUpdateClockText();

    if (!clockTimer) {
        clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     repeats:YES
                                                       block:^(NSTimer *_Nonnull timer) {
            NCUpdateClockText();
        }];
    }
}

static void NCEvaluate(void) {
    BOOL charging = NCLsCharging();
    BOOL hz = NCLsHorizontal();
    NCLog(@"evaluate: charging=%d horizontal=%d batteryState=%ld orient=%ld",
          charging, hz, (long)[UIDevice currentDevice].batteryState,
          (long)[UIDevice currentDevice].orientation);
    if (NCIsEnabled() && charging && hz) {
        NCCreateWindow();
    } else {
        NCDestroyWindow();
    }
}

static void NCOrientationChanged(void) {
    NCEvaluate();
    // центрируем часы при повороте
    dispatch_async(dispatch_get_main_queue(), ^{
        if (clockLabel && nightstandWindow) {
            clockLabel.frame = nightstandWindow.bounds;
            NCUpdateClockText();
        }
    });
}

static void NCSetup(void) {
    NCLog(@"NSSC16 loaded, setting up observers");
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;

    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryStateDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *_) {
        NCEvaluate();
    }];

[[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification
                                                       object:nil
                                                        queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *_) {
        NCOrientationChanged();
    }];

    // Перечитываем настройки при их изменении (переключатель в Настройках)
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification
                                                       object:nil
                                                        queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *_) {
        NCEvaluate();
    }];

    // проверим состояние сразу же при загрузке твика
    NCEvaluate();
}

%ctor {
    // Основной поток, после загрузки SpringBoard
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NCSetup();
    });
}