//
//  InstagramViewController.m
//  Wheaton Orientation
//
//  Created by Chris Anderson on 6/6/14.
//  Copyright (c) 2014 Chris Anderson. All rights reserved.
//

#import "InstagramViewController.h"
#import "InstagramKit.h"
#import "InstaCell.h"
#import "UIImageView+AFNetworking.h"
#import "GGFullscreenImageViewController.h"
#import "InstagramMedia.h"
#import "InstagramUser.h"


@implementation InstagramViewController
{
    NSMutableArray *mediaArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mediaArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mediaArray = [[NSMutableArray alloc] init];
    [self loadMedia];
    
    [self.collectionView setMultipleTouchEnabled:YES];
}

- (IBAction)reloadMedia
{
    if (mediaArray) {
        [mediaArray removeAllObjects];
    }
    
    [self loadMedia];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"TOUCHED");
}

- (void)loadMedia
{
    [[InstagramEngine sharedEngine] getMediaForUser:@"15328905" count:8 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        [mediaArray removeAllObjects];
        [mediaArray addObjectsFromArray:media];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Load Popular Media Failed");
        NSLog(@"%@", error);
    }];
    
//    [[InstagramEngine sharedEngine] searchUsersWithString:@"chrisanderson93" withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
//        NSLog(@"%@", ((InstagramUser *)[media objectAtIndex:0]).Id);
//    } failure:^(NSError *error) {
//    }];
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return mediaArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InstaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InstaCell" forIndexPath:indexPath];
    
    if (mediaArray.count >= indexPath.row+1) {
        InstagramMedia *media = mediaArray[indexPath.row];
        [cell.imageView setImageWithURL:media.thumbnailURL];
    } else {
        [cell.imageView setImage:nil];
    }
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GGFullscreenImageViewController *vc = [[GGFullscreenImageViewController alloc] init];
    InstaCell *cell = (InstaCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    InstagramMedia *media = mediaArray[indexPath.item];
    vc.liftedImageView = cell.imageView;
    vc.fullResolution = media.standardResolutionImageURL;
    NSLog(@"%@", media.standardResolutionImageURL);
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
