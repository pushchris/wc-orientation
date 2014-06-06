//
//  SportsTableViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 11/10/13.
//
//

#import "SportsTableViewController.h"
#import "SportTableCell.h"
#import "Sport.h"

@interface SportsTableViewController ()

@end

@implementation SportsTableViewController

@synthesize sportResults;
@synthesize displayResults = _displayResults;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sportResults = [[NSMutableDictionary alloc] init];
    
    [sportResults setObject:[[NSArray alloc] init] forKey:@"0"];
    [sportResults setObject:[[NSArray alloc] init] forKey:@"1"];
    
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    [self loadSports];
    
//    Mixpanel *mixpanel = [Mixpanel sharedInstance];
//    [mixpanel track:@"Opened Sports" properties:@{}];
}

- (void)loadSports
{
    [sportResults setObject:[[NSArray alloc] init] forKey:@"0"];
    [sportResults setObject:[[NSArray alloc] init] forKey:@"1"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: kSports]];
        [self performSelectorOnMainThread:@selector(fetchedDataToCome:) withObject:data waitUntilDone:YES];
    });
}

- (void)refreshView:(UIRefreshControl *)sender {
    [self loadSports];
    [sender endRefreshing];
}

- (void)fetchedDataToCome:(NSData *)responseData
{
    if (responseData == nil) {
        return;
    }
    
    NSError *error;
    
    NSMutableArray *upcomingSports = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSMutableArray *sports = [[NSMutableArray alloc] init];
    for (NSDictionary *s in upcomingSports) {
        Sport *sport = [[Sport alloc] init];
        [sport jsonToSport:s];
        [sports addObject: sport];
    }
    
    
    [sportResults setObject:sports forKey:@"1"];
    [self.tableView reloadData];
    
    NSString *completedSportsUrl = [NSString stringWithFormat:@"%@/scores",kSports];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: completedSportsUrl]];
        [self performSelectorOnMainThread:@selector(fetchedDataCompleted:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedDataCompleted:(NSData *)responseData
{
    if (responseData == nil) {
        return;
    }
    
    NSError *error;
    
    NSArray *pastSports = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSMutableArray *reversedSports = [NSMutableArray arrayWithCapacity:[pastSports count]];
    NSEnumerator *reverseEnumerator = [pastSports reverseObjectEnumerator];
    for (id object in reverseEnumerator) {
        Sport *sport = [[Sport alloc] init];
        [sport jsonToSport:object];
        [reversedSports addObject:sport];
    }
    
    [sportResults setObject:reversedSports forKey:@"0"];
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
    if (sectionIndex == 0) {
        return @"Past";
    }
    return @"Upcoming";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[sportResults objectForKey:[NSString stringWithFormat:@"%ld", (long)section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Sport *sport = [[sportResults objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.section]] objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = @"SportTableCell";
    
    if ([sport.score count] > 0 && ![[sport.score objectForKey:@"school"] isEqual: @""]) {
        cellIdentifier = @"SportScoreTableCell";
    }
    
    SportTableCell *cell = (SportTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return [sport generateCell:cell];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Sport *sport = [[sportResults objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.section]] objectAtIndex:indexPath.row];
    if ([[sport.score objectForKey:@"other"] intValue] < [[sport.score objectForKey:@"school"] intValue]) {
        [cell setBackgroundColor:[UIColor colorWithRed:255/255.0f green:106/255.0f blue:0.0f alpha:.15f]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
