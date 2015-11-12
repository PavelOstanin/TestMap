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

@interface POMainMapScreenViewController ()<MKMapViewDelegate, WYPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mainPlaceMap;
@property (strong, nonatomic) NSMutableArray *listOfPlace;
@property (strong, nonatomic) WYPopoverController* popoverController;
@property (strong, nonatomic) UITableView* bookmarksTable;

@end

@implementation POMainMapScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    NSManagedObjectContext *context = [[POCoreDataManager shared] managedObjectContext];
    Location *savingLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
    savingLocation.location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    NSError *error = nil;
    if (![context save:&error]){
        NSLog(@"Can't save %@ %@", error, [error localizedDescription]);
    }
    self.listOfPlace = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *SFAnnotationIdentifier = @"SFAnnotationIdentifier";
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *)[self.mainPlaceMap dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
    if (!pinView && [[annotation title] isEqualToString:@"MyLocation"]) {
        NSLog(@"%f",[annotation coordinate].latitude);
        NSLog(@"%f",[annotation coordinate].longitude);
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:SFAnnotationIdentifier];
        UIImage *flagImage = [UIImage imageNamed:@"arrow"];

        annotationView.image = flagImage;
        return annotationView;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}

#pragma mark - popover controller methods

- (IBAction)showPopover:(id)sender {
  //  UINavigationController* contentViewController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"bookmarksTable"]];
   // self.popoverController = [[WYPopoverController alloc] initWithContentViewController:contentViewController];
  //  self.popoverController.delegate = self;
   // [self.popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
    [self performSegueWithIdentifier:@"show" sender:self];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}
- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    self.popoverController.delegate = nil;
    self.popoverController = nil;
}

#pragma  mark - segue

- (IBAction)unwindFromBookmarksList:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"unwindToMap"]) {
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show"])
    {
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        UIViewController* destinationViewController = (UIViewController *)segue.destinationViewController;
        destinationViewController.contentSizeForViewInPopover = CGSizeMake(280, 280);       // Deprecated in iOS7. Use 'preferredContentSize' instead.
        
        self.popoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        self.popoverController.delegate = self;
    }
}
@end
