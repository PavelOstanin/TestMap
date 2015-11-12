//
//  POLocationManager.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 10/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POLocationManager.h"


@implementation POLocationManager

static id instance;

+ (instancetype)shared{
    static dispatch_once_t once_Token;
    dispatch_once(&once_Token, ^{
        instance = [self new];
    });
    return instance;
}

- (void)initCurrentLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    [self.locationManager startUpdatingLocation];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
}

- (void)addLocation:(CLLocationCoordinate2D)location onMapView:(MKMapView*)mapView{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = location;
    [mapView addAnnotation:annotation];
}

- (void)addMyLocationOnMapView:(MKMapView*)mapView{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
    annotation.coordinate = self.locationManager.location.coordinate;
    annotation.title = @"MyLocation";
    [mapView addAnnotation:annotation];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 1000, 1000);
    [mapView setRegion:viewRegion animated:YES];
}

@end
