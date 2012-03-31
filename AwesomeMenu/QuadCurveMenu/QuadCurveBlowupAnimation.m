//
//  QuadCurveBlowupAnimation.m
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveBlowupAnimation.h"

static float const kQuadCurveDefaultBlowUpScale = 3.0f;

@implementation QuadCurveBlowupAnimation

@synthesize blowUpScale;
@synthesize duration;
@synthesize delayBetweenItemAnimation;

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        self.blowUpScale = kQuadCurveDefaultBlowUpScale;
        self.duration = kQuadCoreDefaultAnimationDuration;
        self.delayBetweenItemAnimation = kQuadCoreDefaultDelayBetweenItemAnimation;
    }
    return self;
}

#pragma mark - QuadCurveAnimation Adherence

- (NSString *)animationName {
    return @"blowup";
}

- (CAAnimationGroup *)animationForItem:(QuadCurveMenuItem *)item {
    
    CGPoint point = item.center;
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:point], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(self.blowUpScale, self.blowUpScale, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = self.duration;
    
    return animationgroup;

}

@end
