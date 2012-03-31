//
//  QuadCurveMenuItem.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuadCurveMenuItemEventDelegate;
@protocol QuadCurveMenuItemFactory;


@interface QuadCurveMenuItem : UIImageView

@property (nonatomic, strong) id dataObject;

@property (nonatomic, readonly) UIImageView *contentImageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightedImage;

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;

@property (nonatomic, strong) id<QuadCurveMenuItemEventDelegate> delegate;

- (id)initWithImage:(UIImage *)image 
   highlightedImage:(UIImage *)highlightedImage
       contentImage:(UIImage *)contentImage
    highlightedContentImage:(UIImage *)highlightContentImage;

@end

@protocol QuadCurveMenuItemEventDelegate <NSObject>

@optional

- (void)quadCurveMenuItemLongPressed:(QuadCurveMenuItem *)item;
- (void)quadCurveMenuItemTapped:(QuadCurveMenuItem *)item;

@end
