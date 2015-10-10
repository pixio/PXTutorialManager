//
//  FRAsyncListifier.h
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

#import <Foundation/Foundation.h>

typedef void(^callbackWithThing)(id);
typedef void(^callbackWithBool)(BOOL);

/**
 *  A class for building an array from multiple async calls.
 */
@interface PXAsyncUtilities : NSObject

/**
 *  Asynchronously download the objects specified in the list using the specified block.
 *  The completion is called with the results of all downloads in a list.
 *
 *  @discussion This class method is used to perform async operations (such as downloads) mapping a list
 *              of objects to a new list using the specified block.  This mapping could be converting
 *              @c NSStrings or @c NSURLs to images by downloading them, or loading URLs from disk.
 *              Once all the operations complete, the callback is called with the result list.
 *              It is important that ALL calls to @c downloadBlock call the block passed as an argument.
 *              If, for some reason, the operation fails, it is acceptable to pass @c nil to the block,
 *              which will be ignored safely.
 *  @discussion Any blocks which return nil will also not have their object returned to the final callback
 *              in the list of objects.
 *  @discussion The list of @c objectIds returned along with the completed @c list is in the same order as the downloaded
 *              output in case the order changed as a result of the download or there were @c nil results.
 *
 *  @param objectIds     ids of objects to download
 *  @param downloadBlock block which downloads an object with the given id
 *  @param completion    completion to call when the list is complete
 */
+ (void)downloadAndListObjects:(NSArray*)objects downloadBlock:(void(^)(id objectId, callbackWithThing callback))downloadBlock completion:(void(^)(NSArray * list, NSArray * objectIds))completion;

/**
 *  Asynchronously perform the specified operation on the given objects, recording success of each.
 *  The completion is called with two arrays containing the objects for which the operation succeeded and failed.
 *
 *  @discussion This class method is used to perform async operations which can simply succeed or fail.
 *              It is important that ALL calls to @c operation call the block passed as an argument.
 *              If there is no concept of success or failure for @c operation, it is acceptable to simply call
 *              @c callback with @c TRUE and ignore the @c successes and @c faulures arguments to @c completion.
 *
 *  @param objects    objects to pass to operation
 *  @param operation  block which performs some async operation
 *  @param completion completion to call when all async operations are done
 */
+ (void)useObjects:(NSArray*)objects forOperation:(void(^)(id object, callbackWithBool callback))operation completion:(void(^)(NSArray * successes, NSArray * failures))completion;

@end