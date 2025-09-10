
# Android SDK start
if [ `uname` = "Darwin" ];then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
else
    # Linux
    export ANDROID_HOME="$HOME/Android/Sdk/"
fi
# 配置sdk及ndk
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/tools/bin:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
[ -n "$ANDROID_SDK_NDK_VERSION" ] && export PATH=$ANDROID_HOME/ndk/$ANDROID_SDK_NDK_VERSION:$PATH
[ -n "$ANDROID_SDK_BUILD_TOOLS_VERSION" ] && export PATH=$ANDROID_HOME/build-tools/$ANDROID_SDK_BUILD_TOOLS_VERSION:$PATH

# Android SDK end