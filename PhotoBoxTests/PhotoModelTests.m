//
//  PhotoModelTests.m
//  PhotoBox
//
//  Created by Nico Prananta on 9/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Photo.h"
#import "Album.h"
#import "Tag.h"

#import "NSArray+Additionals.h"

#import "XCTestCase+Additionals.h"

@interface PhotoModelTests : XCTestCase

@end

@implementation PhotoModelTests

- (void)setUp
{
    [super setUp];
    if ([NSPersistentStoreCoordinator persistentStoreCoordinator]) {
        [NSPersistentStoreCoordinator clearPersistentStore];
    }
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testPhotoObjectJSONSerialization
{    
    NSError *error;
    NSDictionary *photoDictionary = [self objectFromJSONFile:@"photo"];
    Photo *photo = [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:photoDictionary error:&error];
    XCTAssert([photo.photoId isEqualToString:[photoDictionary objectForKey:@"id"]], @"Expected photoId = %@. Actual = %@", [photoDictionary objectForKey:@"id"], photo.photoId);
    XCTAssert([photo.dateUploadedMonth intValue]==[photoDictionary[@"dateUploadedMonth"] intValue], @"Expected %d. Actual %d", [photoDictionary[@"dateUploadedMonth"] intValue], [photo.dateUploadedMonth intValue]);
    XCTAssertTrue(photo.thumbnailImage, @"Expected thumbnail image");
    XCTAssert(photo.albums.count == ((NSArray *)[photoDictionary objectForKey:@"albums"]).count, @"Expected %d albums. Actual %d.",  ((NSArray *)[photoDictionary objectForKey:@"albums"]).count, photo.albums.count);
    XCTAssertTrue([photo.thumbnailImage.urlString isEqualToString:[photoDictionary objectForKey:@"path320x320"]], @"Expected thumbnail image url %@. Actual %@", [photoDictionary objectForKey:@"path320x320"], photo.thumbnailImage.urlString);
    XCTAssertTrue([photo.normalImage.urlString isEqualToString:[photoDictionary objectForKey:@"path640x640"]], @"Expected normal image url %@. Actual %@", [photoDictionary objectForKey:@"path640x640"], photo.normalImage.urlString);
    XCTAssertTrue([photo.pathOriginal.absoluteString isEqual:[photoDictionary objectForKey:@"pathOriginal"]], @"Expected %@. Actual = %@", [photoDictionary objectForKey:@"pathOriginal"], photo.pathOriginal.absoluteString);
    XCTAssert([photo.dateTakenString isEqualToString:@"2013-06-03"], @"Expected date taken string: 2013-06-03. Actual = %@", photo.dateTakenString);
    XCTAssert(photo.tags.count == 4, @"Expected 4 tags. Actual = %d", photo.tags.count);
    XCTAssert([photo.tags[0] isKindOfClass:[NSString class]], @"Expected NSString class. Actual %@", NSStringFromClass([photo.tags[0] class]));
    XCTAssert([((NSString *)photo.tags[0]) isEqualToString:@"2013"], @"Expected tag: 2013. Actual %@", ((Tag *)photo.tags[0]).tagId);
}

- (void)testPhotoObjectManagedObjectSerialization {
    NSError *error;
    NSDictionary *photoDictionary = [self objectFromJSONFile:@"photo"];
    Photo *photo = [MTLJSONAdapter modelOfClass:[Photo class] fromJSONDictionary:photoDictionary error:&error];
    NSManagedObject *photoManagedObject = [MTLManagedObjectAdapter managedObjectFromModel:photo insertingIntoContext:[NSManagedObjectContext mainContext] error:&error];
    XCTAssert(photoManagedObject != nil, @"Photo managed object should not be nil. Error: %@", error);
    XCTAssert([[photoManagedObject valueForKey:@"photoId"] isEqualToString:[photoDictionary objectForKey:@"id"]], @"Expected photo id = %@. Actual = %@", photoDictionary[@"id"], [photoManagedObject valueForKey:@"photoId"]);
    XCTAssertTrue([[photoManagedObject valueForKey:@"pathOriginal"] isEqualToString:photo.pathOriginal.absoluteString], @"Expected %@. Actual = %@", photo.pathOriginal.absoluteString, [photoManagedObject valueForKey:@"pathOriginal"]);
    XCTAssert([photoManagedObject valueForKey:@"dateTakenString"]!=nil, @"Date taken string should not be nil");
    NSArray *albums = [photoDictionary objectForKey:@"albums"];
    NSString *albumsString = [albums photoBoxArrayString];
    XCTAssert([[photoManagedObject valueForKey:@"albums"] isEqualToString:albumsString], @"Expected albums string = %@. Actual = %@.", albumsString, [photoManagedObject valueForKey:@"albums"]);
}

@end
