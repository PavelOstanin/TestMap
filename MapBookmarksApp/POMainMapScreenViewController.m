//
//  POMainMapScreenViewController.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 09/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POMainMapScreenViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "POCoreDataManager.h"
#import "Location.h"
#import "POLocationManager.h"

#import <WYPopoverController.h>

@interface POMainMapScreenViewController ()<MKMapViewDelegate, WYPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mainPlaceMap;
@property (weak, nonatomic) NSMutableArray *listOfPlace;
@property (strong, nonatomic) WYPopoverController* popoverController;

@end

@implementation POMainMapScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMyLocationOnMap) name:@"UpdateLocation" object:nil];
    self.navigationController.navigationBar.alpha = 0.5;
    self.mainPlaceMap.delegate = self;
    self.listOfPlace = [NSMutableArray array];
    
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
    for (Location *loc in self.listOfPlace){
        [[POLocationManager shared] addLocation:((CLLocation*)loc.location).coordinate onMapView:self.mainPlaceMap];
    }
    [[POLocationManager shared] initCurrentLocation];
}

#pragma mark - add current location on map

- (void)addMyLocationOnMap {
    [[POLocationManager shared] addMyLocationOnMapView:self.mainPlaceMap];
}

#pragma mark - long tap action

- (IBAction)handleGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded)
        return;
    CGPoint touchPoint = [sender locationInView:self.mainPlaceMap];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mainPlaceMap convertPoint:touchPoint toCoordinateFromView:self.mainPlaceMap];
    [[POLocationManager shared] addLocation:touchMapCoordinate onMapView:self.mainPlaceMap];
    NSManagedObjectContext *context = [[POCoreDataManager shared] managedObjectContext];
    Location *savingLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
    savingLocation.location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    NSError *error = nil;
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
    if (![context save:&error]){
        NSLog(@"Can't save %@ %@", error, [error localizedDescription]);
    }
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *SFAnnotationIdentifier = @"SFAnnotationIdentifier";
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *)[self.mainPlaceMap dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
    if (!pinView && [[annotation title] isEqualToString:@"MyLocation"])
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:SFAnnotationIdentifier];
        UIImage *flagImage = [UIImage imageNamed:@"arrow"];

        annotationView.image = flagImage;
        return annotationView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
}
- (IBAction)showPopover:(id)sender
{
    self.popoverController = [[WYPopoverController alloc] initWithContentViewController:self];
    self.popoverController.delegate = self;
    [self.popoverController presentPopoverFromRect:CGRectZero inView:nil permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    self.popoverController.delegate = nil;
    self.popoverController = nil;
}
@end
