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
static CGFloat const kAwesomeMenuDefaultAnimationDuration = 0.5f;
static CGFloat const kAwesomeMenuStartMenuDefaultAnimationDuration = 0.3f;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);    
}

@interface AwesomeMenu ()
- (void)_expandAnimation;
- (void)_closeAnimation;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
@end

@implementation AwesomeMenu {
    NSUInteger _flag;
    NSTimer *_timer;
    BOOL _isAnimating;
}

@synthesize nearRadius, endRadius, farRadius, timeOffset, rotateAngle, menuWholeAngle, startPoint, expandRotation, closeRotation, animationDuration, rotateAddButton;
@synthesize expanded = _expanded;

#pragma mark - Initialization & Cleaning up

- (id)initWithFrame:(CGRect)frame startItem:(AwesomeMenuItem*)startItem menuItems:(NSArray *)menuItems
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
        self.animationDuration = kAwesomeMenuDefaultAnimationDuration;
        self.rotateAddButton = YES;
        
        self.menuItems = menuItems;
        
        // assign startItem to "Add" Button.
        self.startButton = startItem;
        self.startButton.delegate = self;
        self.startButton.center = self.startPoint;
        [self addSubview:self.startButton];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame startItem:(AwesomeMenuItem*)startItem optionMenus:(NSArray *)aMenusArray
{
    return [self initWithFrame:frame startItem:startItem menuItems:aMenusArray];
}

#pragma mark - Getters & Setters

- (void)setStartPoint:(CGPoint)aPoint
{
    startPoint = aPoint;
    self.startButton.center = aPoint;
}

#pragma mark - Images

- (void)setImage:(UIImage *)image {
	self.startButton.image = image;
}

- (UIImage*)image {
	return self.startButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
	self.startButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
	return self.startButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
	self.startButton.contentImageView.image = contentImage;
}

- (UIImage*)contentImage {
	return self.startButton.contentImageView.image;
}

- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
	self.startButton.contentImageView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
	return self.startButton.contentImageView.highlightedImage;
}


                               
#pragma mark - UIView's methods

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // if the menu is animating, prevent touches
    if (_isAnimating) 
    {
        return NO;
    }
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isExpanded){
    
        self.expanded = NO;
    }
}

#pragma mark - AwesomeMenuItem delegates

- (void)AwesomeMenuItemTouchesBegan:(AwesomeMenuItem *)item
{
    if (item == self.startButton) 
    {
        self.expanded = ![self isExpanded];
    }
}
- (void)AwesomeMenuItemTouchesEnd:(AwesomeMenuItem *)item
{
    // exclude the "add" button
    if (item == self.startButton) 
    {
        return;
    }
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [self.menuItems count]; i ++)
    {
        AwesomeMenuItem *otherItem = [self.menuItems objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];

        otherItem.center = otherItem.startPoint;
    }
    _expanded = NO;
    
    // rotate start button
    float angle = [self isExpanded] ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:animationDuration animations:^{
        self.startButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    if ([_delegate respondsToSelector:@selector(awesomeMenu:didSelectIndex:)])
    {
        [_delegate awesomeMenu:self didSelectIndex:item.tag - 1000];
    }
}

#pragma mark - Instance methods

- (void)setMenuItems:(NSArray *)menuItems
{	
    if (menuItems == _menuItems)
    {
        return;
    }
    _menuItems = [menuItems copy];
    
    
    // clean subviews
    for (UIView *v in self.subviews) 
    {
        if (v.tag >= 1000) 
        {
            [v removeFromSuperview];
        }
    }
}

- (AwesomeMenuItem *)menuItemAtIndex:(NSUInteger)index
{
    if (index >= [self.menuItems count]) {
        return nil;
    }
    return self.menuItems[index];
}

- (void)open
{
    if (_isAnimating || [self isExpanded]) {
        return;
    }
    [self setExpanded:YES];
}

- (void)close
{
    if (_isAnimating || ![self isExpanded]) {
        return;
    }
    [self setExpanded:NO];
}

