//
//  ARSCNViewExtension.m
//  ARRanging
//
//  Created by zhang_jian on 2018/4/19.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import "ARSCNViewExtension.h"

@implementation ARSCNView (ARSCNViewExtension)

- (SCNVector3)worldVectorFromPosition:(CGPoint)position
{
    NSArray<ARHitTestResult *> * planeHitTestResult = [self hitTest:position types:ARHitTestResultTypeFeaturePoint];
    if (planeHitTestResult.count == 0 || !planeHitTestResult.firstObject) {
        return SCNVector3Zero;
    }
    ARHitTestResult *result = planeHitTestResult.firstObject;
    return [SCNVector3Tool positionTranform:result.worldTransform];
}

- (SCNVector3)anchorFromPosition:(CGPoint)position
{
    NSArray<ARHitTestResult *> * planeHitTestResult = [self hitTest:position types:ARHitTestResultTypeFeaturePoint];
    if (planeHitTestResult.count == 0 || !planeHitTestResult.firstObject) {
        return SCNVector3Zero;
    }
    ARHitTestResult *result = planeHitTestResult.firstObject;
    return [SCNVector3Tool positionTranform:result.anchor.transform];
}

- (SCNVector3)planeExtentFromPosition:(CGPoint)position
{
    NSArray<ARHitTestResult *> * planeHitTestResult = [self hitTest:position types:ARHitTestResultTypeExistingPlaneUsingExtent];
    if (planeHitTestResult.count == 0 || !planeHitTestResult.firstObject) {
        return SCNVector3Zero;
    }
    ARHitTestResult *result = planeHitTestResult.firstObject;
    return [SCNVector3Tool positionTranform:result.worldTransform];
}

@end
