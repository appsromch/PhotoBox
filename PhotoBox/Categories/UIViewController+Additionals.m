//
//  UIViewController+Additionals.m
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import "UIViewController+Additionals.h"

#import "OpenInActivity.h"

#import <Social/Social.h>
#import <objc/runtime.h>

#define kLoadingViewTag 87261
#define HAVE_SHOWN_NO_FACEBOOK @"HAVE_SHOWN_NO_FACEBOOK"
#define HAVE_SHOWN_NO_TWITTER @"HAVE_SHOWN_NO_TWITTER"

static char const * const documentControllerKey = "documentControllerKey";
static char const * const isNavigationBarHidden = "isNavigationBarHidden";

@implementation UIViewController (Additionals)

- (void)showLoadingView:(BOOL)show atBottomOfScrollView:(BOOL)bottom {
    if ([self isKindOfClass:[UICollectionViewController class]]) {
        UICollectionViewController *cv = (UICollectionViewController *)self;
        if (show) {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cv.collectionView viewWithTag:kLoadingViewTag];
            if (!activity) {
                activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [activity setTag:kLoadingViewTag];
                [cv.collectionView addSubview:activity];
            }
            CGSize contentSize = cv.collectionView.contentSize;
            [activity setCenter:CGPointMake(contentSize.width/2, contentSize.height+CGRectGetHeight(activity.frame)/2+10)];
            [activity startAnimating];
            UIEdgeInsets inset = cv.collectionView.contentInset;
            [cv.collectionView setContentInset:UIEdgeInsetsMake(inset.top, inset.left, CGRectGetHeight(activity.frame)*2, inset.right)];
        } else {
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cv.collectionView viewWithTag:kLoadingViewTag];
            [activity stopAnimating];
            [activity removeFromSuperview];
        }
    }
    
}

- (void)showAlertForNoService:(NSString *)service {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:service message:[NSString stringWithFormat:NSLocalizedString(@"Please log in to %1$@ from Settings app if you want to share to %2$@", nil), service, service] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
}

- (void)openActivityPickerForImage:(UIImage *)image {
    void (^UIActivityViewControllerCompletionHandler)(NSString*, BOOL) = ^(NSString *activityType, BOOL completed){
        if (completed) {
            if ([activityType isEqualToString:@"openin.activity"]) {
                [self performSelector:@selector(showDocumentInteractionController:) withObject:image afterDelay:0.3];
            } else if ([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
                
            }
        }
    };
    
    OpenInActivity *openIn = [[OpenInActivity alloc] init];
    [self openActivityPickerForItem:image applicationActivities:@[openIn] completion:nil activityCompletionHandler:UIActivityViewControllerCompletionHandler];
}

- (void)openActivityPickerForURL:(NSURL *)URL completion:(void (^)())completion {
    [self openActivityPickerForItem:URL applicationActivities:nil completion:completion activityCompletionHandler:nil];
}

- (void)openActivityPickerForItem:(id)item applicationActivities:(NSArray *)activities completion:(void(^)())completion activityCompletionHandler:(void(^)(NSString *, BOOL))activityCompletionHandler{
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:activities];
    [activityViewController setTitle:@"Share Photo's URL"];
    [activityViewController setCompletionHandler:activityCompletionHandler];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact]];
    [self presentViewController:activityViewController animated:YES completion:completion];
    
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:HAVE_SHOWN_NO_FACEBOOK]) {
            [self showAlertForNoService:NSLocalizedString(@"Facebook", nil)];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HAVE_SHOWN_NO_FACEBOOK];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:HAVE_SHOWN_NO_TWITTER]) {
                [self showAlertForNoService:NSLocalizedString(@"Twitter", nil)];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HAVE_SHOWN_NO_TWITTER];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } else {
        if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:HAVE_SHOWN_NO_TWITTER]) {
                [self showAlertForNoService:NSLocalizedString(@"Twitter", nil)];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HAVE_SHOWN_NO_TWITTER];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

- (void)showDocumentInteractionController:(UIImage *)image {
    NSURL *url = [self prepareFileToSendToOtherApp:image];
    UIDocumentInteractionController *documentController = objc_getAssociatedObject(self, documentControllerKey);
    if (!documentController) {
        documentController = [UIDocumentInteractionController interactionControllerWithURL: url];
        objc_setAssociatedObject(self, documentControllerKey, documentController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [documentController setURL:url];
    [documentController setAnnotation:@{@"InstagramCaption" : @" #scribeit"}];
    [documentController presentOpenInMenuFromRect:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) inView:self.view animated:YES];
}

- (NSURL *)prepareFileToSendToOtherApp:(UIImage *)image {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:@"savedImage.ig"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:savedImagePath atomically:NO];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:savedImagePath];
    return url;
}

- (void)setNavigationBarHidden:(BOOL)hide animated:(BOOL)animated {
    if (hide) {
        CLS_LOG(@"Hiding navigation bar");
    } else {
        CLS_LOG(@"Showing navigaiton bar");
    }
    if (animated) {
        [[UIApplication sharedApplication] setStatusBarHidden:hide
                                                withAnimation:UIStatusBarAnimationFade];
        
        //Fade navigation bar
        [UINavigationBar beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3]; // Approximately the same time the status bar takes to fade.
        
        self.navigationController.navigationBar.alpha = hide ? 0 : 1;
        
        [UINavigationBar commitAnimations];
        
        objc_setAssociatedObject(self, isNavigationBarHidden, @(hide), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:hide];
        self.navigationController.navigationBar.alpha = (hide)?0:1;
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)hideNavigationBar {
    [self setNavigationBarHidden:YES animated:YES];
}

- (void)toggleNavigationBarHidden
{
    BOOL hide = !([objc_getAssociatedObject(self, isNavigationBarHidden) boolValue]);
    //Fade status bar
    [self setNavigationBarHidden:hide animated:YES];
}

@end
