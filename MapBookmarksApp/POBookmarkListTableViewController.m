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

@interface POBookmarkListTableViewController ()

@end

@implementation POBookmarkListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showDetailInfo"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Location *selectedLocation = self.bookmarksList[indexPath.row];
        ((PODetailInfoViewController*)segue.destinationViewController).location = selectedLocation;
    }
}

@end
