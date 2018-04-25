//
//  VirtualObjectARView.m
//  ARRanging
//
//  Created by zhang_jian on 2018/4/19.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import "VirtualObjectARView.h"

@implementation VirtualObjectARView

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
//        SCNHitTestOption hitTestOption = SCNHitTestBoundingBoxOnlyKey;
//        NSArray<SCNHitTestResult *> *hitTestResult = [self hitTest:frame.origin options:@{hitTestOption:@(YES)}];
    }
    return self;
}

- (NSDictionary *)hitTestRay:(vector_float3)origin Types:(vector_float3)direction PlaneY:(NSNumber *)planeY
{
    SCNVector3 originSCN = SCNVector3Make(origin.x, origin.y, origin.z);
    SCNVector3 directionSCN = SCNVector3Make(direction.x, direction.y, direction.z);
    if (!planeY) {
        return @{@"origin":[NSValue valueWithSCNVector3:originSCN],
                 @"direction":[NSValue valueWithSCNVector3:directionSCN]};
    }
    
    vector_float3 normalizedDirection = simd_normalize(direction);
    if (normalizedDirection.y == 0)
    {
        if (origin.y == planeY.floatValue)
        {
            return @{@"origin":[NSValue valueWithSCNVector3:originSCN],
                     @"direction":[NSValue valueWithSCNVector3:directionSCN],
                     @"HorizontalPlane":[NSValue valueWithSCNVector3:originSCN]};
        }
        else
            return nil;
    }
    
    float distance = planeY.floatValue - origin.y/normalizedDirection.y;
    if (distance < 0)
    {
        return nil;
    }
    vector_float3 HorizontalPlane = origin+ (normalizedDirection*distance);
    SCNVector3 HorizontalPlaneSCN = SCNVector3Make(HorizontalPlane.x, HorizontalPlane.y, HorizontalPlane.z);
    return @{@"origin":[NSValue valueWithSCNVector3:originSCN],
             @"direction":[NSValue valueWithSCNVector3:directionSCN],
             @"HorizontalPlane":[NSValue valueWithSCNVector3:HorizontalPlaneSCN]};
}

- (NSDictionary *)worldPositionFromScreenPosition:(CGPoint)postion ObjectPosition:(vector_float3)objectPostion InfinitePlane:(BOOL)infinitePlane
{
    NSArray<ARHitTestResult *> * planeHitTestResult = [self hitTest:postion types:ARHitTestResultTypeExistingPlaneUsingExtent];
    
    ARHitTestResult *result;
    if (planeHitTestResult.count > 0 && planeHitTestResult.firstObject)
    {
        result = planeHitTestResult.firstObject;
        
        simd_float4 columns = result.worldTransform.columns[3];
        SCNVector3 planeHitTestPosition = SCNVector3Make(columns.x, columns.y, columns.z);
        ARAnchor *planeAnchor = result.anchor;
        return @{@"position":[NSValue valueWithSCNVector3:planeHitTestPosition],
                 @"planeAnchor":(ARPlaneAnchor *)planeAnchor,
                 @"isOnPlane":@(YES)};
    }
    
    
    return nil;
}

#pragma mark - Hit Tests

- (NSDictionary *)hitTestRayFromScreenPostion:(CGPoint)position
{
    if (!self.session.currentFrame) {
        return nil;
    }
    ARFrame *frame = self.session.currentFrame;
    
    simd_float4 columns = frame.camera.transform.columns[3];
    vector_float3 cameraPos = vector3(columns.x, columns.y, columns.z);
    vector_float3 positionVec = vector3((float)position.x, (float)position.y, 1.f);
    vector_float3 rayDirection = simd_normalize(positionVec-cameraPos);
    return [self hitTestRay:cameraPos Types:rayDirection PlaneY:nil];
}

- (NSDictionary *)hitTestWithInfiniteHerizontalPlaneWithPoint:(CGPoint)point PointOnPlane:(vector_float3)pointOnPlane
{
    NSDictionary<NSString *,NSValue *> *ray = [self hitTestRayFromScreenPostion:point];
    if (!ray) {
        return nil;
    }
    
    if (ray[@"direction"].SCNVector3Value.y > -0.03) {
        return nil;
    }
    
    return [self hitTestRay:vector3(ray[@"origin"].SCNVector3Value.x, ray[@"origin"].SCNVector3Value.y, ray[@"origin"].SCNVector3Value.z)
                      Types:vector3(ray[@"direction"].SCNVector3Value.x, ray[@"direction"].SCNVector3Value.y, ray[@"direction"].SCNVector3Value.z)
                     PlaneY:@(pointOnPlane.y)];
}


@end
