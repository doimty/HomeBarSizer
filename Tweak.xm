// HomeBarSizer — iOS 15+ roothide
// prefs: com.imkpatil.homebarsizer / TwkEnabled, BarWidth, BarHeight, BarRadius
// Missing selectors are skipped via %group + class_get*Method before %init.

#import <substrate.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <math.h>

static BOOL IsEnabled = YES;
static double HomeBarWidth = 134.0;
static double HomeBarHeight = 5.0;
static double HomeBarRadius = 3.0;

static const double kWidthMin = 10.0;
static const double kWidthMax = 300.0;
static const double kWidthDefault = 134.0;
static const double kHeightMin = 1.0;
static const double kHeightMax = 100.0;
static const double kHeightDefault = 5.0;
static const double kRadiusMin = 1.0;
static const double kRadiusMax = 10.0;
static const double kRadiusDefault = 3.0;

static double ClampPref(double value, double minValue, double maxValue, double fallback) {
    if (isnan(value) || isinf(value))
        return fallback;
    if (value < minValue)
        return minValue;
    if (value > maxValue)
        return maxValue;
    return value;
}

%group SettingsHooks
%hook MTLumaDodgePillSettings

- (double)minWidth {
    if (IsEnabled) return HomeBarWidth;
    return %orig;
}
- (double)maxWidth {
    if (IsEnabled) return HomeBarWidth;
    return %orig;
}
- (double)height {
    if (IsEnabled) return HomeBarHeight;
    return %orig;
}
- (double)cornerRadius {
    if (IsEnabled) return HomeBarRadius;
    return %orig;
}

- (void)setMinWidth:(double)arg1 {
    %orig(IsEnabled ? HomeBarWidth : arg1);
}
- (void)setMaxWidth:(double)arg1 {
    %orig(IsEnabled ? HomeBarWidth : arg1);
}
- (void)setHeight:(double)arg1 {
    %orig(IsEnabled ? HomeBarHeight : arg1);
}
- (void)setCornerRadius:(double)arg1 {
    %orig(IsEnabled ? HomeBarRadius : arg1);
}
%end
%end

%group SizeClassIOS16
%hook MTLumaDodgePillView
+ (CGSize)suggestedSizeForContentWidth:(double)width withSettings:(id)settings {
    if (IsEnabled) return CGSizeMake(HomeBarWidth, HomeBarHeight);
    return %orig;
}
%end
%end

%group SizeInstanceIOS15
%hook MTLumaDodgePillView
- (CGSize)suggestedSizeForContentWidth:(double)width {
    if (IsEnabled) return CGSizeMake(HomeBarWidth, HomeBarHeight);
    return %orig;
}
%end
%end

%group SizeFits
%hook MTLumaDodgePillView
- (CGSize)sizeThatFits:(CGSize)size {
    if (IsEnabled) return CGSizeMake(HomeBarWidth, HomeBarHeight);
    return %orig;
}
%end
%end

static void reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name,
                           const void *object, CFDictionaryRef userInfo) {
    (void)center;
    (void)observer;
    (void)name;
    (void)object;
    (void)userInfo;

    CFStringRef domain = CFSTR("com.imkpatil.homebarsizer");
    CFPreferencesAppSynchronize(domain);

    id enabledVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("TwkEnabled"), domain);
    if (enabledVal && [enabledVal respondsToSelector:@selector(boolValue)])
        IsEnabled = [enabledVal boolValue];

    id widthVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("BarWidth"), domain);
    if (widthVal && [widthVal respondsToSelector:@selector(doubleValue)])
        HomeBarWidth = ClampPref([widthVal doubleValue], kWidthMin, kWidthMax, kWidthDefault);

    id heightVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("BarHeight"), domain);
    if (heightVal && [heightVal respondsToSelector:@selector(doubleValue)])
        HomeBarHeight = ClampPref([heightVal doubleValue], kHeightMin, kHeightMax, kHeightDefault);

    id radiusVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("BarRadius"), domain);
    if (radiusVal && [radiusVal respondsToSelector:@selector(doubleValue)])
        HomeBarRadius = ClampPref([radiusVal doubleValue], kRadiusMin, kRadiusMax, kRadiusDefault);
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        reloadSettings, CFSTR("com.imkpatil.homebarsizer.settingschanged"),
        NULL, CFNotificationSuspensionBehaviorCoalesce);
    reloadSettings(NULL, NULL, NULL, NULL, NULL);

    if (%c(MTLumaDodgePillSettings))
        %init(SettingsHooks);

    Class view = %c(MTLumaDodgePillView);
    if (view) {
        if (class_getClassMethod(view, @selector(suggestedSizeForContentWidth:withSettings:)))
            %init(SizeClassIOS16);
        if (class_getInstanceMethod(view, @selector(suggestedSizeForContentWidth:)))
            %init(SizeInstanceIOS15);
        %init(SizeFits);
    }
}
