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
#import "POBookmarksPopoverTableViewController.h"
#import <WYPopoverController.h>
#import <WYStoryboardPopoverSegue.h>
#import "PODataFetcher.h"
#import "POBookmarkListTableViewController.h"
#import "PODetailInfoViewController.h"
#import <SAMHUDView.h>
#import "POCustomCalloutView.h"
#import "PODetailInfoViewController.h"

@interface POMainMapScreenViewController ()<MKMapViewDelegate, WYPopoverControllerDelegate, POCustomCalloutDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mainPlaceMap;
@property (strong, nonatomic) NSMutableArray *listOfPlace;
@property (strong, nonatomic) WYPopoverController* popoverController;
@property (assign, nonatomic) BOOL isDirection;
@property (strong, nonatomic) SAMHUDView *hud;
@property (strong, nonatomic) POCustomCalloutView *calloutView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

NSInteger currentAnnotationViewIndex;

@implementation POMainMapScreenViewController

#pragma mark - Lazy getter

-(NSManagedObjectContext*)managedObjectContext {
    if (!_managedObjectContext)
        _managedObjectContext = [POCoreDataManager shared].managedObjectContext;
    return _managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calloutView = [[POCustomCalloutView alloc] init];
    self.isDirection = NO;
    self.hud = [[SAMHUDView alloc] initWithTitle:@"Loading…" loading:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addMyLocationOnMap)
                                                 name:@"UpdateLocation"
                                               object:nil];
    self.navigationController.navigationBar.alpha = 0.5;
    self.listOfPlace = [NSMutableArray array];
    [[POLocationManager shared] initCurrentLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
    [self addBookmarksOnMap];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - add locations on map

- (void)addBookmarksOnMap {
    [[POLocationManager shared] removeBookmarksAnnotationOnMapView:self.mainPlaceMap];
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
    Location *savingLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    savingLocation.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    savingLocation.name = @"";
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]){
        NSLog(@"Can't save %@ %@", error, [error localizedDescription]);
    }
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
}

#pragma mark - popover controller methods

- (IBAction)showPopover:(id)sender {
    if (!self.isDirection) {
        [self performSegueWithIdentifier:@"showPopoverBookmarksList" sender:sender];
    }
    else {
        [self goToCenter:[POLocationManager shared].lastValidLocation.coordinate];
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

-(IBAction)unwindFromDetailInfo:(UIStoryboardSegue*)segue{
    PODetailInfoViewController *controller = segue.sourceViewController;
    if ([segue.identifier isEqualToString:@"unwindToMapDirection"]) {
        [self drawDirectionToLocation:((CLLocation*)controller.location.location)];
    }
    else if ([segue.identifier isEqualToString:@"unwindToCenterMap"]) {
        [self goToCenter:((CLLocation*)controller.location.location).coordinate];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPopoverBookmarksList"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        POBookmarksPopoverTableViewController* destinationViewController = segue.destinationViewController;
//        destinationViewController.contentSizeForViewInPopover = CGSizeMake(280, 280);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        destinationViewController.bookmarksList = self.listOfPlace;
        destinationViewController.block = ^(NSInteger index){
            Location *loc = self.listOfPlace[index];
            [self drawDirectionToLocation:((CLLocation*)loc.location)];
            [self.popoverController dismissPopoverAnimated:YES];
        };
        self.popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        self.popoverController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"segueDetailInfo"]){
        PODetailInfoViewController* destinitionViewController = segue.destinationViewController;
        destinitionViewController.location = self.listOfPlace[currentAnnotationViewIndex];
    }
}
#pragma mark - move/remove direction

-  (void)goToCenter:(CLLocationCoordinate2D)coordinate {
    [[POLocationManager shared] moveCenterMapTo:coordinate onMap:self.mainPlaceMap];
    self.isDirection = NO;
    self.navigationItem.leftBarButtonItem.title = @"Route";
    [self.mainPlaceMap removeOverlays:self.mainPlaceMap.overlays];
    [[POLocationManager shared] removeBookmarksAnnotationOnMapView:self.mainPlaceMap];
    [self addBookmarksOnMap];
}

- (void)drawDirectionToLocation:(CLLocation *)location{
    self.navigationItem.leftBarButtonItem.title = @"Clear route";
    self.isDirection = YES;
    [[POLocationManager shared] removeBookmarksAnnotationOnMapView:self.mainPlaceMap];
    [[POLocationManager shared] addLocation:location.coordinate onMapView:self.mainPlaceMap];
    [self.hud show];
    __weak __typeof(self)weakSelf = self;
    [PODataFetcher getPolyLineArrayFromStartCoordinate:[POLocationManager shared].lastValidLocation.coordinate toFinishCoordinate:location.coordinate onSuccess:^(NSMutableDictionary *result){
        [weakSelf.hud dismissAnimated:YES];
        if ([result objectForKey:@"routes"]) {
            MKPolyline *polyline = [[POLocationManager shared] getPoliLineFromRoutesArray:[result objectForKey:@"routes"]];
            [[POLocationManager shared] moveCenterMapInDrawDirectionTo:location onMap:weakSelf.mainPlaceMap];
            [weakSelf.mainPlaceMap addOverlay:polyline];
        }
    }failure:^(NSError *error){
        [weakSelf.hud dismissAnimated:YES];
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
                                                                        reuseIdentifier:@"myLocation"];
        UIImage *flagImage = [UIImage imageNamed:@"arrow"];
        annotationView.image = flagImage;
        return annotationView;
    }
    else {
        MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location"];
        annotationView.canShowCallout = NO;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
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
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"DetailsIphone" sender:view];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:YES];
    [self.calloutView removeFromSuperview];
    
    CLLocationCoordinate2D coord= CLLocationCoordinate2DMake([view.annotation coordinate].latitude, [view.annotation coordinate].longitude);
    for (Location *loc in self.listOfPlace){
        if (((CLLocation*)loc.location).coordinate.latitude == coord.latitude && ((CLLocation*)loc.location).coordinate.longitude == coord.longitude){
            self.calloutView = [POCustomCalloutView addCalloutViewWithLocation:loc];
            currentAnnotationViewIndex = [self.listOfPlace indexOfObject:loc];
            self.calloutView.delegate = self;
            self.calloutView.frame = CGRectMake(view.frame.origin.x - 50, view.frame.origin.y - 50, 200, 50);
            [self.mainPlaceMap addSubview:self.calloutView];
            break;
        }
    }
}

#pragma mark - Action

- (IBAction)dismissCalloutView:(UITapGestureRecognizer *)sender {
    [self.calloutView removeFromSuperview];
}

- (void)clickSegueButton:(POCustomCalloutView *)view {
    [self.calloutView removeFromSuperview];
    [self performSegueWithIdentifier:@"segueDetailInfo" sender:nil];
}

@end
