//
//  QuadCurveDefaultMenuItemFactory.m
//  Nudge
//
//  Created by Franklin Webber on 3/19/12.
//  Copyright (c) 2012 Franklin Webber. All rights reserved.
//

#import "QuadCurveDefaultMenuItemFactory.h"

@interface QuadCurveDefaultMenuItemFactory () {
    UIImage *image;
    UIImage *highlightImage;
    UIImage *contentImage;
    UIImage *highlightContentImage;
}

@end

@implementation QuadCurveDefaultMenuItemFactory

#pragma mark - Initialization

- (id)initWithImage:(UIImage *)_image highlightImage:(UIImage *)_highlightImage 
       contentImage:(UIImage *)_contentImage highlightedContentImage:(UIImage *)_highlightContentImage {
    self = [super init];
    if (self) {
        
        image = _image;
        highlightImage = _highlightImage;
        contentImage = _contentImage;
        highlightContentImage = _highlightContentImage;
        
    }
    return self;
}

+ (id)defaultMenuItemFactory {
    
    return [[self alloc] initWithImage:[UIImage imageNamed:@"bg-menuitem.png" ]
                                           highlightImage:[UIImage imageNamed:@"bg-menuitem-highlighted.png"]
                                             contentImage:[UIImage imageNamed:@"icon-star.png"]
                                  highlightedContentImage:nil];
}

+ (id)defaultMainMenuItemFactory {
    
    return [[self alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton.png" ]
                        highlightImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"]
                          contentImage:[UIImage imageNamed:@"icon-plus.png"]
               highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];

}

#pragma mark - QuadCurveMenuItemFactory Adherence

- (QuadCurveMenuItem *)createMenuItemWithDataObject:(id)dataObject {
    
    QuadCurveMenuItem *item = [[QuadCurveMenuItem alloc] initWithImage:image 
                                                      highlightedImage:highlightImage
                                                          contentImage:contentImage 
                                               highlightedContentImage:highlightContentImage];
    
    [item setDataObject:dataObject];
    
    return item;
}

@end
