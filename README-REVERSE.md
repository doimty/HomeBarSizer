# HomeBarSizer 1.1 逆向结论 + iOS 15+ 适配方案 (2026-08-27)

## 二进制逆向结论 (com.imkpatil.homebarsizer_1.1.deb, 2019-05 构建)

- 纯 Logos/substrate tweak,代码段仅 784 字节,无自建 ObjC 类,4 个 MSHookMessageEx:
  1. `+[MTLumaDodgePillView suggestedSizeForContentWidth:]` (hook 在 metaclass 上, iOS 12 时代是类方法)
  2. `-[MTLumaDodgePillSettings setMinWidth:]`
  3. `-[MTLumaDodgePillSettings setMaxWidth:]`
  4. `-[MTLumaDodgePillSettings setHeight:]`
- prefs: `com.imkpatil.homebarsizer` 域,键 TwkEnabled(BOOL,默认 YES)/BarWidth(默认 134.0)/BarHeight(默认 5.0)
- 两个 darwin 通知: settingschanged → 重读 prefs; respring → `[[FBSystemService sharedInstance] exitAndRelaunch:YES]`
- 与原项目 moj3ve/HomeBarSizer 源码比对: 二进制 = 更早 revision(master 版多了 getter hook 和 BarRadius/cornerRadius/cornerMask)

## 源码来源
- https://github.com/moj3ve/HomeBarSizer (master, control 版本 1.1.1)
- 用户自己的源码已丢失,此仓库为恢复副本 + 原始 deb

## iOS 15+ 失效原因
1. `+suggestedSizeForContentWidth:` 单参数类方法在 iOS 15+ 不存在:
   - iOS 12: `+suggestedSizeForContentWidth:` (1 参类方法, hook 正确)
   - iOS 14: 变成实例方法 `-suggestedSizeForContentWidth:` (1 参)
   - iOS 16/17: 变成类方法 `+suggestedSizeForContentWidth:withSettings:` (2 参)
   - → 旧 hook 静默失效(MSHookMessageEx 找不到方法)
2. MTLumaDodgePillSettings 的 setter hook 全部依然有效:
   - iOS 12→17 头文件确认 setMinWidth:/setMaxWidth:/setHeight: 始终存在,类始终存在
   - 现代 tweak CornBar (wrp1002, iOS 15/16) hook 的就是同一组 setter → 机制被证实可用
3. 打包层面: 2019 老 substrate 二进制, rootful 路径 /Library/MobileSubstrate + CydiaSubstrate.framework
   - roothide (iOS 15+, arm64e) 上路径不存在 → dyld 直接加载失败
   - arm64e 切片为 2019 老签名,现代全 PAC arm64e 下不可靠 → 必须重编

## 修复方案 (repos/HomeBarSizer/Tweak.xm.iOS15+)
- 保留 MTLumaDodgePillSettings setter hook (核心有效机制) + 增加 getter hook (minWidth/maxWidth/height, master 源码的思路,读路径强制)
- 视图尺寸 hook 全部覆盖:
  - `+suggestedSizeForContentWidth:withSettings:` (iOS 16/17 签名)
  - `-suggestedSizeForContentWidth:` (iOS 14/15 签名)
  - `-sizeThatFits:` (全版本通用兜底)
  - 不存在的 selectors 静默 no-op,不崩
- 重打包: roothide scheme, /var/jb 路径, ellekit substrate 兼容, arm64+arm64e, min iOS 14+
- 云构建基线: GitHub Actions macos-14 + Xcode 15.4 (15F31d) + iPhoneOS 17.5 SDK (沿用 NetworkManagerReborn/Insulation 验证过的基线)
