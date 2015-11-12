//
//  POLocationManager.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 10/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface POLocationManager : NSObject <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

+ (instancetype)shared;
- (void)initCurrentLocation;
- (void)addLocation:(CLLocationCoordinate2D)location onMapView:(MKMapView*)mapView;
- (void)addMyLocationOnMapView:(MKMapView*)mapView;

@end
