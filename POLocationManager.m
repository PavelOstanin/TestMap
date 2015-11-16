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
    self.locationManager.distanceFilter = 100;
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
    annotation.title = @"Bookmark";
    [mapView addAnnotation:annotation];
}

- (void)addMyLocationOnMapView:(MKMapView*)mapView{
    NSPredicate *predicat = [NSPredicate predicateWithFormat:@"title == %@",@"MyLocation"];
    [mapView removeAnnotations:[mapView.annotations filteredArrayUsingPredicate:predicat]];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = self.lastValidLocation.coordinate;
    annotation.title = @"MyLocation";
    [mapView addAnnotation:annotation];
    [self moveCenterMapTo:self.lastValidLocation.coordinate onMap:mapView];
}

- (void)removeBookmarksAnnotationOnMapView:(MKMapView*)mapView {
    NSPredicate *predicat = [NSPredicate predicateWithFormat:@"title == %@",@"Bookmark"];
    [mapView removeAnnotations:[mapView.annotations filteredArrayUsingPredicate:predicat]];
}

- (MKPolyline*)getPoliLineFromRoutesArray:(NSArray*)routes {
    NSDictionary *firstRoute = [routes objectAtIndex:0];
    NSDictionary *leg =  [[firstRoute objectForKey:@"legs"] objectAtIndex:0];
    NSArray *steps = [leg objectForKey:@"steps"];
    int stepIndex = 0;
    CLLocationCoordinate2D stepCoordinates[1  + [steps count] + 1];
    stepCoordinates[stepIndex] = self.lastValidLocation.coordinate;
    
    for (NSDictionary *step in steps) {
        NSDictionary *start_location = [step objectForKey:@"start_location"];
        stepCoordinates[++stepIndex] = [self coordinateWithLocation:start_location];
        if ([steps count] == stepIndex){
            NSDictionary *end_location = [step objectForKey:@"end_location"];
            stepCoordinates[++stepIndex] = [self coordinateWithLocation:end_location];
        }
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:stepCoordinates count:1 + stepIndex];
    return polyLine;
}

- (CLLocationCoordinate2D)coordinateWithLocation:(NSDictionary*)location {
    double latitude = [[location objectForKey:@"lat"] doubleValue];
    double longitude = [[location objectForKey:@"lng"] doubleValue];
    return CLLocationCoordinate2DMake(latitude, longitude);
}

- (void)moveCenterMapInDrawDirectionTo:(CLLocation*)location onMap:(MKMapView*)mapView{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((self.lastValidLocation.coordinate.latitude + location.coordinate.latitude)/2.0 , (self.lastValidLocation.coordinate.longitude + location.coordinate.longitude)/2.0);
    CLLocationDistance meters = [self.lastValidLocation distanceFromLocation:location];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 1.5 * meters, 1.5 * meters);
    [mapView setRegion:viewRegion animated:YES];
}

- (void)moveCenterMapTo:(CLLocationCoordinate2D)location onMap:(MKMapView*)mapView{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 1000, 1000);
    [mapView setRegion:viewRegion animated:YES];
}
@end
