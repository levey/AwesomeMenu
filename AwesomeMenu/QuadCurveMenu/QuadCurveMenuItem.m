//
//  QuadCurveMenuItem.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenuItem.h"

static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}

@interface QuadCurveMenuItem () {
    
    BOOL delegateHasLongPressed;
    BOOL delegateHasTapped;
    
}

- (void)longPressOnMenuItem:(UIGestureRecognizer *)sender;
- (void)singleTapOnMenuItem:(UIGestureRecognizer *)sender;

@end

@implementation QuadCurveMenuItem

@synthesize dataObject;

@synthesize contentImageView = _contentImageView;

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;
@synthesize delegate  = delegate_;

@dynamic image;
@dynamic highlightedImage;

#pragma mark - Initialization

- (id)initWithImage:(UIImage *)_image 
   highlightedImage:(UIImage *)_highlightedImage 
       contentImage:(UIImage *)_contentImage 
highlightedContentImage:(UIImage *)_highlightedContentImage {
    
    if (self = [super init]) {
        
        self.userInteractionEnabled = YES;
        
        self.image = _image;
        self.highlightedImage = _highlightedImage;
        _contentImageView = [[UIImageView alloc] initWithImage:_contentImage];
        _contentImageView.highlightedImage = _highlightedContentImage;
        
        [self addSubview:_contentImageView];
        
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMenuItem:)];
        
        [self addGestureRecognizer:longPressGesture];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnMenuItem:)];
        
        [self addGestureRecognizer:singleTapGesture];
        
        [self setUserInteractionEnabled:YES];

        
    }
    return self;
}

#pragma mark - Delegate

- (void)setDelegate:(id<QuadCurveMenuItemEventDelegate>)delegate {
    
    delegate_ = delegate;
    
    delegateHasLongPressed = [delegate respondsToSelector:@selector(quadCurveMenuItemLongPressed:)];
    delegateHasTapped = [delegate respondsToSelector:@selector(quadCurveMenuItemTapped:)];
    
}

#pragma mark - Gestures

- (void)longPressOnMenuItem:(UILongPressGestureRecognizer *)sender {
    
    if (delegateHasLongPressed) {
        [delegate_ quadCurveMenuItemLongPressed:self];
    }
    
}

- (void)singleTapOnMenuItem:(UITapGestureRecognizer *)sender {
    
    if (delegateHasTapped) {
        [delegate_ quadCurveMenuItemTapped:self];
    }
    
}

#pragma mark - UIView's methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    float width = _contentImageView.image.size.width;
    float height = _contentImageView.image.size.height;
    _contentImageView.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
}


#pragma mark - Status Methods

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [_contentImageView setHighlighted:highlighted];
}


@end