- (void)_setMenu {
	NSUInteger count = [self.menuItems count];
    for (int i = 0; i < count; i ++)
    {
        AwesomeMenuItem *item = [self.menuItems objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = startPoint;
        
        // avoid overlap
        if (menuWholeAngle >= M_PI * 2) {
            menuWholeAngle = menuWholeAngle - menuWholeAngle / count;
        }
        CGPoint endPoint = CGPointMake(startPoint.x + endRadius * sinf(i * menuWholeAngle / (count - 1)), startPoint.y - endRadius * cosf(i * menuWholeAngle / (count - 1)));
        item.endPoint = RotateCGPointAroundCenter(endPoint, startPoint, rotateAngle);
        CGPoint nearPoint = CGPointMake(startPoint.x + nearRadius * sinf(i * menuWholeAngle / (count - 1)), startPoint.y - nearRadius * cosf(i * menuWholeAngle / (count - 1)));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, startPoint, rotateAngle);
        CGPoint farPoint = CGPointMake(startPoint.x + farRadius * sinf(i * menuWholeAngle / (count - 1)), startPoint.y - farRadius * cosf(i * menuWholeAngle / (count - 1)));
        item.farPoint = RotateCGPointAroundCenter(farPoint, startPoint, rotateAngle);  
        item.center = item.startPoint;
        item.delegate = self;
		[self insertSubview:item belowSubview:self.startButton];
    }
}

- (BOOL)isExpanded
{
    return _expanded;
}
- (void)setExpanded:(BOOL)expanded
{
    if (expanded) {
        [self _setMenu];
        if(self.delegate && [self.delegate respondsToSelector:@selector(awesomeMenuWillAnimateOpen:)]){
            [self.delegate awesomeMenuWillAnimateOpen:self];
        }
    } else {
        if(self.delegate && [self.delegate respondsToSelector:@selector(awesomeMenuWillAnimateClose:)]){
            [self.delegate awesomeMenuWillAnimateClose:self];
        }
    }
    
    _expanded = expanded;

    // rotate add button
    if (self.rotateAddButton) {
        float angle = [self isExpanded] ? -M_PI_4 : 0.0f;
        [UIView animateWithDuration:kAwesomeMenuStartMenuDefaultAnimationDuration animations:^{
            self.startButton.transform = CGAffineTransformMakeRotation(angle);
        }];
    }
    
    // expand or close animation
    if (!_timer) 
    {
        _flag = [self isExpanded] ? 0 : ([self.menuItems count] - 1);
        SEL selector = [self isExpanded] ? @selector(_expandAnimation) : @selector(_closeAnimation);

        // Adding timer to runloop to make sure UI event won't block the timer from firing
        _timer = [NSTimer timerWithTimeInterval:timeOffset target:self selector:selector userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _isAnimating = YES;
    }
}

#pragma mark - Private methods

- (void)_expandAnimation
{
	
    if (_flag == [self.menuItems count])
    {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
    AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:expandRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = animationDuration;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3], 
                                [NSNumber numberWithFloat:.4], nil]; 
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    if(_flag == [self.menuItems count] - 1){
        [animationgroup setValue:@"firstAnimation" forKey:@"id"];
    }
    
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    _flag ++;
    
}

- (void)_closeAnimation
{
    if (_flag == -1)
    {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
     AwesomeMenuItem *item = (AwesomeMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:closeRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = animationDuration;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil]; 
        
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    if(_flag == 0){
        [animationgroup setValue:@"lastAnimation" forKey:@"id"];
    }
    
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;

    _flag --;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"lastAnimation"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(awesomeMenuDidFinishAnimationClose:)]){
            [self.delegate awesomeMenuDidFinishAnimationClose:self];
        }
    }
    if([[anim valueForKey:@"id"] isEqual:@"firstAnimation"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(awesomeMenuDidFinishAnimationOpen:)]){
            [self.delegate awesomeMenuDidFinishAnimationOpen:self];
        }
    }
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
    animationgroup.duration = animationDuration;
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
    animationgroup.duration = animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


@end
