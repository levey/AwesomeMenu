//
//  QuadCurveTiltAnimation.h
//  AwesomeMenu
//
//  Created by Franklin Webber on 4/2/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveAnimation.h"

@interface QuadCurveTiltAnimation : NSObject <QuadCurveAnimation>

@property (nonatomic,assign) float tiltDirection;

- (id)initWithTilt:(float)tiltDirection;
- (id)initWithClockwiseTilt;
- (id)initWithCounterClockwiseTilt;

@end
