//
//  PXViewController.m
//  PXTutorialManager
//
//  Created by Daniel Blakemore on 05/01/2015.
//  Copyright (c) 2014 Daniel Blakemore. All rights reserved.
//

#import "PXViewController.h"

#import <PXTutorialManager/PXTutorialManager.h>

@interface PXViewController ()

@end

@implementation PXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [PXTutorialManager presentTutorial:@"APPtutorial" force:TRUE];
        
//        // themed version of the built-in demo tutorial
//        [PXTutorialManager setTextBackgroundColor:[UIColor grayColor]];
//        [PXTutorialManager setTintColor:[UIColor whiteColor]];
//        [PXTutorialManager setTextColor:[UIColor whiteColor]];
//        [PXTutorialManager presentTutorial:PXTutorialDemoTutorial force:TRUE];
    });
}

@end
