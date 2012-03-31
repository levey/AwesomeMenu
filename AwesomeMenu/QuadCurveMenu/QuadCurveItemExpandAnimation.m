//
//  QuadCurveItemExpandAnimation.m
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveItemExpandAnimation.h"

static float const kQuadCurveDefaultRotation = M_PI * 2;

@implementation QuadCurveItemExpandAnimation

@synthesize duration;
@synthesize rotation;
@synthesize delayBetweenItemAnimation;

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.rotation = kQuadCurveDefaultRotation;
        self.duration = kQuadCoreDefaultAnimationDuration;
        self.delayBetweenItemAnimation = kQuadCoreDefaultDelayBetweenItemAnimation;
    }
    return self;
}

#pragma mark - QuadCurveAnimation Adherence


- (NSString *)animationName {
    return @"Expand";
}

- (CAAnimationGroup *)animationForItem:(QuadCurveMenuItem *)item {
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:M_PI],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = self.duration;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = self.duration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = self.duration;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    return animationgroup;
}


@end
