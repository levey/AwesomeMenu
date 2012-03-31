//
//  QuadCurveAnimation.h
//  Nudge
//
//  Created by Franklin Webber on 3/16/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QuadCurveMenuItem.h"

static float const kQuadCoreDefaultAnimationDuration = 0.5f;
static float const kQuadCoreDefaultDelayBetweenItemAnimation = 0.036f;

@protocol QuadCurveAnimation <NSObject>

- (NSString *)animationName;
- (CAAnimationGroup *)animationForItem:(QuadCurveMenuItem *)item;

@property (nonatomic,assign) CGFloat duration;
@property (nonatomic,assign) CGFloat delayBetweenItemAnimation;

@end
