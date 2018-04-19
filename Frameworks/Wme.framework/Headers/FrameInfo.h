//
//  FrameMessage.h
//  Wme
//
//  Created by panzh on 05/03/2018.
//  Copyright © 2018 cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct __FrameInfo {
    uint32_t timestamp;
    int32_t width;
    int32_t height;
    uint32_t length;
} FrameInfo;

