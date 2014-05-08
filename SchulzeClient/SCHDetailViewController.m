//
//  SCHDetailViewController.m
//  SchulzeClient
//
//  Created by Team NaN on 5/2/14.
//  Copyright (c) 2014 Commission Junction. All rights reserved.
//

#import "SCHDetailViewController.h"

@interface SCHDetailViewController ()
- (void)configureView;
@end

@implementation SCHDetailViewController {
    NSMutableArray* _candidates;
    NSMutableDictionary * _candidateVotes;
    UITableView * table;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self->table = tableView;
    return [[_candidateVotes allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString * candidate = _candidates[indexPath.row];
    
    // set the candidate name
    UILabel* label = (UILabel*)[cell viewWithTag:2];
    label.text = candidate;
    
    // update the text field tag to the row number
    UITextField *txtField = (UITextField*)[cell viewWithTag:1];
    txtField.tag = indexPath.row;
    
    NSString * rank = [_candidateVotes valueForKey:candidate];
    if ([_candidateVotes valueForKey:candidate] != [NSNull null]) {
        txtField.text = [NSString stringWithFormat:@"%@", rank];
    }
    
    return cell;
}

#pragma mark - Managing the detail item

- (void)setElectionName:(id)newElectionName
{
    if (_electionName != newElectionName) {
        _electionName = newElectionName;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    if (self.electionName) {
        self.detailDescriptionLabel.text = [self.electionName description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"Voter" ]
//                                                                              style:UIBarButtonItemStyleBordered
//                                                                             target:self action:nil];
    [self getElectionDetails];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL*) getVotingUrl
{
    NSString * server = [[NSUserDefaults standardUserDefaults] stringForKey:@"Server"];
    NSString * escapedVoterName = [[[NSUserDefaults standardUserDefaults] stringForKey:@"Voter"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString * escapedElectionName = [_electionName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString * urlString = [[NSString alloc] initWithFormat:@"%@/vote?voter=%@&election=%@", server, escapedVoterName, escapedElectionName];
    NSLog(@"%@", urlString);
    return [NSURL URLWithString:urlString];
}

- (void) getElectionDetails
{
    NSURLRequest * request = [NSURLRequest requestWithURL:[self getVotingUrl]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5];
    
    NSHTTPURLResponse * response = nil;
    NSError * errors = nil;
    NSData * result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    
    NSError * err = nil;
    NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&err];

    if (!_candidateVotes) {
        _candidateVotes = [[NSMutableDictionary alloc] initWithCapacity:[jsonArray count]];
    }
    
    [_candidateVotes removeAllObjects];
    for (NSDictionary * item in jsonArray) {
        // if there is no vote, store a 0 in the dict; nulls cannot be stored in the dict
        NSNumber * rank = [item valueForKey:@"rank"];
        [_candidateVotes setObject:((rank == nil) ? [NSNull null] : rank) forKey:[item valueForKey:@"candidate"]];
    }
    
    // clobber any existing array with new candidate list
    _candidates = [[NSMutableArray alloc] initWithArray:[_candidateVotes allKeys]];
    
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"begin editing %ld", (long)textField.tag);
    
//  UITableViewCell* cell = (UITableViewCell *) [[[textField superview] superview] superview];
//
//    [self->table scrollToRowAtIndexPath:[self->table indexPathForCell:cell]
//                       atScrollPosition:UITableViewScrollPositionMiddle
//                               animated:YES];
    
//    CGPoint origin = textField.frame.origin;
//    CGPoint point = [textField.superview convertPoint:origin toView:self->table];
//    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
//    CGPoint offset = self->table.contentOffset;
//    // Adjust the below value as you need
//    offset.y += (point.y - navBarHeight);
//    NSLog(@"origin:%f p:%f nav:%f offset:%f", origin.y, point.y, navBarHeight, offset.y);
//    [self->table setContentOffset:offset animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    [self.view endEditing:YES];
}

-(NSNumber *) parseVote:(NSString *)vote {
    NSNumber * rank = nil;
    if ([vote length] > 0) {
        if ([vote  isEqual: @"0"]) {
            rank = [NSNumber numberWithInt:0];
        }
        else {
            // integerValue will return 0 if it cannot parse an int from the value (i.e. "NAN")
            // in this case, leave the rank = nil
            NSInteger intValue = [vote integerValue];
            // only allow positive integers:
            //   no negative numbers
            //   no decimals (truncated by the integerValue call)
            if (intValue > 0) {
                rank = [NSNumber numberWithInt:intValue];
            }
        }
    }
    return rank;
}

-(IBAction)textFieldDidEndEditing:(UITextField *)textField {
    NSString * candidate = _candidates[textField.tag];
    NSString * vote = textField.text;
    NSNumber * rank = [self parseVote:vote];
    //NSLog(@"  end editing %ld, candidate %@ / (parsed) rank %@", (long)textField.tag, candidate, rank);

    // cannot store a nil in the dictionary
    [_candidateVotes setObject: (!rank) ? [NSNull null] : rank forKey:candidate];
    textField.text = [NSString stringWithFormat:@"%@", (!rank)?@"":rank];
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn!");
    [self.view endEditing:YES];
    return YES;
}



-(NSData*) buildVotesJSONData {
    NSMutableArray * transformedVotes = [[NSMutableArray alloc] initWithCapacity:[_candidateVotes count]];
    for (id candidate in _candidateVotes) {
        //NSLog(@"candidate: %@ rank: %@", candidate, [_candidateVotes objectForKey:candidate]);
        
        //convert nulls to empty strings
        NSString * rank = [_candidateVotes objectForKey:candidate];
        if (![_candidateVotes objectForKey:candidate]) {
            rank = @"";
        }
        
        NSDictionary * voteDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   candidate, @"candidate",
                                   rank, @"rank",nil];
        [transformedVotes addObject:voteDict];
    }
    //NSLog(@"%@", transformedVotes);
    
    NSError *error = nil;
    return [NSJSONSerialization dataWithJSONObject:transformedVotes
                                           options:NSJSONWritingPrettyPrinted
                                             error:&error];
}

-(BOOL)putVoteToServer {
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self getVotingUrl]
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:5];
    
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [self buildVotesJSONData];
    
    NSHTTPURLResponse * response = nil;
    NSError * errors = nil;
    NSData * result = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response error:&errors];
    if (errors != nil) {
        NSLog(@"%@", [errors localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Cannot reach server."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (response.statusCode != 200) {
        NSLog(@"RESULT %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Server rejected vote."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (IBAction)voteButtonClicked:(id)sender {
    if ([self putVoteToServer]) {
        NSLog(@"Successfully voted!");
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString* ) indentifier sender:(id)sender {
    return [self putVoteToServer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTally"]) {
        NSData * electionName = [self electionName];
        [[segue destinationViewController] setElectionName:electionName];
    }
}

@end
