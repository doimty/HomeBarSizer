// HomeBarSizer — iOS 15+ roothide 适配版
// 逆向自 com.imkpatil.homebarsizer 1.1 (2019, 源码已丢失), 逻辑重建 + 跨版本兼容
// prefs: 域 com.imkpatil.homebarsizer, 键 TwkEnabled/BarWidth/BarHeight/BarRadius
// 兼容性说明: 不存在的 selector 对应 hook 会静默失效(MSHookMessageEx 找不到方法即跳过), 不会崩溃

#import <substrate.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

static BOOL IsEnabled = YES;
static double HomeBarWidth = 134.0;
static double HomeBarHeight = 5.0;
static double HomeBarRadius = 3.0;

@interface FBSystemService : NSObject
+ (id)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg1;
@end

%hook MTLumaDodgePillSettings

// --- 读路径强制 (iOS 12-17 全部存在) ---
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
- (long long)cornerMask {
    if (IsEnabled) return (long long)HomeBarRadius;
    return %orig;
}

// --- 写路径强制 (原版核心机制, iOS 15/16 现代 tweak 验证有效) ---
- (void)setMinWidth:(double)arg1 {
    %orig(IsEnabled ? (int)HomeBarWidth : arg1);
}
- (void)setMaxWidth:(double)arg1 {
    %orig(IsEnabled ? (int)HomeBarWidth : arg1);
}
- (void)setHeight:(double)arg1 {
    %orig(IsEnabled ? (int)HomeBarHeight : arg1);
}
- (void)setCornerRadius:(double)arg1 {
    %orig(IsEnabled ? (int)HomeBarRadius : arg1);
}
- (void)setCornerMask:(long long)arg1 {
    %orig(IsEnabled ? (long long)HomeBarRadius : arg1);
}
%end

%hook MTLumaDodgePillView

// iOS 16/17 签名: +suggestedSizeForContentWidth:withSettings:
+ (CGSize)suggestedSizeForContentWidth:(double)width withSettings:(id)settings {
    if (IsEnabled) return CGSizeMake(HomeBarWidth, HomeBarHeight);
    return %orig;
}

// iOS 14/15 签名: -suggestedSizeForContentWidth:
- (CGSize)suggestedSizeForContentWidth:(double)width {
    if (IsEnabled) return CGSizeMake(HomeBarWidth, HomeBarHeight);
    return %orig;
}

// 全版本兜底: sizeThatFits:
- (CGSize)sizeThatFits:(CGSize)size {
    if (IsEnabled) return CGSizeMake(HomeBarWidth, HomeBarHeight);
    return %orig;
}
%end

static void reloadSettings(void) {
    CFStringRef domain = CFSTR("com.imkpatil.homebarsizer");
    CFPreferencesAppSynchronize(domain);

    id enabledVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("TwkEnabled"), domain);
    if (enabledVal && [enabledVal respondsToSelector:@selector(boolValue)])
        IsEnabled = [enabledVal boolValue];

    id widthVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("BarWidth"), domain);
    if (widthVal && [widthVal respondsToSelector:@selector(doubleValue)])
        HomeBarWidth = [widthVal doubleValue];

    id heightVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("BarHeight"), domain);
    if (heightVal && [heightVal respondsToSelector:@selector(doubleValue)])
        HomeBarHeight = [heightVal doubleValue];

    id radiusVal = (__bridge_transfer id)CFPreferencesCopyAppValue(CFSTR("BarRadius"), domain);
    if (radiusVal && [radiusVal respondsToSelector:@selector(doubleValue)])
        HomeBarRadius = [radiusVal doubleValue];
}

static void respring(CFNotificationCenterRef center, void *observer, CFStringRef name,
                     const void *object, CFDictionaryRef userInfo) {
    [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        (CFNotificationCallback)reloadSettings, CFSTR("com.imkpatil.homebarsizer.settingschanged"),
        NULL, CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        respring, CFSTR("com.imkpatil.homebarsizer.respring"),
        NULL, CFNotificationSuspensionBehaviorCoalesce);
    reloadSettings();
}