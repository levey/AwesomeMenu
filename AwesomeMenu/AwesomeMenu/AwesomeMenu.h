//
//  AwesomeMenu.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwesomeMenuItem.h"

@protocol AwesomeMenuDelegate;

@interface AwesomeMenu : UIView <AwesomeMenuItemDelegate>

@property (nonatomic, copy) NSArray *menuItems;
@property (nonatomic, strong) AwesomeMenuItem *startButton;

@property (nonatomic, getter = isExpanded) BOOL expanded;
@property (nonatomic, assign) id<AwesomeMenuDelegate> delegate;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;
@property (nonatomic, strong) UIImage *contentImage;
@property (nonatomic, strong) UIImage *highlightedContentImage;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat closeRotation;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL    rotateAddButton;
@property (nonatomic, assign) CGFloat addRotation;

- (id)initWithFrame:(CGRect)frame startItem:(AwesomeMenuItem*)startItem menuItems:(NSArray *)menuItems;

- (id)initWithFrame:(CGRect)frame startItem:(AwesomeMenuItem*)startItem optionMenus:(NSArray *)aMenusArray DEPRECATED_MSG_ATTRIBUTE("use -initWithFrame:startItem:menuItems: instead.");

- (AwesomeMenuItem *)menuItemAtIndex:(NSUInteger)index;

- (void)open;

- (void)close;

@end

@protocol AwesomeMenuDelegate <NSObject>
- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx;
@optional
- (void)awesomeMenuDidFinishAnimationClose:(AwesomeMenu *)menu;
- (void)awesomeMenuDidFinishAnimationOpen:(AwesomeMenu *)menu;
- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu;
- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu;
@end