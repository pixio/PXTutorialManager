//
//  NSArray+Map.h
//  FindUTA
//
//  Created by Andrew Cobb on 8/19/12.
//  Copyright (c) 2012 Andrew Cobb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Map)

- (NSMutableArray*)mapAndFilter:(id (^)(id obj, NSUInteger idx))block;

@end
