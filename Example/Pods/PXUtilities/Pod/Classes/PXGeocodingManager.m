//
//  PXGeocodingManager.m
//
//  Created by Daniel Blakemore on 7/16/14.
//
//  Copyright (c) 2015 Pixio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PXGeocodingManager.h"

#define PXGeocoderHaveNewSignal 1
#define PXGeocoderNoNewSignal 0
#define RetryCount 10

@implementation PXGeocodingManager
{
    NSMutableArray * _queue;
    NSMutableArray * _thunks;
    NSConditionLock * _queueLock;
    NSConditionLock * _newSignal;
    NSThread * _processingThread;
}

+ (instancetype)sharedManger
{
    static PXGeocodingManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PXGeocodingManager alloc] init];
    });
    
    return manager;
}

- (id) init
{
    self = [super init];
    if (self) {
        _queue = [NSMutableArray array];
        _thunks = [NSMutableArray array];
        
        _queueLock = [[NSConditionLock alloc] init];
        _newSignal = [[NSConditionLock alloc] initWithCondition:PXGeocoderNoNewSignal];
        
        _processingThread = [[NSThread alloc] initWithTarget:self selector:@selector(processThem) object:nil];
        [_processingThread start];
        
    }
    return self;
}

- (void)geocodeAddressString:(NSString*)addressString callback:(void(^)(CLPlacemark * placemark, NSInteger errorCode))callback
{
    NSAssert(callback, @"callback cannot be nil");
    
    [_queueLock lock];
    [_queue addObject:addressString];
    [_thunks addObject:callback];
    [_queueLock unlock];
    
    // signal new things to do
    [_newSignal lock];
    [_newSignal unlockWithCondition:PXGeocoderHaveNewSignal];
    
}

- (CLPlacemark*)synchronatedGeocodeAddress:(NSString*)address errorCode:(NSInteger*)errorCode
{
    __block CLPlacemark * theThingThatGoesOut = nil;
    
    NSConditionLock * lock = [[NSConditionLock alloc] initWithCondition:0];
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray* placemarks, NSError* error) {
        if (error) {
//            NSLog(@"Geocoding Error: %@", [error description]);
            *errorCode = [error code];
        } else {
            if ([placemarks count]) {
                theThingThatGoesOut = [placemarks objectAtIndex:0];
            }
        }
        [lock lock];
        [lock unlockWithCondition:1];
    }];
    
    [lock lockWhenCondition:1];
    [lock unlock]; // cleanup
    
    return theThingThatGoesOut;
}

- (void)processThem
{
    while (TRUE) {
        // see if queue has things
        [_queueLock lock];
        
        NSString * address = nil;
        void(^callback)(CLPlacemark * placemark, NSInteger errorCode) = nil;
        if ([_queue count]) {
            // need to do things, pop thing to do
            address = [_queue objectAtIndex:0];
            callback = [_thunks objectAtIndex:0];
            [_queue removeObjectAtIndex:0];
            [_thunks removeObjectAtIndex:0];
        }
        
        [_queueLock unlock];
        
        if (!address) {
            // nothing to do, wait until something to do
            [_newSignal lock];
            [_newSignal unlockWithCondition:PXGeocoderNoNewSignal];
            [_newSignal lockWhenCondition:PXGeocoderHaveNewSignal];
            [_newSignal unlock];
        } else {
            // process thing
            CLPlacemark * placemark = nil;
            NSInteger sleepIncrementBaseValue = 150000; // µs
            NSInteger sleepIncrementMultiplier = 1;
            NSInteger errorCode = kCLErrorNetwork;
            NSInteger sleepTime = sleepIncrementBaseValue * sleepIncrementMultiplier++;
            usleep((unsigned int)sleepTime);
            while (!(placemark = [self synchronatedGeocodeAddress:address errorCode:&errorCode])) {
                // failed again, need to sleep more
                sleepTime += sleepIncrementBaseValue * sleepIncrementMultiplier++;
                
                if (sleepIncrementMultiplier > RetryCount || errorCode != kCLErrorNetwork) {
                    // give up on this one
                    break;
                }
                
                usleep((unsigned int)sleepTime);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // call back on main thread
                callback(placemark, errorCode);
            });
        }
    }
}

@end
