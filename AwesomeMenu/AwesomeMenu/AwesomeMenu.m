//
//  AwesomeMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import "AwesomeMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kAwesomeMenuDefaultNearRadius = 110.0f;
static CGFloat const kAwesomeMenuDefaultEndRadius = 120.0f;
static CGFloat const kAwesomeMenuDefaultFarRadius = 140.0f;
static CGFloat const kAwesomeMenuDefaultStartPointX = 160.0;
static CGFloat const kAwesomeMenuDefaultStartPointY = 240.0;
static CGFloat const kAwesomeMenuDefaultTimeOffset = 0.036f;
static CGFloat const kAwesomeMenuDefaultRotateAngle = 0.0;
static CGFloat const kAwesomeMenuDefaultMenuWholeAngle = M_PI * 2;
static CGFloat const kAwesomeMenuDefaultExpandRotation = M_PI;
static CGFloat const kAwesomeMenuDefaultCloseRotation = M_PI * 2;
static NSTimeInterval const kAwesomeMenuDefaultExpandDuration = 0.4f;
static NSTimeInterval const kAwesomeMenuDefaultCloseDuration  = 0.4f;


static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
  CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
  CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
  CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
  return CGPointApplyAffineTransform(point, transformGroup);    
}

@interface AwesomeMenu ()

@property (nonatomic, retain) NSInvocation *delayedAction;

- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;

- (void)_rotateAddButton;

@end

@implementation AwesomeMenu

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint, expandRotation, closeRotation, expandDuration, closeDuration;
@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;
@synthesize animating = _animating;
@synthesize delayedAction = _delayedAction;

#pragma mark - initialization & cleaning up
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
		
		self.nearRadius = kAwesomeMenuDefaultNearRadius;
		self.endRadius = kAwesomeMenuDefaultEndRadius;
		self.farRadius = kAwesomeMenuDefaultFarRadius;
		self.timeOffset = kAwesomeMenuDefaultTimeOffset;
		self.rotateAngle = kAwesomeMenuDefaultRotateAngle;
		self.menuWholeAngle = kAwesomeMenuDefaultMenuWholeAngle;
		self.startPoint = CGPointMake(kAwesomeMenuDefaultStartPointX, kAwesomeMenuDefaultStartPointY);
    self.expandRotation = kAwesomeMenuDefaultExpandRotation;
    self.closeRotation = kAwesomeMenuDefaultCloseRotation;
    self.expandDuration = kAwesomeMenuDefaultExpandDuration;
    self.closeDuration = kAwesomeMenuDefaultCloseDuration;
    
    self.menusArray = aMenusArray;
    
    // add the "Add" Button.
    _addButton = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
                                       highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"] 
                                           ContentImage:[UIImage imageNamed:@"icon-plus.png"] 
                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
    _addButton.delegate = self;
    _addButton.center = self.startPoint;
    [self addSubview:_addButton];
  }
  return self;
}

- (void)dealloc
{
  self.delayedAction = nil;
  [_addButton release];
  [_menusArray release];
  [super dealloc];
}

#pragma mark - getters & setters

- (void)setStartPoint:(CGPoint)aPoint
{
  startPoint = aPoint;
  _addButton.center = aPoint;
}

#pragma mark - images

- (void)setImage:(UIImage *)image {
	_addButton.image = image;
}

- (UIImage*)image {
	return _addButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	_addButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
	return _addButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
	_addButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return _addButton.contentImageView.image;
}


- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	_addButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
	return _addButton.contentImageView.highlightedImage;
}



#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
  // if the menu state is expanding, everywhere can be touch
  // otherwise, only the add button are can be touch
  if (YES == _expanding) 
  {
    return YES;
  }
  else
  {
    return CGRectContainsPoint(_addButton.frame, point);
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (!self.animating) {
    self.expanding = !self.isExpanding;
  }
}

#pragma mark - AwesomeMenuItem delegates
- (void)AwesomeMenuItemTouchesBegan:(AwesomeMenuItem *)item
{
  if (item == _addButton) 
  {
    if (!self.animating) {
      self.expanding = !self.isExpanding;
    }
    else{
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                  [self methodSignatureForSelector:@selector(AwesomeMenuItemTouchesBegan:)]];
      invocation.target = self;
      invocation.selector = @selector(AwesomeMenuItemTouchesBegan:);
      [invocation setArgument:&item atIndex:2];
      self.delayedAction = invocation;
    }
  }
}
- (void)AwesomeMenuItemTouchesEnd:(AwesomeMenuItem *)item
{
  // exclude the "add" button
  if (item == _addButton) 
  {
    return;
  }
  
  if (self.animating) {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector:@selector(AwesomeMenuItemTouchesEnd:)]];
    invocation.target = self;
    invocation.selector = @selector(AwesomeMenuItemTouchesEnd:);
    [invocation setArgument:&item atIndex:2];
    self.delayedAction = invocation;
    return;
  }
  
  _animating = YES;
  
  // blowup the selected menu button 
  CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
  blowup.delegate = self;
  [item.layer addAnimation:blowup forKey:@"blowup"];
  item.center = item.startPoint;
  
  
  // shrink other menu buttons
  for (int i = 0; i < [_menusArray count]; i ++)
  {
    AwesomeMenuItem *otherItem = [_menusArray objectAtIndex:i];
    CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
    if (otherItem.tag == item.tag) {
      continue;
    }
    [otherItem.layer addAnimation:shrink forKey:@"shrink"];
    
    otherItem.center = otherItem.startPoint;
  }
  _expanding = NO;
  
  // rotate "add" button
  [self _rotateAddButton];
  
  if ([_delegate respondsToSelector:@selector(AwesomeMenu:didSelectIndex:)])
  {
    [_delegate AwesomeMenu:self didSelectIndex:item.tag - 1000];
  }
}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{	
  if (aMenusArray == _menusArray)
  {
    return;
  }
  [_menusArray release];
  _menusArray = [aMenusArray copy];
  
  
  // clean subviews
  for (UIView *v in self.subviews) 
  {
    if (v.tag >= 1000) 
    {
      [v removeFromSuperview];
    }
  }
}


