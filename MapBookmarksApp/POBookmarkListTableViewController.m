//
//  POBookmarkListTableViewController.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 16/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POBookmarkListTableViewController.h"
#import "Location.h"
#import "POBookmarkTableViewCell.h"
#import "PODetailInfoViewController.h"
#import "POCoreDataManager.h"

@interface POBookmarkListTableViewController ()

@property (strong, nonatomic) NSMutableArray *bookmarksList;
@property (assign, nonatomic) BOOL isEditStyle;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation POBookmarkListTableViewController

#pragma mark - Lazy getter

-(NSManagedObjectContext*)managedObjectContext {
    if (!_managedObjectContext)
        _managedObjectContext = [POCoreDataManager shared].managedObjectContext;
    return _managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isEditStyle = NO;
    self.bookmarksList = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
    [self.tableView reloadData];
}

#pragma mark - Action

- (IBAction)editButtonAction:(id)sender {
    self.isEditStyle = !self.isEditStyle;
    self.navigationItem.rightBarButtonItem.title = self.isEditStyle ? @"Done" : @"Edit";
}

#pragma mark - Table view data source, Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bookmarksList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    POBookmarkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell setNameWithLocation:self.bookmarksList[indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isEditStyle;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.managedObjectContext deleteObject:self.bookmarksList[indexPath.row]];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]){
            NSLog(@"Can't delete %@ %@", error, [error localizedDescription]);
        }
        [self.bookmarksList removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showDetailInfo"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Location *selectedLocation = self.bookmarksList[indexPath.row];
        ((PODetailInfoViewController*)segue.destinationViewController).location = selectedLocation;
    }
}

@end
