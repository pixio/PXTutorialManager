//
//  PXTutorialManager.m
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

#import "PXTutorialManager.h"

#import <PXButton/PXButton.h>
#import <PXImageView/PXImageView.h>
#import <PXUtilities/NSString+JSON.h>
#import <UIColor-MoreColors/UIColor+MoreColors.h>

#import <iCarousel/iCarousel.h>

#define isShittyPhoneThatOwnersShouldFeelBadForHaving  ([[UIScreen mainScreen] bounds].size.height == 480)?TRUE:FALSE
#define StorageFormatVersion 1.0f
#define StorageFormatVersionKey @"storageVersion"
#define TutorialPageArrayKey @"pageArray"
#define TutorialPageTitleKey @"pageTitle"
#define TutorialPageTextKey @"pageText"
#define TutorialPageImageNameKey @"pageImageName"
#define TutorialBackgroundImageNameKey @"background"
#define TutorialDoneTitleKey @"doneTitle"
#define DefaultBackgroundImageName @"com.pixio.tutorial.default-background-image"
#define DefaultNextButtonImage @"tutorial-forward"
#define DefaultPrevButtonImage @"tutorial-back"

@interface UIImage (PXTutorialManager)

+ (UIImage *)px_imageNamed:(NSString *)name;

@end

@implementation UIImage (PXTutorialManager)

// Someone else had a good idea so I used it. http://stackoverflow.com/a/22068117/579405
+ (UIImage *)px_imageNamed:(NSString *)name
{
    UIImage *imageFromMainBundle = [UIImage imageNamed:name];
    if (imageFromMainBundle) {
        return imageFromMainBundle;
    }
    
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"PXTutorialManager" ofType:@"bundle"];
    NSString *imageName = [NSString stringWithFormat:@"%@/%@", bundlePath, name];
    UIImage *imageFromBundle = [UIImage imageNamed:imageName];
    if (!imageFromBundle) {
        NSLog(@"Image not found: %@", name);
    }
    return imageFromBundle;
}

@end

@interface PXTutorialPage : NSObject

/**
 *  The title of the tutorial slide.
 */
@property (nonatomic) NSString * title;

/**
 *  The image or screenshot to display with the title and text.
 */
@property (nonatomic) UIImage * image;

/**
 *  Text describing this step in the tutorial and the included image.
 */
@property (nonatomic) NSString * text;

@end

@implementation PXTutorialPage

@end

@interface PXTutorialManager () <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic) PXButton * doneButton;

@end

@implementation PXTutorialManager
{
    PXImageView * _backgroundImageView;
    UILabel * _titleView;
    UILabel * _textView;
    UILabel * _textView2; // used for crossfade
    UIView * _textBackground;
    UIView * _dividerLine;
    UIButton * _backButton;
    UIButton * _forwardButton;
    UIPageControl * _pageIndicator;
    iCarousel * _carousel;
    
    NSMutableArray * _tutorial;
}

// class-level "properties"
static NSString * __finalButtonTitle;

static UIFont * __font;
static UIFont * __titleFont;

static UIImage * __backgroundImage;
static UIImage * __nextButtonImage;
static UIImage * __prevButtonImage;

static UIColor * __textColor;
static UIColor * __tintColor;
static UIColor * __titleColor;
static UIColor * __buttonColor;
static UIColor * __textBackgroundColor;

+ (void)load
{
    __finalButtonTitle = @"Done";
    
    __font = [UIFont boldSystemFontOfSize:16.0f];
    __titleFont = [UIFont boldSystemFontOfSize:18.0f];
    
    __backgroundImage = [UIImage px_imageNamed:DefaultBackgroundImageName];
    __prevButtonImage = [UIImage px_imageNamed:DefaultPrevButtonImage];
    __nextButtonImage = [UIImage px_imageNamed:DefaultNextButtonImage];
    
    __textColor = [UIColor grayColor];
    __tintColor = [UIColor blackColor];
    __titleColor = [UIColor whiteColor];
    __buttonColor = [UIColor blueNcs];
    __textBackgroundColor = [UIColor whiteColor];
}

#pragma mark - "properties"

#pragma mark Text

+ (NSString*)finalButtonTitle
{
    return __finalButtonTitle;
}

+ (void)setFinalButtonTitle:(NSString*)title
{
    __finalButtonTitle = title;
}

#pragma mark Fonts

+ (UIFont *)font
{
    return __font;
}

+ (void)setFont:(UIFont *)font
{
    __font = font;
}

+ (UIFont *)titleFont
{
    return __titleFont;
}

+ (void)setTitleFont:(UIFont*)titleFont
{
    __titleFont = titleFont;
}

#pragma mark Images

