//
//  QuadCurveMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenu.h"
#import <QuartzCore/QuartzCore.h>

#import "QuadCurveDefaultDataSource.h"
#import "QuadCurveDefaultMenuItemFactory.h"
#import "QuadCurveRadialDirector.h"

#import "QuadCurveBlowupAnimation.h"
#import "QuadCurveShrinkAnimation.h"
#import "QuadCurveItemExpandAnimation.h"
#import "QuadCurveItemCloseAnimation.h"

static int const kQuadCurveMenuItemStartingTag = 1000;

@interface QuadCurveMenu () {
    
    BOOL delegateHasDidTapMainMenu;
    BOOL delegateHasDidLongPressMainMenu;
    BOOL delegateHasShouldExpand;
    BOOL delegateHasShouldClose;
    BOOL delegateHasWillExpand;
    BOOL delegateHasDidExpand;
    BOOL delegateHasWillClose;
    BOOL delegateHasDidClose;
    BOOL delegateHasDidTapMenuItem;
    BOOL delegateHasDidLongPressMenuItem;

}

@property (nonatomic,strong) QuadCurveMenuItem *mainMenuButton;
@property (nonatomic,assign) CGPoint centerPoint;

- (QuadCurveMenuItem *)menuItemAtIndex:(int)index;

- (void)addMenuItem:(QuadCurveMenuItem *)item toViewAtPosition:(NSRange)position;
- (void)addMenuItemsToViewAndPerform:(void (^)(QuadCurveMenuItem *item))block;

- (void)animateMenuItemToEndPoint:(QuadCurveMenuItem *)item;
- (void)animateItemToStartPoint:(QuadCurveMenuItem *)item;
- (void)performExpandMenu;
- (void)performCloseMenu;

- (void)menuItemTapped:(QuadCurveMenuItem *)item;
- (void)mainMenuItemTapped;

- (void)menuItemLongPressed:(QuadCurveMenuItem *)item;
- (void)mainMenuItemLongPressed;

- (void)singleTapInMenuView:(UITapGestureRecognizer *)tapGesture;

@end

#pragma mark - Implementation

@implementation QuadCurveMenu

@synthesize mainMenuButton;

@synthesize mainMenuItemFactory = mainMenuItemFactory_;
@synthesize menuItemFactory = menuItemFactory_;
@synthesize menuDirector = menuDirector_;

@synthesize centerPoint = centerPoint_;

@synthesize selectedAnimation;
@synthesize unselectedanimation;
@synthesize expandItemAnimation;
@synthesize closeItemAnimation;

@synthesize expanding = _expanding;

@synthesize delegate = _delegate;
@synthesize dataSource = dataSource_;

#pragma mark - Initialization & Deallocation

- (id)initWithFrame:(CGRect)frame 
        centerPoint:(CGPoint)centerPoint
         dataSource:(id<QuadCurveDataSourceDelegate>)dataSource 
    mainMenuFactory:(id<QuadCurveMenuItemFactory>)mainFactory 
    menuItemFactory:(id<QuadCurveMenuItemFactory>)menuItemFactory {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.centerPoint = centerPoint;
        
        self.mainMenuItemFactory = mainFactory;
        self.menuItemFactory = menuItemFactory;
        
        self.menuDirector = [[QuadCurveRadialDirector alloc] init];
        
        self.selectedAnimation = [[QuadCurveBlowupAnimation alloc] init];
        self.unselectedanimation = [[QuadCurveShrinkAnimation alloc] init];
        
        self.expandItemAnimation = [[QuadCurveItemExpandAnimation alloc] init];
        self.closeItemAnimation = [[QuadCurveItemCloseAnimation alloc] init];
        
        self.dataSource = dataSource;

        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapInMenuView:)];
        [self addGestureRecognizer:singleTapGesture];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame dataSource:(id<QuadCurveDataSourceDelegate>)dataSource {
    
    return [self initWithFrame:frame 
                    centerPoint:CGPointMake(frame.size.width / 2, frame.size.height / 2) 
                    dataSource:dataSource 
               mainMenuFactory:[QuadCurveDefaultMenuItemFactory defaultMainMenuItemFactory]
               menuItemFactory:[QuadCurveDefaultMenuItemFactory defaultMenuItemFactory]];    
}

- (id)initWithFrame:(CGRect)frame withArray:(NSArray *)array {
    
    return [self initWithFrame:frame
                    centerPoint:CGPointMake(frame.size.width / 2, frame.size.height / 2) 
                    dataSource:[[QuadCurveDefaultDataSource alloc] initWithArray:array]
               mainMenuFactory:[QuadCurveDefaultMenuItemFactory defaultMainMenuItemFactory]
               menuItemFactory:[QuadCurveDefaultMenuItemFactory defaultMenuItemFactory]];
    
}

#pragma mark - Main Menu Item

