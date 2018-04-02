//
//  SocketMessage.h
//  iOSBroadcastExtension
//
//  Created by panzh on 13/03/2018.
//  Copyright © 2018 Cisco Systems Inc. All rights reserved.
//

typedef NS_ENUM(int8_t, ScreenShareError) {
    ScreenShareErrorNone = 0,
    ScreenShareErrorFatal = -1,
    ScreenShareErrorNoLocus = -2,
    ScreenShareErrorStop = -3,
    ScreenShareErrorContainingAppSuspended  = -4,
};

typedef struct __FrameMessage {
    ScreenShareError error;
    uint32_t timestamp;
    int32_t width;
    int32_t height;
    uint32_t length;
    uint8_t data[];
} FrameMessage;

typedef struct {
    ScreenShareError error;
} FeedbackMessage;

typedef struct __FrameInfo {
    uint32_t timestamp;
    int32_t width;
    int32_t height;
    uint32_t length;
} FrameInfo;
