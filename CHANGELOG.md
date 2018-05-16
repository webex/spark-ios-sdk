# Change Log
All notable changes to this project will be documented in this file.
#### 1.4.0 Releases

- `1.4.0` Releases - [1.4.0](#140)
#### 1.3.1 Releases

- `1.3.1` Releases - [1.3.1](#131)

#### 1.3.0 Releases

- `1.3.0` Releases - [1.3.0](#130)

#### 1.2.0 Releases

- `1.2.0` Releases - [1.2.0](#120)

#### 1.1.0 Releases

- `1.1.0` Releases - [1.1.0](#110)

#### 1.0.0 Releases

- `1.0.0` Releases - [1.0.0](#100)

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
## [1.4.0](https://github.com/ciscospark/spark-ios-sdk/releases/tag/1.4.0)
Released on 2018-05-15.

#### Added
- Support screen sharing for both [sending](https://github.com/webex/spark-ios-sdk/blob/EFT/1.4.0/README.md#usage) and [receiving](https://github.com/webex/spark-ios-sdk/blob/EFT/1.4.0/README.md#usage), see more details [here](https://github.com/webex/spark-ios-sdk/wiki/screen-sharing...TBD)
- A new API to refresh token for [authentication](https://webex.github.io/spark-ios-sdk/Protocols/Authenticator.html#/...TBD)
- Two properties in [Membership](https://webex.github.io/spark-ios-sdk/Structs/Membership.html): personDisplayName, personOrgId
- Support real time message receiving
- Support message end to end encription
- A few new APIs to do [message](https://webex.github.io/spark-ios-sdk/Classes/MessageClient.html#/...TBD)/[file](https://webex.github.io/spark-ios-sdk/Classes/MessageClient.html#/...TBD) end to end encryption, [Mention](https://webex.github.io/spark-ios-sdk/Classes/MessageClient.html#/...TBD) in message, [upload](https://webex.github.io/spark-ios-sdk/Structs/Message.html#/...LocalFile) and [download](https://webex.github.io/spark-ios-sdk/Structs/Message.html#/...RemoteFile) encrypted files
- Five properties in [Person](https://webex.github.io/spark-ios-sdk/Structs/Person.html): nickName, firstName, lastName, orgId, type
- Three functions to [create](https://webex.github.io/spark-ios-sdk/Classes/PersonClient.html#/...TBD)/[update](https://webex.github.io/spark-ios-sdk/Classes/PersonClient.html#/...TBD)/[delete](https://webex.github.io/spark-ios-sdk/Classes/PersonClient.html#/...TBD) a person for organization's administrator
- Support room [list](https://webex.github.io/spark-ios-sdk/Classes/RoomClient.html#/...TBD) ordered by either room ID, lastactivity time or creation time
- A new property in [TeamMembership](https://webex.github.io/spark-ios-sdk/Structs/TeamMembership.html): personOrgId
- Two new parameters to [update](https://webex.github.io/spark-ios-sdk/Classes/WebhookClient.html#/...TBD) webhook : status and secret

#### Updated
- Fixed ocassional crash when switching between video call and audio call when CallKit is used
- Fixed video freeze when iOS SDK makes a call to JavaScript SDK
- Fixed crash issue when invoking Phone.requestMediaAccess function from background thread
- Fixed wrong call type for room calling when there are only two people in the call

## [1.3.1](https://github.com/ciscospark/spark-ios-sdk/releases/tag/1.3.1)
Released on 2018-1-12.

#### Feature:
          SSO Authenticator

## [1.3.0](https://github.com/ciscospark/spark-ios-sdk/releases/tag/1.3.0)
Released on 2017-10-13.

## [1.2.0](https://github.com/ciscospark/spark-ios-sdk/releases/tag/1.2.0)
Released on 2017-05-23.

## [1.1.0](https://github.com/ciscospark/spark-ios-sdk/releases/tag/1.1.0)
Released on 2016-11-29.

#### Updated
- Support swift 3.0

## [1.0.0](https://github.com/ciscospark/spark-ios-sdk/releases/tag/1.0.0)
Released on 2016-07-25.

#### Added
- Travis CI

#### Updated
- Media engine refactor
- Use NSDate for object mapper 

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
