//
//  PXUtilities.m
//
//  Created by Daniel Blakemore on 5/12/14.
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

#import "PXUtilities.h"

#import "NSString+MD5.h"

#import <UIColor-MoreColors/UIColor+MoreColors.h>

@implementation PXUtilities

+ (NSURL*)convertStringToURL:(NSString*)string
{
    if (string == nil)
    {
        return nil;
    }
    
    // find link
    static NSDataDetector * detector = nil;
    if (!detector) {
        detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:NULL];
    }
    NSArray * matches = [detector matchesInString:string options:kNilOptions range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult * result in matches) {
        if ([result resultType] == NSTextCheckingTypeLink) {
            return [result URL];
        }
    }
    // no match found
    return nil;
}

+ (NSString*)formatDate:(NSDate*)date
{
    return [PXUtilities formatDate:date shortFormat:FALSE];
}

+ (NSString*)formatDate:(NSDate*)date shortFormat:(BOOL)sf
{
    NSCalendar * calendar = [NSCalendar autoupdatingCurrentCalendar];

    // get years
    NSInteger yearsBetween = [[calendar components:NSCalendarUnitYear fromDate:date toDate:[NSDate date] options:0] year];
                              
    
    if (yearsBetween > 0) {
        // it's been years, say that
        if (yearsBetween == 1) {
            return sf ? NSLocalizedString(@"1y", @"Short 1 year old") : NSLocalizedString(@"1 year ago", @"This post is 1 year old.");
        }
        return [NSString stringWithFormat:sf ? NSLocalizedString(@"%dy", @"Short years old") : NSLocalizedString(@"%d years ago", @"Number of years old a post is."), yearsBetween];
    }
    
    // get months
    NSInteger monthsBetween = [[calendar components:NSCalendarUnitMonth fromDate:date toDate:[NSDate date] options:0] month];

    
    if (monthsBetween > 0) {
        // it's been months, say that
        if (monthsBetween == 1) {
            return sf ? NSLocalizedString(@"1M", @"Short 1 month old") : NSLocalizedString(@"1 month ago", @"This post is 1 month old.");
        }
        return [NSString stringWithFormat:sf ? NSLocalizedString(@"%dM", @"Short months old") : NSLocalizedString(@"%d months ago", @"Number of months old a post is."), monthsBetween];
    }
    
    // get weeks
    NSInteger daysBetween = [[calendar components:NSCalendarUnitDay fromDate:date toDate:[NSDate date] options:0] day];
    
    if (daysBetween > 7) {
        // it's been weeks, say that
        if (daysBetween / 7 == 1) {
            return sf ? NSLocalizedString(@"1w", @"Short 1 week old") : NSLocalizedString(@"1 week ago", @"This post is 1 week old.");
        }
        return [NSString stringWithFormat:sf ? NSLocalizedString(@"%dw", @"Short weeks old") : NSLocalizedString(@"%d weeks ago", @"Number of weeks old a post is."), daysBetween / 7];
    }
    
    // get days
    if (daysBetween > 0) {
        // it's been DAYS, say that
        if (daysBetween == 1) {
            return sf ? NSLocalizedString(@"1d", @"Short 1 day old") : NSLocalizedString(@"1 day ago", @"This post is 1 day old.");
        }
        return [NSString stringWithFormat:sf ? NSLocalizedString(@"%dd", @"Short days old") : NSLocalizedString(@"%d days ago", @"Number of days old a post is."), daysBetween];
    }
    
    // get hours
    NSInteger hoursBetween = [[calendar components:NSCalendarUnitHour fromDate:date toDate:[NSDate date] options:0] hour];

    
    if (hoursBetween > 0) {
        // it's been hours, say that
        if (hoursBetween == 1) {
            return sf ? NSLocalizedString(@"1h", @"Short 1 hour old") : NSLocalizedString(@"1 hour ago", @"This post is 1 hour old.");
        }
        return [NSString stringWithFormat:sf ? NSLocalizedString(@"%dh", @"Short hours old") : NSLocalizedString(@"%d hours ago", @"Number of hours old a post is."), hoursBetween];
    }
    
    // get minutes
    NSInteger minutesBetween = [[calendar components:NSCalendarUnitMinute fromDate:date toDate:[NSDate date] options:0] minute];

    
    if (minutesBetween > 0) {
        // it's been hours, say that
        if (minutesBetween == 1) {
            return sf ? NSLocalizedString(@"1m", @"Short 1 minute old") : NSLocalizedString(@"1 minute ago", @"This post is 1 minute old.");
        }
        return [NSString stringWithFormat:sf ? NSLocalizedString(@"%dm", @"Short minutes old") : NSLocalizedString(@"%d minutes ago", @"Number of minutes old a post is."), minutesBetween];
    }
    
    return sf ? NSLocalizedString(@"now", @"Short post just now") : NSLocalizedString(@"just now", @"The post was made just now, i.e. within the last minute.");
}

+ (NSURL*)gravatarURLForEmail:(NSString*)email
{
    NSString *gravatarPath = [NSString stringWithFormat:@"http://gravatar.com/avatar/%@?&default=retro", [email md5string]];
    
    return [NSURL URLWithString:gravatarPath];
}

@end