- (void)setMainMenuItemFactory:(id<QuadCurveMenuItemFactory>)mainMenuItemFactory {
    
    [mainMenuButton removeFromSuperview];
    
    mainMenuItemFactory_ = mainMenuItemFactory;
    
    self.mainMenuButton = [[self mainMenuItemFactory] createMenuItemWithDataObject:nil];
    self.mainMenuButton.delegate = self;
    
    self.mainMenuButton.center = self.centerPoint;
    
    [self addSubview:mainMenuButton];
    [self setNeedsDisplay];
    
}

#pragma mark - Event Delegate

- (void)setDelegate:(id<QuadCurveMenuDelegate>)delegate {
    
    _delegate = delegate;
    
    delegateHasDidTapMainMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didTapMenu:)];
    delegateHasDidLongPressMainMenu = [delegate respondsToSelector:@selector(quadCurveMenu:didLongPressMenu:)];
    
    delegateHasDidTapMenuItem = [delegate respondsToSelector:@selector(quadCurveMenu:didTapMenuItem:)];
    delegateHasDidLongPressMenuItem = [delegate respondsToSelector:@selector(quadCurveMenu:didLongPressMenu:)];
    
    delegateHasShouldExpand = [delegate respondsToSelector:@selector(quadCurveMenuShouldExpand:)];
    delegateHasShouldClose = [delegate respondsToSelector:@selector(quadCurveMenuShouldClose:)];
    delegateHasWillExpand = [delegate respondsToSelector:@selector(quadCurveMenuWillExpand:)];
    delegateHasDidExpand = [delegate respondsToSelector:@selector(quadCurveMenuDidExpand:)];
    delegateHasWillClose = [delegate respondsToSelector:@selector(quadCurveMenuWillClose:)];
    delegateHasDidClose = [delegate respondsToSelector:@selector(quadCurveMenuDidClose:)];
    
}

#pragma mark - Data Source Delegate

- (void)setDataSource:(id<QuadCurveDataSourceDelegate>)dataSource {
    dataSource_ = dataSource;    
}

- (int)numberOfDisplayableItems {
    return [[self dataSource] numberOfMenuItems];
}

- (id)dataObjectAtIndex:(int)index {
    return [[self dataSource] dataObjectAtIndex:index];    
}

- (QuadCurveMenuItem *)menuItemAtIndex:(int)index {
    UIView *item = [self viewWithTag:kQuadCurveMenuItemStartingTag + index];
    
    if (item) {
        return (QuadCurveMenuItem *)item;
    } else {
        return [[self menuItemFactory] createMenuItemWithDataObject:[self dataObjectAtIndex:index]];
    }
    
}


#pragma mark 

- (void)expandMenu {
    if (![self isExpanding]) {
        [self setExpanding:YES];
    }
}

- (void)closeMenu {
    if ([self isExpanding]) {
        [self setExpanding:NO];
    }
}

#pragma mark - UIView Gestures

- (void)singleTapInMenuView:(UITapGestureRecognizer *)tapGesture {
    [self closeMenu];
}

#pragma mark - QuadCurveMenuItemEventDelegate Adherence


#pragma mark Tap Event

- (void)quadCurveMenuItemTapped:(QuadCurveMenuItem *)item {
    
    if (item == mainMenuButton) {
        [self mainMenuItemTapped];
    } else {
        [self menuItemTapped:item];
    }
}

- (void)mainMenuItemTapped {
    
    if (delegateHasDidTapMainMenu) {
        [[self delegate] quadCurveMenu:self didTapMenu:mainMenuButton];
    }
    
    BOOL willBeExpandingMenu = ![self isExpanding];
    BOOL shouldPerformAction = YES;
    
    if (willBeExpandingMenu && delegateHasShouldExpand) {
        shouldPerformAction = [[self delegate] quadCurveMenuShouldExpand:self];
    }
    
    if ( ! willBeExpandingMenu && delegateHasShouldClose) {
        shouldPerformAction = [[self delegate] quadCurveMenuShouldClose:self];
    }
    
    if (shouldPerformAction) {
        [self setExpanding:willBeExpandingMenu];
    }
    
}

- (void)menuItemTapped:(QuadCurveMenuItem *)item {
    
    if (delegateHasDidTapMenuItem) {
        [[self delegate] quadCurveMenu:self didTapMenuItem:item];
    }
    
    [self animateMenuItems:[NSArray arrayWithObject:item] withAnimation:[self selectedAnimation]];
    
    NSPredicate *otherItems = [NSPredicate predicateWithFormat:@"tag != %d",[item tag]];
    
    NSArray *otherMenuItems = [[self allMenuItemsBeingDisplayed] filteredArrayUsingPredicate:otherItems];
    
    [self animateMenuItems:otherMenuItems withAnimation:[self unselectedanimation]];
    
    _expanding = NO;
    
    [self rotateMainMenuItemClockwise:[self isExpanding]];
    
}

#pragma mark Long Press Event

- (void)quadCurveMenuItemLongPressed:(QuadCurveMenuItem *)item {
    
    if (item == mainMenuButton) {
        [self mainMenuItemLongPressed];
    } else {
        [self menuItemLongPressed:item];
    }
    
}

