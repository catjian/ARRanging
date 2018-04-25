//
//  focusSquare.h
//  ARRanging
//
//  Created by zhang_jian on 2018/4/9.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "FocusSquareSegment.h"

typedef NS_ENUM(NSUInteger, ENUM_State) {
    state_initializing,
    state_featureDetected,
    state_planDetected
};

// Original size of the focus square in meters.
static CGFloat size = 0.17;
// Scale factor for the focus square when it is closed, w.r.t. the original size.
static CGFloat scaleForClosedSquare = 0.97;
// Side length of the focus square segments when it is open (w.r.t. to a 1x1 square).
static CGFloat sideLengthForOpenSegments = 0.2;
// Duration of the open/close animation
static CGFloat animationDuration = 0.7;

@interface FocusSquare : SCNNode

@property (nonatomic) ENUM_State state;
@property (nonatomic) simd_float3 lastPostion;

- (void)unhide;

@end
