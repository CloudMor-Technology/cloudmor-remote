#!/usr/bin/env bash
# CloudMor Remote branding, applied in CI before building (repo: CloudMor-Technology/cloudmor-remote).
# - App name "CloudMor Remote" (window titles, tray, Mac app, Windows Programs list)
# - Built in to CloudMor's own RustDesk server on rmm.cloudmor.com and its public key,
#   so a fresh install needs no setup and never uses RustDesk's public servers.
set -euo pipefail
cd "$(dirname "$0")/.."
NAME="CloudMor Remote"
HOST="rmm.cloudmor.com"
KEY="RKFf6+bue2XOuBuxBHlw29L7L2WHoWJxAtmoA0Upxa0="
CFG=libs/hbb_common/src/config.rs
perl -pi -e "s/RwLock::new\(\"RustDesk\"\.to_owned\(\)\)/RwLock::new(\"$NAME\".to_owned())/" "$CFG"
# Org prefix for macOS settings folders and launchd job names (com.cloudmor.CloudMor Remote_service).
perl -pi -e "s/RwLock::new\(\"com\.carriez\"\.to_owned\(\)\)/RwLock::new(\"com.cloudmor\".to_owned())/" "$CFG"
grep -q '"com.cloudmor".to_owned()' "$CFG"
# launchd job labels match the org above (the app name is substituted at install time).
perl -pi -e 's/com\.carriez\.RustDesk/com.cloudmor.RustDesk/g' src/platform/privileges_scripts/*
grep -q 'com.cloudmor.RustDesk_service' src/platform/privileges_scripts/daemon.plist
perl -pi -e 's{<string>com\.carriez\.rustdesk</string>}{<string>com.cloudmor.remote</string>}' flutter/macos/Runner/Info.plist
perl -pi -e "s/^pub const RENDEZVOUS_SERVERS: &\[&str\] = &\[.*\];/pub const RENDEZVOUS_SERVERS: &[&str] = &[\"$HOST\"];/" "$CFG"
perl -pi -e "s|^pub const RS_PUB_KEY: &str = \".*\";|pub const RS_PUB_KEY: &str = \"$KEY\";|" "$CFG"
grep -q "\"$NAME\".to_owned()" "$CFG"
grep -q "&\[\"$HOST\"\]" "$CFG"
grep -q "\"$KEY\"" "$CFG"
# The Xcode project sets the bundle id per configuration, overriding AppInfo.xcconfig.
perl -pi -e 's/PRODUCT_BUNDLE_IDENTIFIER = com\.carriez\.rustdesk;/PRODUCT_BUNDLE_IDENTIFIER = com.cloudmor.remote;/g' flutter/macos/Runner.xcodeproj/project.pbxproj
! grep -q "com.carriez.rustdesk;" flutter/macos/Runner.xcodeproj/project.pbxproj
perl -pi -e "s/^PRODUCT_NAME = .*/PRODUCT_NAME = $NAME/; s/^PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = com.cloudmor.remote/; s/^PRODUCT_COPYRIGHT = .*/PRODUCT_COPYRIGHT = Copyright 2026 CloudMor. Based on RustDesk (AGPL-3.0)./" flutter/macos/Runner/Configs/AppInfo.xcconfig
perl -pi -e "s/\"RustDesk Remote Desktop\"/\"$NAME\"/; s/VALUE \"ProductName\", \"RustDesk\"/VALUE \"ProductName\", \"$NAME\"/; s/VALUE \"CompanyName\", \".*?\"/VALUE \"CompanyName\", \"CloudMor\"/" flutter/windows/runner/Runner.rc
perl -pi -e "s{Release/RustDesk\.app/}{Release/\"$NAME.app\"/}g" build.py
grep -q "Release/\"$NAME.app\"/" build.py
# The MSI preprocessor runs "<app name>.exe" unquoted; quote it for the space in the name.
perl -pi -e 's/f"\{dist_app\} \{args\}"/f\x27"{dist_app}" {args}\x27/' res/msi/preprocess.py
grep -q "f'\"{dist_app}\" {args}'" res/msi/preprocess.py
echo "Branded as $NAME on $HOST"
