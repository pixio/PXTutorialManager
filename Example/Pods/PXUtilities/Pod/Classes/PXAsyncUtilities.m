//
//  FRAsyncListifier.m
//  Favred
//
//  Created by Daniel Blakemore on 9/9/14.
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

#import "PXAsyncUtilities.h"

@interface PXAsyncUtilities ()

@property (nonatomic, copy) void(^downloadCompletion)(NSArray * list, NSArray * objects);

@property (nonatomic, copy) void(^downloadBlock)(id object, callbackWithThing);

@property (nonatomic, copy) void(^operationCompletion)(NSArray * successes, NSArray * failures);

@property (nonatomic, copy) void(^operationBlock)(id object, callbackWithBool);

@property (nonatomic) NSArray * objects;

@end

@implementation PXAsyncUtilities
{
    NSMutableArray * _array;
    NSMutableArray * _objectsWhoseDownloadBlocksSucceededWithNonNilResults;
    NSMutableArray * _successes;
    NSMutableArray * _failures;
    NSInteger _left;
}

+ (void)downloadAndListObjects:(NSArray*)objects downloadBlock:(void(^)(id objectId, callbackWithThing callback))downloadBlock completion:(void(^)(NSArray * list, NSArray * objects))completion
{
    PXAsyncUtilities * downloader = [[PXAsyncUtilities alloc] init];
    [downloader setDownloadCompletion:completion];
    [downloader setDownloadBlock:downloadBlock];
    [downloader setObjects:objects];
    [downloader goDownload];
}

- (void)goDownload
{
    _array = [NSMutableArray array];
    _objectsWhoseDownloadBlocksSucceededWithNonNilResults = [NSMutableArray array];
    _left = [_objects count];
    if (!_left) {
        if (_downloadCompletion) {
            _downloadCompletion(_array, _objectsWhoseDownloadBlocksSucceededWithNonNilResults);
        }
    }
    for (id object in _objects) {
        _downloadBlock(object, ^(id resultObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // ignore nil objects
                if (resultObject) {
                    [_objectsWhoseDownloadBlocksSucceededWithNonNilResults addObject:object];
                    [_array addObject:resultObject];
                }
                if (!(--_left)) {
                    if (_downloadCompletion) {
                        _downloadCompletion(_array, _objectsWhoseDownloadBlocksSucceededWithNonNilResults);
                    }
                }
            });
        });
    }
}

+ (void)useObjects:(NSArray*)objects forOperation:(void(^)(id object, callbackWithBool callback))operation completion:(void(^)(NSArray * successes, NSArray * failures))completion;
{
    PXAsyncUtilities * downloader = [[PXAsyncUtilities alloc] init];
    [downloader setOperationCompletion:completion];
    [downloader setOperationBlock:operation];
    [downloader setObjects:objects];
    [downloader goDo];
}

- (void)goDo
{
    _successes = [NSMutableArray array];
    _failures = [NSMutableArray array];
    _left = [_objects count];
    if (!_left) {
        if (_operationCompletion) {
            _operationCompletion(_successes, _failures);
        }
    }
    for (id object in _objects) {
        _operationBlock(object, ^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // ignore nil objects
                if (success) {
                    [_successes addObject:object];
                } else {
                    [_failures addObject:object];
                }
                if (!(--_left)) {
                    if (_operationCompletion) {
                        _operationCompletion(_successes, _failures);
                    }
                }
            });
        });
    }
}

@end
