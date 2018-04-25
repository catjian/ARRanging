//
//  FocusSquareSegment.m
//  ARRanging
//
//  Created by zhang_jian on 2018/4/9.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import "FocusSquareSegment.h"

@implementation FocusSquareSegment

- (instancetype)initWithName:(NSString *)name Corner:(ENUM_Corner)corner
{
    self = [super init];
    if (self)
    {
        self.corner = corner;
        self.name = name;
        switch (corner)
        {
            case horizontal:
                self.plane = [SCNPlane planeWithWidth:thickness height:length];
                break;
            default:
                self.plane = [SCNPlane planeWithWidth:length height:thickness];
                break;
        }
        SCNMaterial *meterial = self.plane.firstMaterial;
        meterial.diffuse.contents = primaryColor;
        meterial.doubleSided = YES;
        meterial.ambient.contents = [UIColor blackColor];
        meterial.emission.contents = primaryColor;
        self.geometry = self.plane;
    }
    return self;
}

- (void)open
{
    if (self.corner == horizontal)
    {
        self.plane.width = openLength;
    }
    else
    {
        self.plane.height = openLength;
    }
    
    CGFloat offset = length /2 - openLength/2;
    [self updatePostion:offset];
}

- (void)close
{
    CGFloat oldLength;
    if (self.corner == horizontal)
    {
        oldLength = self.plane.width;
        self.plane.width = length;
    }
    else
    {
        oldLength = self.plane.height;
        self.plane.height = length;
    }
    
    CGFloat offset = length /2 - oldLength/2;
    [self updatePostion:offset];
}

- (void)updatePostion:(CGFloat)offset
{
    SCNVector3 position = self.position;
    if (self.corner == horizontal)
    {
        position.x -= offset;
    }
    else
    {
        position.y -= offset;
    }
    self.position = position;
}

@end
