//
//  MoreTableViewController.m
//  Wheaton App
//
//  Created by Chris Anderson on 11/11/13.
//
//

#import "MoreTableViewController.h"
#import "WebViewController.h"

@interface MoreTableViewController ()

@end

@implementation MoreTableViewController {
    NSMutableArray *moreTable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    moreTable = [[NSMutableArray alloc] init];
    
    [self generateTable];
    
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self generateTable];
    [super viewWillAppear:animated];
}

- (void)generateTable
{
    [moreTable removeAllObjects];
    
    NSMutableDictionary *optionsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
    
    [optionsDictionary setObject:@"Extra" forKey:@"header"];
    
    NSMutableDictionary *songOption = [[NSMutableDictionary alloc] init];
    WebViewController *songVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    songVC.url = [NSURL URLWithString:kSong];
    [songOption setValue:@"Class Song" forKey:@"name"];
    [songOption setValue:songVC forKey:@"controller"];
    [optionsArray addObject:songOption];
    
    NSMutableDictionary *lingoOption = [[NSMutableDictionary alloc] init];
    WebViewController *lingoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    lingoVC.url = [NSURL URLWithString:kLingo];
    [lingoOption setValue:@"Learn the Lingo" forKey:@"name"];
    [lingoOption setValue:lingoVC forKey:@"controller"];
    [optionsArray addObject:lingoOption];
    
    [optionsDictionary setObject:optionsArray forKey:@"array"];
    [moreTable addObject:optionsDictionary];
    
/*    NSMutableDictionary *chapelOption = [[NSMutableDictionary alloc] init];
    WebViewController *cVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    cVC.allowZoom = YES;
    cVC.url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"chapel" ofType:@"pdf"]];
    [chapelOption setValue:@"Chapel Seat Layout" forKey:@"name"];
    [chapelOption setValue:cVC forKey:@"controller"];
    [optionsArray addObject:chapelOption];*/
    
    NSMutableDictionary *endDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *endArray = [[NSMutableArray alloc] init];
    
    [endDictionary setObject:@"" forKey:@"header"];
    
    NSMutableDictionary *aboutOption = [[NSMutableDictionary alloc] init];
    WebViewController *aVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebView"];
    aVC.url = [NSURL URLWithString:kAbout];
    [aboutOption setValue:@"About" forKey:@"name"];
    [aboutOption setValue:aVC forKey:@"controller"];
    [endArray addObject:aboutOption];
    
    [endDictionary setObject:endArray forKey:@"array"];
    [moreTable addObject:endDictionary];
    
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
    // Return the number of sections.
    return [moreTable count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[moreTable objectAtIndex:section] objectForKey:@"array"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
    NSDictionary *entry = [moreTable objectAtIndex:sectionIndex];
    
    return [entry objectForKey:@"header"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [[moreTable objectAtIndex:indexPath.section] objectForKey:@"array"];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:@"name"];
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [[[moreTable objectAtIndex:indexPath.section]
                          objectForKey:@"array"]
                         objectAtIndex:indexPath.row];
    UIViewController *selected = [dic objectForKey:@"controller"];
    selected.title = [dic objectForKey:@"name"];
    [self.navigationController
     pushViewController:selected
     animated:YES];
}

@end
