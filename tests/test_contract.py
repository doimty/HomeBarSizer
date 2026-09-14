#!/usr/bin/env python3
"""HomeBarSizer contract checks for the 1.3 hardening pass."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
TWEAK = (ROOT / "Tweak.xm").read_text(encoding="utf-8")
PREFS = (ROOT / "Prefs/HBRootListController.m").read_text(encoding="utf-8")
PREFS_MAKE = (ROOT / "Prefs/Makefile").read_text(encoding="utf-8")
CONTROL = (ROOT / "control").read_text(encoding="utf-8")
CODE_ONLY = "\n".join(
    line for line in TWEAK.splitlines()
    if line.strip() and not line.strip().startswith("//")
)

failures = []


def check(name, cond, detail=""):
    if cond:
        print(f"PASS {name}")
    else:
        failures.append(name)
        print(f"FAIL {name} {detail}")


check("无 Darwin respring 通知", "homebarsizer.respring" not in TWEAK)
check("无 FBSystemService respring", "exitAndRelaunch" not in CODE_ONLY)
check("设置页用 posix_spawn respring", "posix_spawn" in PREFS and "sbreload" in PREFS)
check("Prefs TARGET 钉死 16.5", "iphone:clang:16.5:15.0" in PREFS_MAKE)
check("Prefs 不用 latest SDK", "clang:latest" not in PREFS_MAKE)
check("Author 为 doimty", re.search(r"^Author: doimty$", CONTROL, re.M) is not None)
check("Maintainer 为 doimty", re.search(r"^Maintainer: doimty$", CONTROL, re.M) is not None)
check("Version 1.3.1", re.search(r"^Version: 1.3.1$", CONTROL, re.M) is not None)
check("Icon 用带版本的 HTTPS 地址", "icons/com.imkpatil.homebarsizer-1.3.1.png" in CONTROL)
check("无 cornerMask hook", "cornerMask" not in CODE_ONLY and "setCornerMask" not in CODE_ONLY)
check("setter 不把 double 截成 int", "(int)HomeBar" not in CODE_ONLY)
check("读取后夹紧", "ClampPref" in TWEAK and "kWidthMax" in TWEAK)
check("reloadSettings 五参数原型", re.search(
    r"static void reloadSettings\(CFNotificationCenterRef", TWEAK) is not None)
check("按 selector 分组 hook", "%group SizeClassIOS16" in TWEAK and "%group SizeInstanceIOS15" in TWEAK)
check("class_getClassMethod 守卫", "class_getClassMethod" in TWEAK)
check("无 ezswipe 残留", "ezswipe" not in PREFS.lower())
check("设置页资源有 icon.png", (ROOT / "Prefs/Resources/icon.png").is_file())

if failures:
    raise SystemExit(f"{len(failures)} failed: {failures}")
print("all passed")
