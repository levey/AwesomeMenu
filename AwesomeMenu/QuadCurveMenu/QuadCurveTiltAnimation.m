//
//  QuadCurveTiltAnimation.m
//  AwesomeMenu
//
//  Created by Franklin Webber on 4/2/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveTiltAnimation.h"

@implementation QuadCurveTiltAnimation

@synthesize tiltDirection = tiltDirection_;
@synthesize delayBetweenItemAnimation;
@synthesize duration;

#pragma mark - Initialization

- (id)initWithTilt:(float)tiltDirection {
    self = [super init];
    if (self) {
        [self setTiltDirection:tiltDirection];
    }
    return self;
}

- (id)initWithClockwiseTilt {
    return [self initWithTilt:M_PI_4];
}

- (id)initWithCounterClockwiseTilt {
    return [self initWithTilt:-M_PI_4];
}

#pragma mark - QuadCurveAnanimation Adherence

- (NSString *)animationName {
    return @"tiltAnimation";
}

- (CAAnimationGroup *)animationForItem:(QuadCurveMenuItem *)item {
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotateAnimation.fromValue = [[item.layer presentationLayer] valueForKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = [NSNumber numberWithFloat:self.tiltDirection];
    rotateAnimation.duration = self.duration;
    rotateAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:rotateAnimation,nil];
    animationGroup.duration = self.duration;
    animationGroup.fillMode = kCAFillModeForwards;
    
    item.transform = CGAffineTransformMakeRotation(self.tiltDirection);
    
    return animationGroup;
    
}

@end
