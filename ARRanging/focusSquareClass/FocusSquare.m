//
//  focusSquare.m
//  ARRanging
//
//  Created by zhang_jian on 2018/4/9.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import "FocusSquare.h"

@interface FocusSquare()

@end

@implementation FocusSquare
{
    BOOL m_isOpen;
    BOOL m_isAnimating;
    NSMutableArray<NSValue *> *recentFocusSquarePositions;
    SCNNode *m_positioningNode;
    NSArray<FocusSquareSegment *> *m_SegmentArr;
    NSMutableSet<ARAnchor *> *anchorsOfVisitedPlanes;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        recentFocusSquarePositions = [NSMutableArray array];
        anchorsOfVisitedPlanes = [NSMutableSet set];
        self.opacity = .0f;
        m_positioningNode = [SCNNode node];
        self.state = state_initializing;
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        
        FocusSquareSegment *horLine = [[FocusSquareSegment alloc] initWithName:@"horLine" Corner:horizontal];
        FocusSquareSegment *verLine = [[FocusSquareSegment alloc] initWithName:@"verLine" Corner:vertical];
        m_SegmentArr = @[horLine, verLine];
        CGFloat lineLen = .5f;
//        simd_float3 simdVal = horLine.simdPosition;
//        simdVal.x += -(lineLen/2-thickness/2);
//        simdVal.y += -(lineLen-thickness);
//        simdVal.z += 0;
//        horLine.simdPosition = simdVal;
        horLine.simdPosition += simd_make_float3(-(lineLen/2-thickness/2), -(lineLen-thickness), 0);
        verLine.simdPosition += simd_make_float3(-(lineLen/2-thickness/2), -(lineLen-thickness), 0);
        
        SCNVector3 euler = m_positioningNode.eulerAngles;
        euler.x = M_PI_2;
        m_positioningNode.eulerAngles = euler;
        m_positioningNode.simdScale = simd_make_float3(size*scaleForClosedSquare);
        for (FocusSquareSegment *segment in m_SegmentArr)
        {
            [m_positioningNode addChildNode:segment];
        }
        [self displayNodeHierarchyOnTop:YES];
        [self addChildNode:m_positioningNode];
        
        [self displayAsBillBoard];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
        switch (self.state) {
            case state_initializing:
                
                break;
            case state_featureDetected:
                break;
            default:
                break;
        }
    }
}

- (vector_float3)lastPostion
{
    switch (self.state) {
        case state_initializing:
            return simd_make_float3(0);
        case state_featureDetected:
            return 0;
        default:
            return 0;
    }
}

#pragma mark - Appearance
- (void)hide
{
    if (![SCNAction valueForKey:@"unhide"])
    {
        return;
    }
    [self displayNodeHierarchyOnTop:NO];
    [self runAction:[SCNAction fadeInWithDuration:.5]  forKey:@"hide"];
}

- (void)unhide
{
    if (![SCNAction valueForKey:@"unhide"])
    {
        return;
    }
    [self displayNodeHierarchyOnTop:YES];
    [self runAction:[SCNAction fadeInWithDuration:.5]  forKey:@"unhide"];
}

- (void)displayAsBillBoard
{
    SCNVector3 euler = self.eulerAngles;
    euler.x = - M_PI_2;
    self.eulerAngles = euler;
    self.simdPosition = simd_make_float3(0, 0, -0.8);
    [self unhide];
    [self performOpenAnimation];
}

- (void)displayAsOpenWithPostion:(SCNVector3)postion Camara:(ARCamera *)camara
{
    [self performOpenAnimation];
    [recentFocusSquarePositions addObject:[NSValue valueWithSCNVector3:postion]];
    [self updateTransformWithPostion:postion Camara:camara];
}

- (void)displayAsClosedWithPostion:(SCNVector3)postion PlaneAnchor:(ARPlaneAnchor *)planeAnchor Camara:(ARCamera *)camara
{
    [self performCloseAnimation:![anchorsOfVisitedPlanes containsObject:planeAnchor]];
    [anchorsOfVisitedPlanes addObject:planeAnchor];
    [recentFocusSquarePositions addObject:[NSValue valueWithSCNVector3:postion]];
    [self updateTransformWithPostion:postion Camara:camara];
}

#pragma mark - Animations
- (void)performOpenAnimation
{
    
}

