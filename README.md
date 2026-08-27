# HomeBarSizer (iOS 15+ roothide 适配版)

调节 iOS 底部 HomeBar 的宽度、高度和圆角。

## 背景

原项目 (com.imkpatil.homebarsizer, P2KDev, 2019) 源码已丢失。本仓库基于对 1.1 二进制的完整逆向重建：

- hook `MTLumaDodgePillSettings` 的 `minWidth/maxWidth/height/cornerRadius/cornerMask` 读写路径
- hook `MTLumaDodgePillView` 的三种尺寸 API（`+suggestedSizeForContentWidth:withSettings:` / `-suggestedSizeForContentWidth:` / `-sizeThatFits:`），覆盖 iOS 12-17 全部签名变化，不存在的 selector 自动跳过
- prefs 域 `com.imkpatil.homebarsizer`：`TwkEnabled`(默认开) / `BarWidth`(134) / `BarHeight`(5) / `BarRadius`(3)
- 设置变更走 darwin 通知热更新，无需重启；设置页含「立即重启桌面」按钮

## 构建

roothide scheme，GitHub Actions (macOS 14 / Xcode 15.4 / iPhoneOS 17.5 SDK)，产出 `com.imkpatil.homebarsizer_1.2_iphoneos-arm64e.deb`。

## 文件

- `Tweak.xm` — iOS 15+ 适配实现
- `Tweak.xm.orig-2019` — 原始 1.1 二进制所对应的源码(恢复自 moj3ve/HomeBarSizer 早期 revision)
- `Prefs/` — 中文设置页