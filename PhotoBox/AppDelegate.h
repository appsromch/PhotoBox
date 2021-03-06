//
//  AppDelegate.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/30/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBoxNavigationControllerDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) PhotoBoxNavigationControllerDelegate *navigationDelegate;

@end
