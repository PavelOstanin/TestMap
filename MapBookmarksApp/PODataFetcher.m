//
//  PODataFetcher.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 16/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "PODataFetcher.h"
#import <AFNetworking/AFNetworking.h>


@implementation PODataFetcher

+ (void)getPolyLineArrayFromStartCoordinate:(CLLocationCoordinate2D)startCoordinate toFinishCoordinate:(CLLocationCoordinate2D)finishCoordinate onSuccess:(void (^)(NSMutableDictionary *result))success failure:(void (^)(NSError *error))failure {

    NSString *requestString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true", startCoordinate.latitude,  startCoordinate.longitude, finishCoordinate.latitude, finishCoordinate.longitude];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
//        NSArray *routes = [responseObject objectForKey:@"routes"];
//        NSDictionary *firstRoute = [routes objectAtIndex:0];
//        NSDictionary *leg =  [[firstRoute objectForKey:@"legs"] objectAtIndex:0];
//        NSArray *steps = [leg objectForKey:@"steps"];
//        int stepIndex = 0;
//        CLLocationCoordinate2D stepCoordinates[1  + [steps count] + 1];
//        stepCoordinates[stepIndex] = currentLocation;
//        
//        for (NSDictionary *step in steps) {
//            NSDictionary *start_location = [step objectForKey:@"start_location"];
//            stepCoordinates[++stepIndex] = [self coordinateWithLocation:start_location];
//            if ([steps count] == stepIndex){
//                NSDictionary *end_location = [step objectForKey:@"end_location"];
//                stepCoordinates[++stepIndex] = [self coordinateWithLocation:end_location];
//            }
//        }
//        self.polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:1 + stepIndex];
//        polilyne(self.polyLine);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}


@end
