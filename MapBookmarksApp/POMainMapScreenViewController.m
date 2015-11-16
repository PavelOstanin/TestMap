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
#import "POBookmarksTableViewController.h"
#import <WYPopoverController.h>
#import <WYStoryboardPopoverSegue.h>
#import "PODataFetcher.h"

@interface POMainMapScreenViewController ()<MKMapViewDelegate, WYPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mainPlaceMap;
@property (strong, nonatomic) NSMutableArray *listOfPlace;
@property (strong, nonatomic) WYPopoverController* popoverController;
@property (assign, nonatomic) BOOL isDirection;

@end

@implementation POMainMapScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isDirection = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addMyLocationOnMap)
                                                 name:@"UpdateLocation"
                                               object:nil];
    self.navigationController.navigationBar.alpha = 0.5;
    self.mainPlaceMap.delegate = self;
    self.listOfPlace = [NSMutableArray array];
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
    [self addBookmarksOnMap];
    [[POLocationManager shared] initCurrentLocation];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - add locations on map

- (void)addBookmarksOnMap {
    for (Location *loc in self.listOfPlace) {
        [[POLocationManager shared] addLocation:((CLLocation*)loc.location).coordinate onMapView:self.mainPlaceMap];
    }
}

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
    [self saveBookmarkWithCoordinate:touchMapCoordinate];
}

#pragma mark - save location

- (void)saveBookmarkWithCoordinate:(CLLocationCoordinate2D)coordinate{
    NSManagedObjectContext *context = [[POCoreDataManager shared] managedObjectContext];
    Location *savingLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
    savingLocation.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSError *error = nil;
    if (![context save:&error]){
        NSLog(@"Can't save %@ %@", error, [error localizedDescription]);
    }
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
}

#pragma mark - popover controller methods

- (IBAction)showPopover:(id)sender {
    if (!self.isDirection) {
        [self performSegueWithIdentifier:@"show" sender:sender];
    }
    else {
        [[POLocationManager shared] moveCenterMapTo:[POLocationManager shared].lastValidLocation.coordinate onMap:self.mainPlaceMap];
        self.isDirection = NO;
        self.navigationItem.leftBarButtonItem.title = @"Route";
        [self.mainPlaceMap removeOverlays:self.mainPlaceMap.overlays];
        [[POLocationManager shared] removeBookmarksAnnotationOnMapView:self.mainPlaceMap];
        [self addBookmarksOnMap];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    self.popoverController.delegate = nil;
    self.popoverController = nil;
}

#pragma  mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        POBookmarksTableViewController* destinationViewController = (POBookmarksTableViewController *)segue.destinationViewController;
//        destinationViewController.contentSizeForViewInPopover = CGSizeMake(280, 280);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        destinationViewController.bookmarksList = [self.listOfPlace mutableCopy];
        destinationViewController.blockGetIndexBookmark = ^(NSInteger index){
            Location *loc = self.listOfPlace[index];
            self.navigationItem.leftBarButtonItem.title = @"Clear route";
            [self drawDirectionToLocation:((CLLocation*)loc.location)];
            [self.popoverController dismissPopoverAnimated:YES];
        };
        self.popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        self.popoverController.delegate = self;
    }
}
#pragma mark - move direction

- (void)drawDirectionToLocation:(CLLocation *)location{
    self.isDirection = YES;
    [[POLocationManager shared] removeBookmarksAnnotationOnMapView:self.mainPlaceMap];
    [[POLocationManager shared] addLocation:location.coordinate onMapView:self.mainPlaceMap];
    [PODataFetcher getPolyLineArrayFromStartCoordinate:[POLocationManager shared].lastValidLocation.coordinate toFinishCoordinate:location.coordinate onSuccess:^(NSMutableDictionary *result){
        if ([result objectForKey:@"routes"]) {
            MKPolyline *polyline = [[POLocationManager shared] getPoliLineFromRoutesArray:[result objectForKey:@"routes"]];
            [[POLocationManager shared] moveCenterMapInDrawDirectionTo:location onMap:self.mainPlaceMap];
            [self.mainPlaceMap addOverlay:polyline];
        }
    }failure:^(NSError *error){
        NSLog(@"%@",error.localizedDescription);
    }];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *annotationIdentifier = @"annotationIdentifier";
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *)[self.mainPlaceMap dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!pinView && [[annotation title] isEqualToString:@"MyLocation"]) {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:annotationIdentifier];
        UIImage *flagImage = [UIImage imageNamed:@"arrow"];
        annotationView.image = flagImage;
        return annotationView;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor colorWithRed:61.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:0.5];
    polylineView.lineWidth = 7;
    return polylineView;
}

@end