- (void)mainMenuItemLongPressed {
    
    if (delegateHasDidLongPressMainMenu) {
        [[self delegate] quadCurveMenu:self didLongPressMenu:mainMenuButton];
    }
    
}

- (void)menuItemLongPressed:(QuadCurveMenuItem *)item {
    
    if (delegateHasDidLongPressMenuItem) {
        [[self delegate] quadCurveMenu:self didLongPressMenuItem:item];
    }
    
}

#pragma mark - Selection Animations

- (void)animateMenuItems:(NSArray *)items withAnimation:(id<QuadCurveAnimation>)animation {
    for (QuadCurveMenuItem *item in items) {
        CAAnimationGroup *itemAnimation = [animation animationForItem:item];
        [item.layer addAnimation:itemAnimation forKey:[animation animationName]];
        item.center = item.startPoint;
    }
}

- (void)rotateMainMenuItemClockwise:(BOOL)animateClockwise {
    
    float angle = animateClockwise ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        mainMenuButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
}

- (NSArray *)allMenuItemsBeingDisplayed {
    
    NSPredicate *allMenuItemsPredicate = [NSPredicate predicateWithFormat:@"tag BETWEEN { %d, %d }",
                                          kQuadCurveMenuItemStartingTag,
                                          (kQuadCurveMenuItemStartingTag + [self numberOfDisplayableItems])];
    
    return [[self subviews] filteredArrayUsingPredicate:allMenuItemsPredicate];
}

#pragma mark - Expanding / Closing the Menu

- (BOOL)isExpanding {
    return _expanding;
}

- (void)setExpanding:(BOOL)expanding {
    _expanding = expanding;
    
    [self rotateMainMenuItemClockwise:[self isExpanding]];
    
	if ([self isExpanding]) {
        [self performExpandMenu];
	} else {
        [self performCloseMenu];
    }
    
}

#pragma mark - QuadCurveMenuItem Management

- (void)addMenuItem:(QuadCurveMenuItem *)item toViewAtPosition:(NSRange)position {
    
    int index = position.location;
    int count = position.length;
    
    item.tag = kQuadCurveMenuItemStartingTag + index;
    item.delegate = self;
    
    [[self menuDirector] positionMenuItem:item atIndex:index ofCount:count fromMenu:mainMenuButton];
    
    [self insertSubview:item belowSubview:mainMenuButton];
}

- (void)addMenuItemsToViewAndPerform:(void (^)(QuadCurveMenuItem *item))block {
    
    int total = [self numberOfDisplayableItems];
    
    for (int index = 0; index < total; index ++) {
        
        QuadCurveMenuItem *item = [self menuItemAtIndex:index];
        [self addMenuItem:item toViewAtPosition:NSMakeRange(index,total)];
        
        block(item);
    }
    
}


#pragma mark - Animate MenuItems Expanded

- (void)performExpandMenu {
    
    if (delegateHasWillExpand) {
        [[self delegate] quadCurveMenuWillExpand:self];
    }
    
    [self addMenuItemsToViewAndPerform:^(QuadCurveMenuItem *item) {
        item.center = item.startPoint;
    }];
    
    NSArray *itemToBeAnimated = [self allMenuItemsBeingDisplayed];
    
    for (int x = 0; x < [itemToBeAnimated count]; x++) {
        QuadCurveMenuItem *item = [itemToBeAnimated objectAtIndex:x];
        [self performSelector:@selector(animateMenuItemToEndPoint:) withObject:item afterDelay:self.closeItemAnimation.delayBetweenItemAnimation * x];
    }
    
    if (delegateHasDidExpand) {
        [[self delegate] quadCurveMenuDidExpand:self];
    }
    
}

- (void)animateMenuItemToEndPoint:(QuadCurveMenuItem *)item {
    CAAnimationGroup *expandAnimation = [[self expandItemAnimation] animationForItem:item];
    [item.layer addAnimation:expandAnimation forKey:[[self expandItemAnimation] animationName]];
    item.center = item.endPoint;
}

#pragma mark - Animate MenuItems Closed

- (void)performCloseMenu {
    
    if (delegateHasWillClose) {
        [[self delegate] quadCurveMenuWillClose:self];
    }
    
    NSArray *itemToBeAnimated = [self allMenuItemsBeingDisplayed];
    
    for (int x = 0; x < [itemToBeAnimated count]; x++) {
        QuadCurveMenuItem *item = [itemToBeAnimated objectAtIndex:x];
        [self performSelector:@selector(animateItemToStartPoint:) withObject:item afterDelay:self.expandItemAnimation.delayBetweenItemAnimation * x];
    }
    
    if (delegateHasDidClose) {
        [[self delegate] quadCurveMenuDidClose:self];
    }
    
}

- (void)animateItemToStartPoint:(QuadCurveMenuItem *)item {
    CAAnimationGroup *closeAnimation = [[self closeItemAnimation] animationForItem:item];
    [item.layer addAnimation:closeAnimation forKey:[[self closeItemAnimation] animationName]];
    item.center = item.startPoint;
}


@end
