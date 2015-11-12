//
//  POBookmarksTableViewController.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 12/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POBookmarksTableViewController.h"
#import "POCoreDataManager.h"
#import "Location.h"

@interface POBookmarksTableViewController ()

@property (strong, nonatomic) NSMutableArray *bookmarksList;

@end

@implementation POBookmarksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookmarksList = [[POCoreDataManager shared] fetchRequestWithEntityName:@"Location"];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bookmarksList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",((Location*)self.bookmarksList[indexPath.row]).location];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"unwindToMap" sender:self];
}

@end
