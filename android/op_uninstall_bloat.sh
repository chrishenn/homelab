#!/bin/bash

adb shell pm disable-user com.android.traceur
adb shell pm disable-user com.google.android.feedback
adb shell pm disable-user com.google.android.apps.wellbeing
adb shell pm disable-user com.android.chrome
adb shell pm disable-user com.google.android.documentsui
adb shell pm disable-user com.google.android.gm
adb shell pm disable-user com.google.android.music
adb shell pm disable-user com.google.android.videos

adb shell pm disable-user com.oneplus.opbugreportlite
adb shell pm disable-user com.oneplus.brickmode
adb shell pm disable-user com.oneplus.opbackup
adb shell pm disable-user net.oneplus.odm
adb shell pm disable-user net.oneplus.odm.provider
adb shell pm disable-user com.oneplus.membership
adb shell pm disable-user com.oneplus.membership.basiccolorblack.overlay
adb shell pm disable-user com.oneplus.membership.basiccolorwhite.overlay

adb shell pm disable-user com.dsi.ant.server
adb shell pm disable-user com.facebook.appmanager
adb shell pm disable-user com.facebook.services
adb shell pm disable-user com.facebook.system
adb shell pm disable-user com.heytap.cloud
adb shell pm disable-user com.heytap.mcs
adb shell pm disable-user com.heytap.openid
adb shell pm disable-user com.netflix.mediaclient
adb shell pm disable-user com.netflix.partner.activation
adb shell pm disable-user com.tencent.soter.soterserver

pm uninstall -k --user 0 com.android.traceur
pm uninstall -k --user 0 com.google.android.feedback
pm uninstall -k --user 0 com.google.android.apps.wellbeing
pm uninstall -k --user 0 com.android.chrome
pm uninstall -k --user 0 com.google.android.documentsui
pm uninstall -k --user 0 com.google.android.gm
pm uninstall -k --user 0 com.google.android.music
pm uninstall -k --user 0 com.google.android.videos
pm uninstall -k --user 0 com.oneplus.opbugreportlite
pm uninstall -k --user 0 com.oneplus.brickmode
pm uninstall -k --user 0 com.oneplus.opbackup
pm uninstall -k --user 0 net.oneplus.odm
pm uninstall -k --user 0 net.oneplus.odm.provider
pm uninstall -k --user 0 com.oneplus.membership
pm uninstall -k --user 0 com.oneplus.membership.basiccolorblack.overlay
pm uninstall -k --user 0 com.oneplus.membership.basiccolorwhite.overlay
pm uninstall -k --user 0 com.dsi.ant.server
pm uninstall -k --user 0 com.facebook.appmanager
pm uninstall -k --user 0 com.facebook.services
pm uninstall -k --user 0 com.facebook.system
pm uninstall -k --user 0 com.heytap.cloud
pm uninstall -k --user 0 com.heytap.mcs
pm uninstall -k --user 0 com.heytap.openid
pm uninstall -k --user 0 com.netflix.mediaclient
pm uninstall -k --user 0 com.netflix.partner.activation
pm uninstall -k --user 0 com.tencent.soter.soterserver
