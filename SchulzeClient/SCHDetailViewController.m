#import "CJAffiliate.h"
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
    //NSLog(@"%@", urlString);
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
    _candidates = [[NSMutableArray alloc] initWithCapacity:[jsonArray count]];
    
    [_candidateVotes removeAllObjects];
    for (NSDictionary * item in jsonArray) {
        // if there is no vote, store a 0 in the dict; nulls cannot be stored in the dict
        NSNumber * rank = [item valueForKey:@"rank"];
        [_candidateVotes setObject:((rank == nil) ? [NSNull null] : rank) forKey:[item valueForKey:@"candidate"]];
        [_candidates addObject:[item valueForKey:@"candidate"]];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    [self.view endEditing:YES];
    return YES;
}

-(NSArray*) buildVotesJSONStructure {
    NSMutableArray * transformedVotes = [[NSMutableArray alloc] initWithCapacity:[_candidateVotes count]];
    for (id candidate in _candidateVotes) {
        //NSLog(@"candidate: %@ rank: %@", candidate, [_candidateVotes objectForKey:candidate]);
        
        NSString * rank = [_candidateVotes objectForKey:candidate];
        
        //convert nulls to empty strings
        if (![_candidateVotes objectForKey:candidate]) {
            rank = @"";
        }
        
        NSDictionary * voteDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   candidate, @"candidate",
                                   rank, @"rank",nil];
        [transformedVotes addObject:voteDict];
    }
    //NSLog(@"%@", transformedVotes);
    return transformedVotes;

}

-(BOOL)putVoteToServer {
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[self getVotingUrl]
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:5];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSArray * votesArray = [self buildVotesJSONStructure];
    
    NSError *error = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:votesArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSHTTPURLResponse * response = nil;
    NSError * errors = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response error:&errors];
    if (errors != nil) {
        //NSLog(@"%@", [errors localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Cannot reach server."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (response.statusCode != 200) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Server rejected vote."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    [self reportVotes:votesArray];
    
    return YES;
}

-(void) reportVotes:(NSArray* ) votes {
    
    NSMutableArray * voteItems = [NSMutableArray arrayWithCapacity:votes.count];
    for (NSDictionary* vote in votes) {
        CJAFItem* item = [CJAFItem itemWithSKU:[NSString stringWithFormat:@"%@:%@",
                               [vote objectForKey:@"candidate"],
                               [vote objectForKey:@"rank"]]];
        //NSLog(@"%@", item);
        [voteItems addObject:item];
    }
    
    NSString * voter = [[NSUserDefaults standardUserDefaults] stringForKey:@"Voter"];
    [CJAF reportInAppEvent:@"voteEvent"
               withOrderId:[NSString stringWithFormat:@"%@:%@", _electionName, voter]
              withSaleInfo:[CJAFSaleInfo itemizedSale:voteItems]];
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
