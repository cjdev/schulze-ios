#import "SCHTallyViewController.h"

@interface SCHTallyViewController ()
- (void)configureView;
@end

@implementation SCHTallyViewController {
    NSMutableArray * _places;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary * candidateRank = _places[indexPath.row];
    
    UILabel *placeLabel = (UILabel*)[cell viewWithTag:1];
    placeLabel.text = [NSString stringWithFormat:@"%@", [candidateRank valueForKey:@"rank"]];
    
    // set the candidate name
    UILabel* candidateLabel = (UILabel*)[cell viewWithTag:2];
    candidateLabel.text = [candidateRank valueForKey:@"candidate"];
    
    // highlight the winner
    if ([[candidateRank valueForKey:@"rank"] isEqualToNumber:@1]) {
        UIColor * winnerColor = [UIColor colorWithRed:0.0f/255.0f green:153.0f/255.0f blue:26.0f/255.0f alpha:1.0f];
        placeLabel.textColor = winnerColor;
        candidateLabel.textColor = winnerColor;
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
    [self getElectionTally];
    [self configureView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)getElectionTally
{
    NSString * server = [[NSUserDefaults standardUserDefaults] stringForKey:@"Server"];
    NSString * escapedElectionName = [_electionName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString * urlString = [[NSString alloc] initWithFormat:@"%@/places/%@", server, escapedElectionName];
    //NSLog(@"%@", urlString);
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                          timeoutInterval:5];
    
    NSHTTPURLResponse * response = nil;
    NSError * errors = nil;
    NSData * result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errors];
    
    NSError * err = nil;
    NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&err];

    if (!_places) {
        _places = [[NSMutableArray alloc] init];
    }
    
    // jsonArray is a two dimmensional array, allowing for ties
    int rank = 1;
    for (NSArray* places in jsonArray) {
        for (NSString * candidate in places) {
            NSDictionary* d = @{ @"rank": [[NSNumber alloc] initWithInt:rank],
                                 @"candidate": candidate
                                 };
            [_places addObject:d];
        }
        rank++;
    }
    
    //NSLog(@"%@", _places);
}

@end
