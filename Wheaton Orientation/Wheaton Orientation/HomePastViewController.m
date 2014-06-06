//
//  HomePastViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 12/14/13.
//
//

#import "HomePastViewController.h"
#import "SportTableCell.h"
#import "EventTableCell.h"
#import "MetraTableViewCell.h"
#import "Sport.h"

@interface HomePastViewController ()

@end

@implementation HomePastViewController

@synthesize home, scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    home = [[NSMutableArray alloc] init];
    
    NSMutableArray *sportSection = [[NSMutableArray alloc] init];
    [home addObject:sportSection];
    
    NSMutableArray *metraSection = [[NSMutableArray alloc] init];
    [home addObject:metraSection];
    
    [scrollView loaded:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [scrollView setDelegate:self];
    [scrollView setScrollEnabled:YES];
    [scrollView setAutoresizingMask:UIViewAutoresizingNone];
    
    [self load];
}

- (void)load
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:kHome parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = responseObject;
        
        [[home objectAtIndex:0] removeAllObjects];
        [[home objectAtIndex:1] removeAllObjects];
        
        NSArray *sportArray = [dic objectForKey:@"sports"];
        for (NSDictionary *s in sportArray) {
            Sport *sport = [[Sport alloc] init];
            [sport jsonToSport:s];
            [[home objectAtIndex:0] addObject:sport];
            [self.tableView reloadData];
        }
        
        NSArray *metraArray = [dic objectForKey:@"train"];
        for (NSDictionary *m in metraArray) {
            [[home objectAtIndex:1] addObject:m];
        }
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [home count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[home objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Sports";
    } else {
        return @"Metra";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        Sport *sport = [[home objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        NSString *cellIdentifier = @"SportTableCell";
        
        if ([sport.score count] > 0 && ![[sport.score objectForKey:@"school"] isEqual: @""]) {
            cellIdentifier = @"SportScoreTableCell";
        }
        
        SportTableCell *sportCell = (SportTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (sportCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
            sportCell = [nib objectAtIndex:0];
        }
        
        cell = [sport generateCell:sportCell];
    } else if (indexPath.section == 1) {
        
        NSString *cellIdentifier = @"MetraCell";
        NSString *cellFileName = @"MetraTableViewCell";
        
        NSDictionary *inbound = [[[home objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"inbound"];
        NSDictionary *outbound = [[[home objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"outbound"];
        
        MetraTableViewCell *eventCell = (MetraTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (eventCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellFileName owner:nil options:nil];
            eventCell = [nib objectAtIndex:0];
        }
        
        eventCell.origin.text = [inbound objectForKey:@"origin"];
        eventCell.destination.text = [inbound objectForKey:@"destination"];
        
        eventCell.departureTimeInbound.text = [inbound objectForKey:@"departure"];
        eventCell.departureTimeOutbound.text = [outbound objectForKey:@"departure"];
        
        cell = eventCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
