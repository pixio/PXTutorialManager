//
//  NSArray+Map.m
//  FindUTA
//
//  Created by Andrew Cobb on 8/19/12.
//  Copyright (c) 2012 Andrew Cobb. All rights reserved.
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSMutableArray*) mapAndFilter:(id (^)(id obj, NSUInteger idx))block
{
    NSMutableArray *result = [NSMutableArray array];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id newObj = block(obj, idx);
        if (newObj) {
            [result addObject:block(obj, idx)];
        }
    }];
    
    return result;
}

@end
