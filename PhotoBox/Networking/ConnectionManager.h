//
//  ConnectionManager.h
//  PhotoBox
//
//  Created by Nico Prananta on 8/31/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFOAuth1Client.h>

extern NSString *PhotoBoxAccessTokenDidAcquiredNotification;

@interface ConnectionManager : NSObject

+ (ConnectionManager *)sharedManager;

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) AFOAuth1Token *consumerToken;
@property (nonatomic, strong) AFOAuth1Token *oauthToken;
@property (nonatomic, assign, getter = isUserLoggedIn) BOOL userLoggedIn;
@property (nonatomic, assign) BOOL isShowingLoginPage;

- (void)setBaseURL:(NSURL *)baseURL
       consumerKey:(NSString *)consumerKey
    consumerSecret:(NSString *)consumerSecret
        oauthToken:(NSString *)oauthToken
       oauthSecret:(NSString *)oauthSecret;

- (void)startOAuthAuthorizationWithServerURL:(NSString *)serverStringURL;
- (void)continueOauthAuthorizationWithQuery:(NSString *)query;
- (void)openLoginFromStoryboardWithIdentifier:(NSString *)storyboardId;
- (void)deleteTokens;
- (void)logout;

- (void)connectAsTester;

+ (NSURL *)oAuthInitialUrlForServer:(NSString *)server;
+ (NSURL *)oAuthAccessUrlForServer:(NSString *)server;

@end
