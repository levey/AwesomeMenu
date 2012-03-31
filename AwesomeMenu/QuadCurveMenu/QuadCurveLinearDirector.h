//
//  QuadCurveLinearDirector.h
//  AwesomeMenu
//
//  Created by Franklin Webber on 3/30/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveMotionDirector.h"

@interface QuadCurveLinearDirector : NSObject <QuadCurveMotionDirector>

- (id)initWithAngle:(CGFloat)angle andPadding:(CGFloat)padding;

@property (nonatomic,assign) CGFloat angle;
@property (nonatomic,assign) CGFloat padding;

@end