- (void)_setMenu {
	int count = [_menusArray count];
  for (int i = 0; i < count; i ++)
  {
    AwesomeMenuItem *item = [_menusArray objectAtIndex:i];
    item.tag = 1000 + i;
    item.startPoint = startPoint;
    CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / count), startPoint.y - endRadius * cosf(i * menuWholeAngle / count));
    item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
    CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / count), startPoint.y - nearRadius * cosf(i * menuWholeAngle / count));
    item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
    CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / count), startPoint.y - farRadius * cosf(i * menuWholeAngle / count));
    item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);  
    item.center = item.startPoint;
    item.delegate = self;
		[self insertSubview:item belowSubview:_addButton];
  }
}

- (BOOL)isExpanding
{
  return _expanding;
}
- (void)setExpanding:(BOOL)expanding
{
  //    if (self.animating) {
  //        NSLog(@"*WARNING: Can not change expanding status while animating.");
  //        return;
  //    }
	
	if (expanding) {
		[self _setMenu];
	}
	
  _expanding = expanding;    
  
  // rotate add button
  [self _rotateAddButton];
  
  // expand or close animation
  if (!_timer) 
  {
    _animating = YES;
    
    _flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
    SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);
    
    // Adding timer to runloop to make sure UI event won't block the timer from firing
    _timer = [[NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
  }
}
#pragma mark - private methods
- (void)_expand
{
	
  if (_flag == [_menusArray count])
  {
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    return;
  }
  
  int tag = 1000 + _flag;
  AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
  
  CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:expandRotation],[NSNumber numberWithFloat:0.0f], nil];
  rotateAnimation.duration = self.expandDuration;
  rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:.3], 
                              [NSNumber numberWithFloat:.4], nil]; 
  
  CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  positionAnimation.duration = self.expandDuration;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
  CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
  CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
  CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
  positionAnimation.path = path;
  CGPathRelease(path);
  
  CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
  animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
  animationgroup.duration = self.expandDuration;
  animationgroup.fillMode = kCAFillModeForwards;
  animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  
  // Last animation
  if (_flag == [_menusArray count] - 1) {
    animationgroup.delegate = self;
  }
  
  [item.layer addAnimation:animationgroup forKey:@"Expand"];
  item.center = item.endPoint;
  
  _flag ++;
  
}

- (void)_close
{
  if (_flag == -1)
  {
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    return;
  }
  
  int tag = 1000 + _flag;
  AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
  
  CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:closeRotation],[NSNumber numberWithFloat:0.0f], nil];
  rotateAnimation.duration = self.closeDuration;
  rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:.0], 
                              [NSNumber numberWithFloat:.4],
                              [NSNumber numberWithFloat:.5], nil]; 
  
  CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  positionAnimation.duration = self.closeDuration;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
  CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
  CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
  positionAnimation.path = path;
  CGPathRelease(path);
  
  CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
  animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
  animationgroup.duration = self.closeDuration;
  animationgroup.fillMode = kCAFillModeForwards;
  animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  
  // Last animation
  if (_flag == 0) {
    animationgroup.delegate = self;
  }
  
  [item.layer addAnimation:animationgroup forKey:@"Close"];
  item.center = item.startPoint;
  
  _flag --;
  
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
  CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
  positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
  
  CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
  scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
  
  CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
  
  CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
  animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
  animationgroup.duration = 0.3f;
  animationgroup.fillMode = kCAFillModeForwards;
  
  return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
  CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
  positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
  
  CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
  scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
  
  CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
  
  CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
  animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
  animationgroup.duration = 0.3f;
  animationgroup.fillMode = kCAFillModeForwards;
  
  return animationgroup;
}

- (void)_rotateAddButton
{
  float angle = _expanding ? -M_PI_4*3 : 0.0f;
  
  CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotateAnimation.toValue = [NSNumber numberWithFloat:angle];
  rotateAnimation.duration = 0.2;
  rotateAnimation.fillMode = kCAFillModeForwards;
  rotateAnimation.removedOnCompletion = NO;
  if(_expanding) {
    [_addButton.contentImageView.layer addAnimation:rotateAnimation forKey:@"rotate"];
  } else {
    [_addButton.contentImageView.layer addAnimation:rotateAnimation forKey:@"rotateBack"];
  }
  
  //  [UIView animateWithDuration:0.2f animations:^{
  //    _addButton.transform = CGAffineTransformMakeRotation(angle);
  //  }];
  
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
  _animating = NO;
  if (self.delayedAction) {
    [self.delayedAction invoke];
    self.delayedAction = nil;
  }
}


@end
