//
//  QuadCurveMenu.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenuItem.h"
#import "QuadCurveAnimation.h"
#import "QuadCurveMotionDirector.h"

@protocol QuadCurveMenuDelegate;
@protocol QuadCurveDataSourceDelegate;
@protocol QuadCurveMenuItemFactory;


@interface QuadCurveMenu : UIView <QuadCurveMenuItemEventDelegate>

@property (nonatomic, getter = isExpanding) BOOL expanding;

@property (nonatomic, strong) id<QuadCurveMotionDirector> menuDirector;

@property (nonatomic, strong) id<QuadCurveMenuItemFactory> mainMenuItemFactory;
@property (nonatomic, strong) id<QuadCurveMenuItemFactory> menuItemFactory;

@property (nonatomic, strong) id<QuadCurveAnimation> selectedAnimation;
@property (nonatomic, strong) id<QuadCurveAnimation> unselectedanimation;
@property (nonatomic, strong) id<QuadCurveAnimation> expandItemAnimation;
@property (nonatomic, strong) id<QuadCurveAnimation> closeItemAnimation;

@property (nonatomic, strong) id<QuadCurveMenuDelegate> delegate;
@property (nonatomic, strong) id<QuadCurveDataSourceDelegate> dataSource;

- (id)initWithFrame:(CGRect)frame withArray:(NSArray *)array;

- (id)initWithFrame:(CGRect)frame dataSource:(id<QuadCurveDataSourceDelegate>)dataSource;

- (id)initWithFrame:(CGRect)frame
        centerPoint:(CGPoint)centerPoint
         dataSource:(id<QuadCurveDataSourceDelegate>)dataSource 
    mainMenuFactory:(id<QuadCurveMenuItemFactory>)mainFactory 
    menuItemFactory:(id<QuadCurveMenuItemFactory>)menuItemFactory;

- (void)expandMenu;
- (void)closeMenu;


@end

@protocol QuadCurveMenuDelegate <NSObject>

@optional


- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenu:(QuadCurveMenuItem *)mainMenuItem;
- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenu:(QuadCurveMenuItem *)mainMenuItem;

- (BOOL)quadCurveMenuShouldExpand:(QuadCurveMenu *)menu;
- (BOOL)quadCurveMenuShouldClose:(QuadCurveMenu *)menu;

- (void)quadCurveMenuWillExpand:(QuadCurveMenu *)menu;
- (void)quadCurveMenuDidExpand:(QuadCurveMenu *)menu;

- (void)quadCurveMenuWillClose:(QuadCurveMenu *)menu;
- (void)quadCurveMenuDidClose:(QuadCurveMenu *)menu;

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenuItem:(QuadCurveMenuItem *)menuItem;
- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenuItem:(QuadCurveMenuItem *)menuItem;

@end

@protocol QuadCurveDataSourceDelegate <NSObject>

- (int)numberOfMenuItems;
- (id)dataObjectAtIndex:(NSInteger)itemIndex;

@end

@protocol QuadCurveMenuItemFactory <NSObject>

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject;

@end