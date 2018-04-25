//
//  ARSCNViewExtension.h
//  ARRanging
//
//  Created by zhang_jian on 2018/4/19.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import <ARKit/ARKit.h>
#import "SCNVector3Tool.h"

@interface ARSCNView (ARSCNViewExtension)

- (SCNVector3)worldVectorFromPosition:(CGPoint)position;

- (SCNVector3)planeExtentFromPosition:(CGPoint)position;

@end
