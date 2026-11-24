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
perl -pi -e "s/^pub const RENDEZVOUS_SERVERS: &\[&str\] = &\[.*\];/pub const RENDEZVOUS_SERVERS: &[&str] = &[\"$HOST\"];/" "$CFG"
perl -pi -e "s|^pub const RS_PUB_KEY: &str = \".*\";|pub const RS_PUB_KEY: &str = \"$KEY\";|" "$CFG"
grep -q "\"$NAME\".to_owned()" "$CFG"
grep -q "&\[\"$HOST\"\]" "$CFG"
grep -q "\"$KEY\"" "$CFG"
perl -pi -e "s/^PRODUCT_NAME = .*/PRODUCT_NAME = $NAME/; s/^PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = com.cloudmor.remote/; s/^PRODUCT_COPYRIGHT = .*/PRODUCT_COPYRIGHT = Copyright 2026 CloudMor. Based on RustDesk (AGPL-3.0)./" flutter/macos/Runner/Configs/AppInfo.xcconfig
perl -pi -e "s/\"RustDesk Remote Desktop\"/\"$NAME\"/; s/VALUE \"ProductName\", \"RustDesk\"/VALUE \"ProductName\", \"$NAME\"/; s/VALUE \"CompanyName\", \".*?\"/VALUE \"CompanyName\", \"CloudMor\"/" flutter/windows/runner/Runner.rc
perl -pi -e "s{Release/RustDesk\.app/}{Release/\"$NAME.app\"/}g" build.py
grep -q "Release/\"$NAME.app\"/" build.py
echo "Branded as $NAME on $HOST"
