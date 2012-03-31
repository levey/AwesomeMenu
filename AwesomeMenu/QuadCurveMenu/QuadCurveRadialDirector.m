//
//  QuadCurveRadialDirector.m
//  AwesomeMenu
//
//  Created by Franklin Webber on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "QuadCurveRadialDirector.h"

static CGFloat const kQuadCurveMenuDefaultNearRadius = 110.0f;
static CGFloat const kQuadCurveMenuDefaultEndRadius = 120.0f;
static CGFloat const kQuadCurveMenuDefaultFarRadius = 140.0f;
static CGFloat const kQuadCurveMenuDefaultTimeOffset = 0.036f;
static CGFloat const kQuadCurveMenuDefaultRotateAngle = 0.0;
static CGFloat const kQuadCurveMenuDefaultMenuWholeAngle = M_PI * 2;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

@implementation QuadCurveRadialDirector

@synthesize nearRadius = nearRadius_; 
@synthesize endRadius = endRadius_;
@synthesize farRadius = farRadius_;
@synthesize rotateAngle = rotateAngle_;
@synthesize menuWholeAngle = menuWholeAngle_;

#pragma mark - Initialization

- (id)initWithMenuWholeAngle:(CGFloat)menuWholeAngle 
          andInitialRotation:(CGFloat)rotateAngle {
    
    self = [super init];
    if (self) {
        self.nearRadius = kQuadCurveMenuDefaultNearRadius;
        self.endRadius = kQuadCurveMenuDefaultEndRadius;
        self.farRadius = kQuadCurveMenuDefaultFarRadius;
        
        self.rotateAngle = rotateAngle;
        self.menuWholeAngle = menuWholeAngle;

    }
    return self;
}

- (id)initWithMenuWholeAngle:(CGFloat)menuWholeAngle {
    return [self initWithMenuWholeAngle:menuWholeAngle 
                     andInitialRotation:kQuadCurveMenuDefaultRotateAngle];
}

- (id)init {
    return [self initWithMenuWholeAngle:kQuadCurveMenuDefaultMenuWholeAngle 
                     andInitialRotation:kQuadCurveMenuDefaultRotateAngle];
}

#pragma mark - QuadCurveMotionDirector Adherence

- (void)positionMenuItem:(QuadCurveMenuItem *)item atIndex:(int)index ofCount:(int)count fromMenu:(QuadCurveMenuItem *)mainMenuItem {
    
    CGPoint startPoint = mainMenuItem.center;
    item.startPoint = startPoint;
    
    float itemAngle = index * self.menuWholeAngle / count;
    float xCoefficient = sinf(itemAngle);
    float yCoefficient = cosf(itemAngle);
    
    CGPoint endPoint = CGPointMake(startPoint.x + self.endRadius * xCoefficient, startPoint.y - self.endRadius * yCoefficient);
    
    item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, self.rotateAngle);
    
    CGPoint nearPoint = CGPointMake(startPoint.x + self.nearRadius * xCoefficient, startPoint.y - self.nearRadius * yCoefficient);
    
    item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, self.rotateAngle);
    
    CGPoint farPoint = CGPointMake(startPoint.x + self.farRadius * xCoefficient, startPoint.y - self.farRadius * yCoefficient);
    
    item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, self.rotateAngle);

}

@end
