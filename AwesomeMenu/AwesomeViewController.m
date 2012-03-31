//
//  AwesomeViewController.m
//  AwesomeMenu
//
//  Created by Franklin Webber on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AwesomeViewController.h"
#import "AwesomeDataSource.h"
#import "QuadCurveRadialDirector.h"
#import "QuadCurveLinearDirector.h"

@interface AwesomeViewController ()

@property (nonatomic,assign) QuadCurveMenu *menu;

@end

@implementation AwesomeViewController

@synthesize menu = menu_;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
//    AwesomeDataSource *dataSource = [[AwesomeDataSource alloc] init];
//    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds dataSource:dataSource];
    
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds 
                                      withArray:[NSArray arrayWithObjects:@"1",@"2",@"3",@"4",nil]];
    
    [menu setMenuDirector:[[QuadCurveRadialDirector alloc] initWithMenuWholeAngle:M_PI/2 andInitialRotation:0]];
    
    menu.delegate = self;
    
    self.menu = menu;

    [self.view addSubview:menu];
	
}

#pragma mark - QuadCurveMenuDelegate Adherence

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenu:(QuadCurveMenuItem *)mainMenuItem {
    NSLog(@"Menu - Tapped");
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenu:(QuadCurveMenuItem *)mainMenuItem {
    NSLog(@"Menu - Long Pressed");
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenuItem:(QuadCurveMenuItem *)menuItem {
    NSLog(@"Menu Item (%@) - Tapped",menuItem.dataObject);
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenuItem:(QuadCurveMenuItem *)menuItem {
    NSLog(@"Menu Item (%@) - Long Pressed",menuItem.dataObject);
}

- (void)quadCurveMenuWillExpand:(QuadCurveMenu *)menu {
    NSLog(@"Menu - Will Expand");
}

- (void)quadCurveMenuDidExpand:(QuadCurveMenu *)menu {
    NSLog(@"Menu - Did Expand");
}

- (void)quadCurveMenuWillClose:(QuadCurveMenu *)menu {
    NSLog(@"Menu - Will Close");
}

- (void)quadCurveMenuDidClose:(QuadCurveMenu *)menu {
    NSLog(@"Menu - Did Close");
    
    static int alternatingMenuTypeCount = 0;
    
    if (alternatingMenuTypeCount % 2 == 0) {
        [self.menu setMenuDirector:[[QuadCurveLinearDirector alloc] initWithAngle:M_PI/2 andPadding:10.0]];
    } else {
        [self.menu setMenuDirector:[[QuadCurveRadialDirector alloc] initWithMenuWholeAngle:M_PI andInitialRotation:0]];
    }
    
    alternatingMenuTypeCount = alternatingMenuTypeCount + 1; 
}

- (BOOL)quadCurveMenuShouldClose:(QuadCurveMenu *)menu {
    return YES;
}

- (BOOL)quadCurveMenuShouldExpand:(QuadCurveMenu *)menu {
    return YES;
}


@end
