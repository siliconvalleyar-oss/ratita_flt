# Dino Run — Deployment

## Build Release APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

APK at `build/app/outputs/flutter-apk/app-release.apk`.

## Install on Device (ADB)

```bash
# For Android 14+ (session API)
adb push build/app/outputs/flutter-apk/app-release.apk /data/local/tmp/app.apk
SESSION=$(adb shell pm install-create -i "com.android.vending" | grep -oP '\d+')
adb shell pm install-write -S $(stat -c%s app.apk) $SESSION app /data/local/tmp/app.apk
adb shell pm install-commit $SESSION

# Or simply
flutter install
```

## App Icon

Regenerate from `assets/icon/logo.png`:

```bash
python3 -c "
from PIL import Image
img = Image.open('assets/icon/logo.png')
for folder,size in [('mipmap-mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    img.resize((size,size), Image.LANCZOS).save(f'android/app/src/main/res/{folder}/ic_launcher.png')
"
```
