# 🐛 HybridCapsLock v3.1.1 - Bug Fix Release

**Release Date:** 2025-01-XX  
**Type:** PATCH  
**Status:** Stable

---

## 📋 Overview

Quick patch release fixing notification positioning issue introduced in v3.1.0. This release moves notifications to the expected top-right corner of the screen.

---

## 🐛 Bug Fixes

### **Notification Positioning Fixed**

**Issue:** Notifications were appearing in top-left corner instead of the standard top-right position.

**Root Cause:** 
- TooltipApp v2.1 has a rendering bug when combining `slide_left` animation with `top_right` anchor
- Tooltips were getting cut off or extending beyond screen bounds
- Menus work fine with `top_right` because they don't use slide animation

**Fix Applied:**
- ✅ Notifications now appear in **top_right corner** (expected position)
- ✅ Animation temporarily disabled to avoid rendering issues
- ✅ Proper negative offset for right-side positioning

**Technical Details:**
```ahk
// Before (v3.1.0):
cmd["position"]["anchor"] := "top_left"  // Workaround
cmd["animation"]["type"] := "slide_left" // Active

// After (v3.1.1):
cmd["position"]["anchor"] := "top_right" // Correct position
// Animation disabled temporarily (commented out)
```

**User Impact:**
- ✅ Notifications appear where users expect them (top-right)
- ✅ No more confusion with left-side positioning
- ✅ Consistent with standard notification behavior across applications

**Future Plans:**
- TooltipApp v2.2 will fix `slide_left + top_right` rendering
- Animation will be re-enabled in future release (v3.1.2 or v3.2.0)

---

## 📥 Installation

### New Users

Same as v3.1.0 - Download and extract the portable release:

1. Download `HybridCapsLock-v3.1.1.zip`
2. Extract to your preferred location
3. Run `HybridCapslock.ahk`

### Existing Users (upgrading from v3.1.0)

**Quick update - minimal backup needed:**

```bash
# 1. Backup your custom configs and plugins
#    Only need to backup: ahk/ folder
#    This contains:
#    - ahk/config/ (your settings, keymaps, colorscheme, kanata config)
#    - ahk/plugins/ (your custom plugins)

# Example backup:
cp -r ahk/ ahk_backup_v3.1.0/

# 2. Download HybridCapsLock-v3.1.1.zip

# 3. Extract to your installation folder (overwrite all files)
#    This updates: system/, doc/, img/, init.ahk, etc.

# 4. Restore your custom configs
cp -r ahk_backup_v3.1.0/* ahk/

# 5. Restart HybridCapslock.ahk
```

**What you'll notice:**
- ✅ Notifications now appear in top-right corner (fixed position)
- ✅ No animation (appears instantly - temporary)
- ✅ All your custom keymaps and plugins work the same
- ✅ Everything else unchanged

---

## 📦 What's Included

- **Core System:** All v3.1.0 features
- **TooltipApp v2.1:** Included (self-contained .NET 6)
- **Bug Fix:** Notification positioning corrected
- **Documentation:** Complete English + Spanish docs

---

## 🔧 Requirements

Same as v3.1.0:

- Windows 10/11 (64-bit)
- AutoHotkey v2.0+
- **TooltipApp v2.1+** (included in release)
- Kanata v1.6.1+ (optional, recommended)

---

## 📊 Changes Since v3.1.0

### Modified Files
- `system/plugins/notification.ahk` - Fixed positioning, disabled animation temporarily
- `README.md` - Version bump to v3.1.1
- `system/plugins/welcome_screen.ahk` - Version display updated

### Commits
```
e5087d1bf fix: move notifications to top_right and disable animation temporarily
```

---

## 🔗 Links

- **Repository:** https://github.com/Wilberucx/Hybrid-CapsLock-fork
- **TooltipApp Repository:** https://github.com/Wilberucx/TooltipApp
- **Documentation:** See `doc/` folder in release
- **Previous Release:** [v3.1.0](https://github.com/Wilberucx/Hybrid-CapsLock-fork/releases/tag/v3.1.0)

---

## 🙏 Acknowledgments

Thanks to users who reported the notification positioning issue immediately after v3.1.0 release. Quick feedback enables quick fixes!

---

## 📝 Known Issues

### Animation Disabled
**Issue:** Notifications appear instantly without slide animation  
**Reason:** Temporary workaround for TooltipApp rendering bug  
**Status:** Will be fixed in TooltipApp v2.2  
**Workaround:** None needed, cosmetic issue only

---

## 🚀 Roadmap

### v3.1.2 / v3.2.0 (Future)
- Re-enable notification animation when TooltipApp v2.2 is released
- Additional bug fixes and improvements

### v3.2.0 (Planned)
- Keymap registry refactor for better performance
- Legacy code cleanup
- New features TBD

### v4.0.0 (Future)
- Breaking changes
- Full removal of deprecated APIs
- Major architecture improvements

---

## 📧 Support

- **Issues:** https://github.com/Wilberucx/Hybrid-CapsLock-fork/issues
- **Discussions:** https://github.com/Wilberucx/Hybrid-CapsLock-fork/discussions

---

**Enjoy the fixed notification positioning!** 🎉