- (void)performCloseAnimation:(BOOL)flash
{
    
}

#pragma mark - Helper Methods
- (void)updateTransformWithPostion:(SCNVector3)postion Camara:(ARCamera *)camera
{
    self.simdTransform = matrix_identity_float4x4;
    NSMutableArray<NSValue *> *suffixPostion = [NSMutableArray array];
    for (int i = 0; i < recentFocusSquarePositions.count; i++)
    {
        NSValue *maxValue = recentFocusSquarePositions[i];
        for (int j = i; j < recentFocusSquarePositions.count; j++)
        {
            NSValue *centerValue = recentFocusSquarePositions[j];
            if (maxValue < centerValue)
            {
                maxValue = centerValue;
            }
        }
        [suffixPostion addObject:maxValue];
        if (suffixPostion.count >= 10) {
            break;
        }
    }
    recentFocusSquarePositions = [NSMutableArray arrayWithArray:suffixPostion];
    
    simd_float3 average = simd_make_float3(0, 0, 0);
    for (NSValue *postion in recentFocusSquarePositions) {
        average += simd_make_float3(postion.SCNVector3Value.x,postion.SCNVector3Value.y,postion.SCNVector3Value.z);
    }
//    average = average/()(recentFocusSquarePositions.count);
    self.simdPosition = average;
    self.simdScale = simd_make_float3([self scaleBaseOnDistanceWithCamera:camera]);
    
    if (!camera) {
        return;
    }
    float tilt = fabsf(camera.eulerAngles.x);
    float threshold1 = M_PI_2 * 0.65;
    float threshold2 = M_PI_2 * 0.75;
    float yaw = atan2f(camera.transform.columns[0].x, camera.transform.columns[1].x);
    float angle = 0.f;
    
    if (tilt >=0 && tilt < threshold1)
    {
        angle = camera.eulerAngles.y;
    }
    else if (tilt >= threshold1 && tilt < threshold2)
    {
        float relativeInRange = fabsf((tilt-threshold1)/(threshold2-threshold1));
        float normalizedY = [self normalizedWithAngle:camera.eulerAngles.y ForMiniamlRotationToRef:yaw];
        angle = normalizedY * (1 - relativeInRange) + yaw * relativeInRange;
    }
    else
    {
        angle = yaw;
    }
    SCNVector3 euler = self.eulerAngles;
    euler.y = - angle;
    self.eulerAngles = euler;
}

- (float)normalizedWithAngle:(float)angle ForMiniamlRotationToRef:(float)ref
{
    float normalized = angle;
    while (fabsf(normalized-ref) > M_PI_4) {
        if (angle > ref)
        {
            normalized -= M_PI_2;
        }
        else
        {
            normalized += M_PI_2;
        }
    }
    return normalized;
}

/**
 Reduce visual size change with distance by scaling up when close and down when far away.
 
 These adjustments result in a scale of 1.0x for a distance of 0.7 m or less
 (estimated distance when looking at a table), and a scale of 1.2x
 for a distance 1.5 m distance (estimated distance when looking at the floor).
 */
- (float)scaleBaseOnDistanceWithCamera:(ARCamera *)camera
{
    if (!camera) {
        return 1.f;
    }
    simd_float4 columns = camera.transform.columns[3];
    vector_float3 translation = simd_make_float3(columns.x, columns.y, columns.z);
    float distanceFromCamera = simd_length(self.simdWorldPosition - translation);
    if (distanceFromCamera < 0.7)
    {
        return distanceFromCamera/0.7;
    }
    else
    {
        return 0.25 * distanceFromCamera + 0.825;
    }
}

#pragma mark - Convenience Methods
- (void)updateRenderOrderWithNode:(SCNNode *)node OnTop:(BOOL)isOnTop
{
    node.renderingOrder = isOnTop?2:0;
    for (SCNMaterial *meterial in (node.geometry?node.geometry.materials:@[]))
    {
        meterial.readsFromDepthBuffer = !isOnTop;
    }
    for (SCNNode *child in node.childNodes)
    {
        [self updateRenderOrderWithNode:child OnTop:isOnTop];
    }
}

- (void)displayNodeHierarchyOnTop:(BOOL)isOnTop
{
    [self updateRenderOrderWithNode:m_positioningNode OnTop:isOnTop];
}

@end
