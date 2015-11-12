//
//  POLocationManager.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 10/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POLocationManager.h"


@implementation POLocationManager

+ (POLocationManager*)shared
{
    static POLocationManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[POLocationManager alloc] init];
        _sharedInstance.locationManager = [[CLLocationManager alloc]init];
        [ _sharedInstance.locationManager requestWhenInUseAuthorization];
        _sharedInstance.locationManager.delegate = _sharedInstance;
        
    });
    return _sharedInstance;
}
- (void)initCurrentLocation {
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    [self.locationManager startUpdatingLocation];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSTimeInterval closestLocationAge = [[NSDate date] timeIntervalSince1970];
    int i = 0;
    for(CLLocation *loc in locations)
    {
        CLLocationAccuracy accuracy = loc.horizontalAccuracy;
        NSTimeInterval locationAge = -[loc.timestamp timeIntervalSinceNow];
        ++i;
        if (locationAge > 15.0)
            continue;
        if (locationAge > closestLocationAge)
            continue;
        if (accuracy > 0 && accuracy < 1000.0 && (loc.coordinate.latitude != 0.0 || loc.coordinate.longitude != 0.0)) {
            self.lastValidLocation = loc;
            closestLocationAge = locationAge;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLocation" object:nil];
        }
    }
}

- (void)addLocation:(CLLocationCoordinate2D)location onMapView:(MKMapView*)mapView{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = location;
    [mapView addAnnotation:annotation];
}

- (void)addMyLocationOnMapView:(MKMapView*)mapView{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = self.lastValidLocation.coordinate;
    annotation.title = @"MyLocation";
    [mapView addAnnotation:annotation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 1000, 1000);
    [mapView setRegion:viewRegion animated:YES];
}

@end
