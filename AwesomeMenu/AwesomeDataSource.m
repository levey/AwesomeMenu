//
//  AwesomeDataSource.m
//  AwesomeMenu
//
//  Created by Franklin Webber on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AwesomeDataSource.h"

@interface AwesomeDataSource () {
    NSMutableArray *dataItems;
}

@end


@implementation AwesomeDataSource

- (id)init {
    self = [super init];
    if (self) {
        dataItems = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
    }
    return self;
}

#pragma mark - QuadCurveDataSourceDelegate Adherence

- (int)numberOfMenuItems {
    return [dataItems count];
}

- (id)dataObjectAtIndex:(NSInteger)itemIndex {
    return [dataItems objectAtIndex:itemIndex];
}

@end
