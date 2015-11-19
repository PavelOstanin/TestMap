//
//  PODetailInfoViewController.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 17/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "PODetailInfoViewController.h"
#import "PODataFetcher.h"
#import "POCoreDataManager.h"
#import <SAMHUDView.h>

@interface PODetailInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *loadPlacesButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *listOfNearbyPlaces;
@property (strong, nonatomic) SAMHUDView *hud;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation PODetailInfoViewController

#pragma mark - Lazy getter

-(NSManagedObjectContext*)managedObjectContext {
    if (!_managedObjectContext)
        _managedObjectContext = [POCoreDataManager shared].managedObjectContext;
    return _managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hud = [[SAMHUDView alloc] initWithTitle:@"Loading…" loading:YES];
    self.listOfNearbyPlaces = [NSMutableArray array];
     [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    if ([self.location.name length]) {
        self.tableView.hidden = YES;
        self.name.text = self.location.name;
    }
    else {
        self.name.text = [NSString stringWithFormat:@"%f %f",((CLLocation*)self.location.location).coordinate.latitude, ((CLLocation*)self.location.location).coordinate.longitude];
        self.loadPlacesButton.hidden = NO;
        self.tableView.hidden = YES;
        [self getListOfPlaces];
    }
}

#pragma  mark - Action

- (IBAction)centerInMapAction:(id)sender {
    [self performSegueWithIdentifier:@"unwindToCenterMap" sender:self];
}

- (IBAction)buildRouteAction:(id)sender {
    [self performSegueWithIdentifier:@"unwindToMapDirection" sender:self];
}

- (IBAction)loadNearbyPlacesAction:(id)sender {
    [self getListOfPlaces];
}

- (IBAction)trashAction:(id)sender {
    [self deleteLocation];
    [self performSegueWithIdentifier:@"unwindToMap" sender:self];
}

- (void)getListOfPlaces {
    [self.hud show];
    __weak __typeof(self)weakSelf = self;
    [PODataFetcher getListOfNearbyPlacesWithCoordinate:((CLLocation*)self.location.location).coordinate onSuccess:^(NSMutableArray *result){
        weakSelf.listOfNearbyPlaces = [NSMutableArray arrayWithArray:result];
        [weakSelf.hud dismissAnimated:YES];
        [weakSelf changeHiden];
        [weakSelf.tableView reloadData];
    }failure:^(NSError *error){
        [weakSelf.hud dismissAnimated:YES];
    }];
}

#pragma mark - Table view data source, Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listOfNearbyPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [self.listOfNearbyPlaces[indexPath.row] valueForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeHiden];
    self.name.text = self.listOfNearbyPlaces[indexPath.row][@"name"];
    [self updateLocationName:self.listOfNearbyPlaces[indexPath.row][@"name"]];
}

#pragma mark - update/delete location

- (void)updateLocationName:(NSString*)name{
    Location *savingLocation = self.location;
    savingLocation.name = name;
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]){
        NSLog(@"Can't save %@ %@", error,[error localizedDescription]);
    }
}

- (void)deleteLocation {
    [self.managedObjectContext deleteObject:self.location];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]){
        NSLog(@"Can't delete %@ %@", error, [error localizedDescription]);
    }
}

- (void)changeHiden {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.view
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^ {
                            self.tableView.contentOffset = CGPointZero;
                            self.tableView.hidden = !self.tableView.hidden;
                            self.loadPlacesButton.hidden = !self.loadPlacesButton.hidden;
                        }
                        completion:nil];
    });
}

@end
