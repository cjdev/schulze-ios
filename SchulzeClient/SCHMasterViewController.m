//
//  SCHMasterViewController.m
//  SchulzeClient
//
//  Created by Team NaN on 5/2/14.
//  Copyright (c) 2014 Commission Junction. All rights reserved.
//

#import "SCHMasterViewController.h"
#import "SCHDetailViewController.h"

@interface SCHMasterViewController () {
    NSMutableArray *_elections;
}
@end

@implementation SCHMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"Voter" ]
//                                                                               style:UIBarButtonItemStyleBordered
//                                                                              target:self action:nil];
    [self getElections];
}

- (void) getElections
{
    NSString* server = [[NSUserDefaults standardUserDefaults] stringForKey:@"Server"];

    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[server stringByAppendingString:@"/elections"]]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5];
    NSHTTPURLResponse * response = nil;
    NSError * errors = nil;
    NSData * result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    
    NSError *err = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&err];
    
    if (!_elections) {
        _elections = [[NSMutableArray alloc] init];
    }
    [_elections removeAllObjects];
    for (NSDictionary *item in jsonArray) {
        [_elections addObject:[item valueForKey:@"name"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
//    if (!_objects) {
//        _objects = [[NSMutableArray alloc] init];
//    }
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _elections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *electionName = _elections[indexPath.row];
    cell.textLabel.text = electionName;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_elections removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSData *electionName = _elections[indexPath.row];
        [[segue destinationViewController] setElectionName:electionName];
    }
}

@end