+ (UIImage *)backgroundImage
{
    return __backgroundImage;
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage
{
    __backgroundImage = backgroundImage;
}

+ (UIImage *)nextButtonImage
{
    return __nextButtonImage;
}

+ (void)setNextButtonImage:(UIImage *)nextButtonImage
{
    __nextButtonImage = nextButtonImage;
}

+ (UIImage *)prevButtonImage
{
    return __prevButtonImage;
}

+ (void)setPrevButtonImage:(UIImage *)nextButtonImage
{
    __prevButtonImage = nextButtonImage;
}

#pragma mark Colors

+ (UIColor *)buttonColor
{
    return __buttonColor;
}

+ (void)setButtonColor:(UIColor *)color
{
    __buttonColor = color;
}

+ (UIColor *)tintColor
{
    return __tintColor;
}

+ (void)setTintColor:(UIColor*)color
{
    __tintColor = color;
}

+ (UIColor *)textBackgroundColor
{
    return __textBackgroundColor;
}

+ (void)setTextBackgroundColor:(UIColor*)color
{
    __textBackgroundColor = color;
}

+ (UIColor *)textColor
{
    return __textColor;
}

+ (void)setTextColor:(UIColor*)color
{
    __textColor = color;
}

+ (UIColor *)titleColor
{
    return __titleColor;
}

+ (void)setTitleColor:(UIColor*)color
{
    __titleColor = color;
}

#pragma mark - public method

+ (void)presentTutorial:(NSString*)tutorial force:(BOOL)force
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:tutorial] && !force) {
        // already displayed tutorial
        return;
    }
    
    // mark as displayed
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:tutorial];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // make and show tutorial
    PXTutorialManager * manager = [[PXTutorialManager alloc] initManager];
    if (![manager loadTutorial:tutorial]) {
        // error occurred, check the logs.
        return;
    }
    [manager show];
}

#pragma mark - private methods

/**
 *  Private init so people don't use it externally.
 *
 *  @return new PXTutorialManager
 */
