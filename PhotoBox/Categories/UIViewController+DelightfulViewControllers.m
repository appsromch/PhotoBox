//
//  UIViewController+DelightfulViewControllers.m
//  Delightful
//
//  Created by Nico Prananta on 11/21/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIViewController+DelightfulViewControllers.h"

#import <JASidePanelController.h>

#import "AppDelegate.h"

@implementation UIViewController (DelightfulViewControllers)

+ (id)mainPhotosViewController {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    JASidePanelController *rootViewController = (JASidePanelController *)delegate.window.rootViewController;
    UINavigationController *centerController = (UINavigationController *)rootViewController.centerPanel;
    return centerController.viewControllers[0];
}

@end