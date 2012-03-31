//
//  QuadCurveRadialDirector.h
//  AwesomeMenu
//
//  Created by Franklin Webber on 3/30/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveMotionDirector.h"

@interface QuadCurveRadialDirector : NSObject <QuadCurveMotionDirector>

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;

- (id)initWithMenuWholeAngle:(CGFloat)menuWholeAngle;
- (id)initWithMenuWholeAngle:(CGFloat)menuWholeAngle andInitialRotation:(CGFloat)rotateAngle;

@end
