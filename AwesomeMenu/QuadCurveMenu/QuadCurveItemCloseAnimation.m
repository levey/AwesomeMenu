//
//  QuadCurveItemCloseAnimation.m
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveItemCloseAnimation.h"

static float const kQuadCurveDefaultRotation = M_PI * 2;

@implementation QuadCurveItemCloseAnimation

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
    return @"Close";
}

- (CAAnimationGroup *)animationForItem:(QuadCurveMenuItem *)item {
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:self.rotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = 0.5f;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = self.duration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = self.duration;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    return animationgroup;
}

@end
