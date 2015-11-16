//
//  PODataFetcher.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 16/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PODataFetcher : NSObject

+ (void)getPolyLineArrayFromStartCoordinate:(CLLocationCoordinate2D)startCoordinate toFinishCoordinate:(CLLocationCoordinate2D)finishCoordinate onSuccess:(void (^)(NSMutableDictionary *result))success failure:(void (^)(NSError *error))failure;

@end
