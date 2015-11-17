//
//  PODataFetcher.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 16/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "PODataFetcher.h"
#import <AFNetworking/AFNetworking.h>

static NSString *clientId = @"XADXAOPXCVJITGC5LR32KBKI4V1NIQZGY5XBHC3WYTCMUO5P";
static NSString *clientSecret = @"OFGVJAQEZTQGZFGPZ5OOHBWBGFJ3BJCJV1Z5NZJKWCFUBX1V";

@implementation PODataFetcher

+ (void)getPolyLineArrayFromStartCoordinate:(CLLocationCoordinate2D)startCoordinate toFinishCoordinate:(CLLocationCoordinate2D)finishCoordinate onSuccess:(void (^)(NSMutableDictionary *result))success failure:(void (^)(NSError *error))failure {

    NSString *requestString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true", startCoordinate.latitude,  startCoordinate.longitude, finishCoordinate.latitude, finishCoordinate.longitude];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+ (void)getListOfNearbyPlacesWithCoordinate:(CLLocationCoordinate2D)coordinate onSuccess:(void (^)(NSMutableArray *result))success failure:(void (^)(NSError *error))failure {
    
    NSString *requestString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%f,%f", clientId,clientSecret,coordinate.latitude,coordinate.longitude];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject[@"response"][@"venues"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
