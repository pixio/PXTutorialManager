//
//  PXTutorialManager.h
//
//  Created by Daniel Blakemore on 9/4/14.
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
#import <UIKit/UIKit.h>

/**
 * A class that displays carousel tutorials loaded from easy-to-write JSON files and images in your app.
 */
@interface PXTutorialManager : UIView

// no initing.  MUST USE CLASS METHOD
- (id) init __attribute__((unavailable("init not available, use +presentTutorial:inView:force: instead")));
- (id) initWithFrame:(CGRect)frame __attribute__((unavailable("initWithFrame: not available, use +presentTutorial:inView:force: instead")));
+ (id) new __attribute__((unavailable("new not available, use +presentTutorial:inView:force: instead")));

/**
 *  Present the specified tutorial full screen in the app.  
 *  If force is set to TRUE, the tutorial is presented whether or not it was 
 *  presented in the past.
 *  The first time the tutorial is presented, the tutorial manager saves state 
 *  to the disk so it is only automatically presented once.
 *
 *  @note Any configuration you would like to perform on the tutorial view must happen before you call present tutorial.
 *
 *  @param tutorial the name of the tutorial to present (corresponds with a file you create called [tutorial].json)
 *  @param force    whether or not to force the tutorial to present (if it has already been presented)
 */
+ (void)presentTutorial:(NSString*)tutorial force:(BOOL)force;

#pragma mark - Text

/**
 *  The title for the final button at the end of the tutorial.
 *
 *  The default title @"Done".
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param title a title for the button that closes the tutorial
 */
+ (void)setFinalButtonTitle:(NSString*)title;

#pragma mark - Fonts

/**
 *  Sets the font for the tutorial text.
 *
 *  The default value is size 16 bold system font.
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param font the font to use for the tutorial page text
 */
+ (void)setFont:(UIFont*)font;

/**
 *  Sets the font for the page title and the final button.
 *
 *  The default value is size 18 bold system font.
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param font the font to use for the final button title and page titles
 */
+ (void)setTitleFont:(UIFont*)titleFont;

#pragma mark - Images

/**
 *  Sets the background image of the tutorial screen.
 *
 *  This property can be overridden by specifying a background image in the tutorial file itself.
 *  If this property is not set before calling presentTutorial:force:, the default will be used.
 *
 *  @param backgroundImage the image to use in the background of the tutorial.
 */
+ (void)setBackgroundImage:(UIImage*)backgroundImage;

/**
 *  Sets the image to use as the next button in the tutorial.
 *
 *  The default is a chevron arrow.  The image set will be tinted with the tintColor set. 
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param nextButtonImage an image to use for the next button
 */
+ (void)setNextButtonImage:(UIImage *)nextButtonImage;

/**
 *  Sets the image to use as the previous button in the tutorial.
 *
 *  The default is a chevron arrow.  The image set will be tinted with the tintColor set.
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param prevButtonImage an image to use for the previous button
 */
+ (void)setPrevButtonImage:(UIImage *)prevButtonImage;

#pragma mark - Colors

/**
 *  Sets the color of the final button that finishes the tutorial.
 *
 *  The default value is the NCS blue: https://en.wikipedia.org/wiki/Shades_of_blue#Blue_.28NCS.29_.28psychological_primary_blue.29
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param color the color to use for the final button
 */
+ (void)setButtonColor:(UIColor*)color;

/**
 *  Sets the color to use for the page indicator and page change buttons.
 *
 *  The default value is blackColor.
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param color the color to use for the page indicator and page change buttons
 */
+ (void)setTintColor:(UIColor*)color;

/**
 *  Sets the color to use for the area behind the text and buttons.
 *
 *  The default value is whiteColor.
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param color the color to use for the area behind the text and buttons
 */
+ (void)setTextBackgroundColor:(UIColor*)color;

/**
 *  Sets the color to use for the text of the tutorial.
 *
 *  The default value is grayColor.
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param color the color to use for the text of the tutorial
 */
+ (void)setTextColor:(UIColor*)color;

/**
 *  Sets the color to use for the page title and final button title.
 *
 *  The default value is whiteColor.
 *  This property must be set before calling presentTutorial:force:, or the default will be used.
 *
 *  @param color the color to use for the page title and final button title
 */
+ (void)setTitleColor:(UIColor*)color;

@end

extern NSString * const PXTutorialDemoTutorial;
