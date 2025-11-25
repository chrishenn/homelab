#!/bin/bash

adb shell dumpsys deviceidle whitelist +com.android.mms.service
adb shell dumpsys deviceidle whitelist +com.android.smspush
adb shell dumpsys deviceidle whitelist +com.google.android.apps.messaging
adb shell dumpsys deviceidle whitelist +com.android.bluetooth
adb shell dumpsys deviceidle whitelist +com.android.bluetoothmidiservice
adb shell dumpsys deviceidle whitelist +com.oneplus.mms
adb shell dumpsys deviceidle whitelist +com.oneplus.sms.smscplugger
adb shell dumpsys deviceidle whitelist +com.vanced.manager
adb shell dumpsys deviceidle whitelist +com.google.android.youtube
adb shell dumpsys deviceidle whitelist +com.google.android.apps.youtube.music
adb shell dumpsys deviceidle whitelist +org.adaway
adb shell dumpsys deviceidle whitelist +au.com.shiftyjelly.pocketcasts
