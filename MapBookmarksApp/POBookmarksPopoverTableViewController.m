//
//  POBookmarksTableViewController.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 12/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POBookmarksPopoverTableViewController.h"
#import "Location.h"
#import "POBookmarkTableViewCell.h"

@interface POBookmarksPopoverTableViewController ()

@end

@implementation POBookmarksPopoverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//     [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.blockGetIndexBookmark(indexPath.row);
}

@end
