//
//  QuadCurveDefaultDataSource.m
//  AwesomeMenu
//
//  Created by Franklin Webber on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "QuadCurveDefaultDataSource.h"

@implementation QuadCurveDefaultDataSource

- (id)initWithArray:(NSArray *)_array {
    self = [super init];
    if (self) {
        array = _array;
    }
    return self;
}

- (int)numberOfMenuItems {
    return [array count];
}

- (id)dataObjectAtIndex:(NSInteger)itemIndex {
    return [array objectAtIndex:itemIndex];
}
@end

