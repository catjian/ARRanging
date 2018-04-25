//
//  FocusSquareSegment.h
//  ARRanging
//
//  Created by zhang_jian on 2018/4/9.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import <SceneKit/SceneKit.h>

#define primaryColor  [UIColor colorWithRed:1 green:.8 blue:0 alpha:1]
// Color of the focus square fill.
#define fillColor [UIColor colorWithRed:1 green:0.9254901961 blue:0.4117647059 alpha:1]

typedef NS_ENUM(NSUInteger, ENUM_Corner) {
    horizontal,
    vertical
};

/// Thickness of the focus square lines in m.
static CGFloat thickness = 0.018;
/// Length of the focus square lines in m.
static CGFloat length = 0.5;
/// Side length of the focus square segments when it is open (w.r.t. to a 1x1 square).
static CGFloat openLength = 0.2;

@interface FocusSquareSegment : SCNNode

@property (nonatomic) ENUM_Corner corner;
@property (nonatomic, strong) SCNPlane *plane;

- (instancetype)initWithName:(NSString *)name Corner:(ENUM_Corner)corner;

@end
