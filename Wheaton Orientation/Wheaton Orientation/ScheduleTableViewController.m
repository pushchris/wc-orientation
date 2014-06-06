//
//  FreshmenTableViewController.m
//  Wheaton Orientation
//
//  Created by Chris Anderson on 6/4/14.
//  Copyright (c) 2014 Chris Anderson. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "WebViewController.h"
#import "EventAutoTableViewCell.h"

static NSString *cellIdentifier = @"EventAutoTableViewCell";


@implementation ScheduleTableViewController
{
    NSMutableArray *eventResults;
    NSInteger *displayResults;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[EventAutoTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    [self loadSchedule];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)loadSchedule
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: kSchedule]];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)refreshView:(UIRefreshControl *)sender {
    [self loadSchedule];
    [sender endRefreshing];
}

- (void)fetchedData:(NSData *)responseData
{
    if (responseData == nil) {
        return;
    }
    
    // parse out the json data
    NSError *error;
    NSDictionary *schedule = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    if (self.tableView.tag == 1) {
        eventResults  = [schedule objectForKey:@"transfers"];
    } else if (self.tableView.tag == 2) {
        eventResults  = [schedule objectForKey:@"parents"];
    } else {
        eventResults  = [schedule objectForKey:@"freshmen"];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [eventResults count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[eventResults objectAtIndex:section] objectForKey:@"day"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[eventResults objectAtIndex:section] objectForKey:@"events"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EventAutoTableViewCell *cell = (EventAutoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *result = [[[eventResults objectAtIndex:indexPath.section] objectForKey:@"events"] objectAtIndex:indexPath.row];
    
    [cell updateFonts];
    
    cell.dateLabel.text = [result valueForKey:@"time"];
    cell.bodyLabel.text = [result valueForKey:@"title"];
    cell.locationLabel.text = [result valueForKey:@"location"];
    //cell.bodyLabel.text = [result valueForKey:@"description"];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}


- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventAutoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell for this indexPath
    [cell updateFonts];
    NSDictionary *result = [[[eventResults objectAtIndex:indexPath.section] objectForKey:@"events"] objectAtIndex:indexPath.row];
    cell.dateLabel.text =  [result valueForKey:@"time"];
    cell.bodyLabel.text = [result valueForKey:@"title"];
    cell.locationLabel.text =  [result valueForKey:@"location"];
    //cell.bodyLabel.text = [result valueForKey:@"description"];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // Set the width of the cell to match the width of the table view. This is important so that we'll get the
    // correct height for different table view widths, since our cell's height depends on its width due to
    // the multi-line UILabel word wrapping. Don't need to do this above in -[tableView:cellForRowAtIndexPath]
    // because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 500.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EventDetailView" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WebViewController *detailViewController = [segue destinationViewController];
    NSIndexPath *indexPath = sender;
    detailViewController.url = [NSURL URLWithString:[[[eventResults objectAtIndex:indexPath.row] objectForKey:@"custom"] objectForKey:@"link"]];
}



@end
