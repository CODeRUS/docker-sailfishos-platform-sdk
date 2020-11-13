#!/bin/bash

set -ex

bash build.sh platformsdk.ks i486 $RELEASE
bash build.sh tooling.ks i486 $RELEASE
bash build.sh target.ks i486 $RELEASE
bash build.sh target.ks armv7hl $RELEASE
bash build.sh target.ks aarch64 $RELEASE