# Change Log
All notable changes to this project will be documented in this file.
#### 0.9.149 Releases

- `0.9.149` Releases - [0.9.149](#09149)

#### 0.9.148 Releases

- `0.9.148` Releases - [0.9.148](#09148)

#### 0.9.147 Releases

- `0.9.147` Releases - [0.9.147](#09147)

#### 0.9.146 Releases

- `0.9.146` Releases - [0.9.146](#09146)

#### 0.9.137 Releases

- `0.9.137` Releases - [0.9.137](#09137)

---
## [0.9.149](https://github.com/ciscospark/spark-ios-sdk/releases/tag/0.9.149)
Released on 2016-07-11.

#### Added
- Add Teams and Team Memberships API.
- Support DTMF feature.

#### Updated
- Fix Message creation timestamp bug.
- Fix Room type bug.

## [0.9.148](https://github.com/ciscospark/spark-ios-sdk/releases/tag/0.9.148)
Released on 2016-06-23.

#### Added
- Suppport customized notification center (CallNotificationCenter/PhoneNotificationCenter) based on protocol (CallObserver/PhoneObserver), to avoid NSNotificationCenter flaws:
    - Pass parameters via a userInfo dicionary, so type info is lost.
    - Use constant string for notification name and parameter key name. It's hard to maintain and document.
    - Must deregister notifications, if not, it may cause crash.
- Add remote video/audio mute/unmute notifications. New API CallObserver.remoteMediaDidChange() is introduced.
- Support audio-only call. MediaOption parameter is introduced for it in API Phone.Dail()/Call.Answer().
- Support media cluster discovery.
- Support video license activation.
- Enable hardware acceleration, and support 720p video quality.
- Support toggling receiving audio and video. New API Call.toggleReceivingVideo()/Call.toggleReceivingAudio() is introduced for it.

#### Updated
- Refactor storage code logic. defaultFacingMode/defaultLoudSpeaker in Spark.Phone are not persistent, so after restart app, these setting doesn't exist.
- Fix logging performance issue.
- Fix missing incoming call issue when start APP from not running status, or switch APP to foreground from background.
- Update Wme.framework, to fix SIGPIPE signal during debug mode.

## [0.9.147](https://github.com/ciscospark/spark-ios-sdk/releases/tag/0.9.147)
Released on 2016-05-25.

#### Added
- Use CocoaLumberjack to print SDK log. Introduce new API Spark.toggleConsoleLogger(enable: Bool) to enable/disable SDK console log. SDK console log is enabled by default.
- Introduce Apache License for SDK.

#### Updated
- Refactor web socket code logic, to fix some potential issue.
- Update Wme.framework.

## [0.9.146](https://github.com/ciscospark/spark-ios-sdk/releases/tag/0.9.146)
Released on 2016-05-19.

#### Added
- Add CHANGELOG.
- Support refreshing token.

#### Updated
- Refine OAuth flow logic.

## [0.9.137](https://github.com/ciscospark/spark-ios-sdk/releases/tag/0.9.137)
Released on 2016-05-12.

#### Added
- Initial release of Cisco Spark SDK.