- (instancetype)initManager
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    if (self == nil)
        return nil;
    
    _tutorial = [NSMutableArray array];
    
    _backgroundImageView = [[PXImageView alloc] init];
    [_backgroundImageView setContentMode:PXContentModeTop];
    [_backgroundImageView setBackgroundColor:[UIColor whiteColor]];
    [_backgroundImageView setImage:[PXTutorialManager backgroundImage]];
    [_backgroundImageView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_backgroundImageView];
    
    _carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_carousel setType:iCarouselTypeCustom];
    [_carousel setDelegate:self];
    [_carousel setDataSource:self];
    [_carousel setCurrentItemIndex:0];
    [_carousel setBounces:FALSE];
    [_carousel setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_carousel];
    
    _titleView = [[UILabel alloc] init];
    [_titleView setTextColor:[PXTutorialManager titleColor]];
    [_titleView setTextAlignment:NSTextAlignmentCenter];
    [_titleView setFont:[PXTutorialManager titleFont]];
    [_titleView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_titleView];
    
    _textBackground = [[UIView alloc] init];
    [_textBackground setBackgroundColor:[PXTutorialManager textBackgroundColor]];
    [_textBackground setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_textBackground];
    
    _textView = [[UILabel alloc] init];
    [_textView setNumberOfLines:0];
    [_textView setTextColor:[PXTutorialManager textColor]];
    [_textView setFont:[PXTutorialManager font]];
    [_textView setLineBreakMode:NSLineBreakByWordWrapping];
    [_textView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [_textBackground addSubview:_textView];
    
    _textView2 = [[UILabel alloc] init];
    [_textView2 setAlpha:0.0f];
    [_textView2 setNumberOfLines:0];
    [_textView2 setTextColor:[PXTutorialManager textColor]];
    [_textView2 setFont:[PXTutorialManager font]];
    [_textView2 setLineBreakMode:NSLineBreakByWordWrapping];
    [_textView2 setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [_textBackground addSubview:_textView2];
    
    _dividerLine = [[UIView alloc] init];
    [_dividerLine setBackgroundColor:[[PXTutorialManager tintColor] colorWithAlphaComponent:0.5f]];
    [_dividerLine setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_dividerLine];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setTintColor:[PXTutorialManager tintColor]];
    [[_backButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_backButton setImage:[[PXTutorialManager prevButtonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_backButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_backButton];
    
    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forwardButton setTintColor:[PXTutorialManager tintColor]];
    [[_forwardButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [_forwardButton setImage:[[PXTutorialManager nextButtonImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_forwardButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_forwardButton];
    
    _doneButton = [PXButton button];
    [_doneButton setTitle:__finalButtonTitle forState:UIControlStateNormal];
    [[_doneButton titleLabel] setFont:[PXTutorialManager titleFont]];
    [_doneButton setBackgroundColor:[PXTutorialManager buttonColor]];
    [_doneButton setTitleColor:[PXTutorialManager titleColor] forState:UIControlStateNormal];
    [_doneButton setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_doneButton];
    
    _pageIndicator = [[UIPageControl alloc] init];
    [_pageIndicator setCurrentPage:0];
    [_pageIndicator setNumberOfPages:1];
    [_pageIndicator setUserInteractionEnabled:FALSE];
    [_pageIndicator setBackgroundColor:[UIColor clearColor]];
    [_pageIndicator setPageIndicatorTintColor:[[PXTutorialManager tintColor] colorWithAlphaComponent:0.5]];
    [_pageIndicator setCurrentPageIndicatorTintColor:[PXTutorialManager tintColor]];
    [_pageIndicator setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self addSubview:_pageIndicator];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(_backgroundImageView, _titleView, _carousel, _textView, _textView2, _textBackground, _backButton, _forwardButton, _pageIndicator, _dividerLine, _doneButton);
    NSDictionary* metrics = @{@"sp" : @8.0f, @"th" : @44.0f, @"bh" : @40, @"tsp" : @15, @"bw" : @40, @"sp2" : @18, @"lh" : @0.5f, @"tbh" : @170, @"ssp" : @5, @"pbw" : @80, @"pbh" : @35};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImageView]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView]|" options:0 metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleView]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_carousel]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textBackground]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sp-[_dividerLine]-sp-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-tsp-[_titleView(th)][_carousel]-sp-[_textBackground(tbh)]|" options:0 metrics:metrics views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pageIndicator]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_forwardButton(bw)]-sp-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_doneButton(pbw)]-sp-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sp-[_backButton(bw)]" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_doneButton(pbh)]" options:0 metrics:metrics views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_pageIndicator attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_pageIndicator attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_forwardButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_pageIndicator attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_backButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_pageIndicator attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_forwardButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_pageIndicator attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_dividerLine(lh)]-ssp-[_pageIndicator(bh)]-ssp-|" options:0 metrics:metrics views:views]];
    
    // tutorial text views
    [_textBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sp2-[_textView]-sp2-|" options:0 metrics:metrics views:views]];
    [_textBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-sp2-[_textView2]-sp2-|" options:0 metrics:metrics views:views]];
    [_textBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[_textView]-bh-|" options:0 metrics:metrics views:views]];
    [_textBackground addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[_textView2]-bh-|" options:0 metrics:metrics views:views]];
    
    return self;
}

/**
 *  Loads the tutorial assets from the bundle and creates the appropriate pages.
 *  If loading fails, the caller is responsible for dealing with the lack of tutorial.
 *
 *  @param tutorial the name of the tutorial to load
 *
 *  @return whether or not the tutorial loaded successfully
 */
- (BOOL)loadTutorial:(NSString*)tutorial
{
    // load tutorial assets
    NSString * tutorialFile;
    if ([tutorial isEqualToString:PXTutorialDemoTutorial]) {
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"PXTutorialManager" ofType:@"bundle"];
        tutorialFile = [[NSBundle bundleWithPath:bundlePath] pathForResource:tutorial ofType:@"json"];
    } else {
        tutorialFile = [[NSBundle mainBundle] pathForResource:tutorial ofType:@"json"];
    }
    if (!tutorialFile) {
        NSLog(@"no such file: %@", [NSString stringWithFormat:@"%@.json", tutorial]);
        
        // no such tutorial
        return FALSE;
    }
    
    NSError * error;
    NSString * tutorialJSON = [[NSString alloc] initWithContentsOfFile:tutorialFile encoding:NSUTF8StringEncoding error:&error];
    
    if (!tutorialJSON) {
        NSLog(@"error opening tutorial file: %@", [error description]);
        
        // file problems
        return FALSE;
    }
    
    NSDictionary * tutorialDict = [tutorialJSON JSONValue];
    
    if ([[tutorialDict objectForKey:StorageFormatVersionKey] floatValue] < StorageFormatVersion) {
        NSLog(@"Tutorial file version %f is out of date with the current version %f.", [[tutorialDict objectForKey:StorageFormatVersionKey] floatValue], StorageFormatVersion);
        
        // wrong version
        return FALSE;
    }
    
    NSArray * pageArray = [tutorialDict objectForKey:TutorialPageArrayKey];
    
    for (NSDictionary * pageDict in pageArray) {
        PXTutorialPage * page = [[PXTutorialPage alloc] init];
        
        [page setTitle:[pageDict objectForKey:TutorialPageTitleKey]];
        [page setText:[pageDict objectForKey:TutorialPageTextKey]];
        [page setImage:[UIImage px_imageNamed:[pageDict objectForKey:TutorialPageImageNameKey]]];
        
        [_tutorial addObject:page];
    }
    
    // background 
    if (tutorialDict[TutorialBackgroundImageNameKey]) {
        [_backgroundImageView setImage:[UIImage px_imageNamed:tutorialDict[TutorialBackgroundImageNameKey]]];
    }
    
    // done title
    if (tutorialDict[TutorialDoneTitleKey]) {
        [_doneButton setTitle:tutorialDict[TutorialDoneTitleKey] forState:UIControlStateNormal];
    }
    
    return TRUE;
}

- (void)show
{
    // set up view too
    [_carousel reloadData];
    [_pageIndicator setNumberOfPages:[_tutorial count]];
    [self carouselCurrentItemIndexDidChange:_carousel]; // call manually because I'm lazy
    [_doneButton addTarget:self action:@selector(postPressed) forControlEvents:UIControlEventTouchUpInside];
    [_backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
    [_forwardButton addTarget:self action:@selector(forwardPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // add self to window for to be on top of all the things
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
    
    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            // make a blur view with the window
            [self setFrame:[window bounds]];
            [self setAlpha:0.0f];
            [self setUserInteractionEnabled:TRUE];
            [window addSubview:self];
            [self layoutIfNeeded]; // ensure no jumping
            break;
        }
    }
    
    [UIView animateWithDuration:0.5f  delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setAlpha:1.0f];
    } completion:^(BOOL finished){
        
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self setAlpha:0.0f];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

- (void)swapMessageForMessage:(NSString*)message
{
    // swap existing message with new one.
    [_textView2 setText:message];
        
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [_textView2 setAlpha:1.0f];
        [_textView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [_textView setText:[_textView2 text]];
        [_textView2 setAlpha:0.0f];
        [_textView setAlpha:1.0f];
    }];
}

- (void)changeToPage:(NSInteger)page
{
    [_carousel scrollToItemAtIndex:page animated:TRUE];
}

#pragma mark - button handlers

- (void)backPressed
{
    NSInteger currentPage = [_carousel currentItemIndex];
    
    if (!currentPage) {
        // no more back
        return;
    }
    
    [self changeToPage:(currentPage - 1)];
}

- (void)forwardPressed
{
    NSInteger currentPage = [_carousel currentItemIndex];
    
    if (currentPage == ([_tutorial count] - 1)) {
        // no more forward
        return;
    }
    
    [self changeToPage:(currentPage + 1)];
}

- (void)postPressed
{
    [self dismiss];
}

#pragma mark - iCarousel data source methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_tutorial count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView * imageView = nil;
    
    //create new view if no view is available for recycling
    if (!view) {
        CGFloat width = [_carousel bounds].size.width * 0.9; // padding for images that go to the edges
        CGFloat height = [_carousel bounds].size.height;
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imageView = (id)view;
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
    } else {
        imageView = (id)view;
    }
    
    [imageView setImage:[(PXTutorialPage*)_tutorial[index] image]];
    
    return view;
}

#pragma mark - iCarousel delegate methods

-(CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    CGFloat spacing = [self carousel:carousel valueForOption:iCarouselOptionSpacing withDefault:1.0];
    
    // zoom out as you get further away.
    return CATransform3DTranslate(transform, offset * _carousel.itemWidth * spacing, 0.0, fabs(offset) * -100);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionOffsetMultiplier: {
            return 3;
        }
        case iCarouselOptionFadeMin: {
            return 0;
        }
        case iCarouselOptionFadeMax: {
            return 0;
        }
        case iCarouselOptionFadeRange: {
            return 6;
        }
        case iCarouselOptionWrap: {
            return FALSE;
        }
        case iCarouselOptionSpacing: {
            return 0.3; // magic number from testing.
        }
        default: {
            return value;
        }
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    // switch the tutorial message and title and move the page indicator
    NSInteger pageNum = [_carousel currentItemIndex];
    
    if (pageNum < 0 || pageNum >= [_tutorial count]) {
        return;
    }
    
    [_titleView setText:[_tutorial[pageNum] title]];
    [self swapMessageForMessage:[_tutorial[pageNum] text]];
    
    [_pageIndicator setCurrentPage:pageNum];
    
    [UIView animateWithDuration:0.1f animations:^{
        [_forwardButton setAlpha:!(pageNum == ([_tutorial count] - 1)) * 1];
        [_doneButton setAlpha:(pageNum == ([_tutorial count] - 1)) * 1];
    }];
}

@end
         
NSString * const PXTutorialDemoTutorial = @"com.pixio.demoTutorial";
