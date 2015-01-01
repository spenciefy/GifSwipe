//
//  SYLikedMoviesCollectionViewController.m
//  Recco
//
//  Created by Cluster 5 on 7/10/14.
//  Copyright (c) 2014 Spencer Yen. All rights reserved.
//

#import "GSLikedGifsCollectionViewController.h"
#import "GSGif.h"
#import "GSGifView.h"
#import "GSPopOutView.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface GSLikedGifsCollectionViewController () {
    UIBarButtonItem *rightButton;
    BOOL isDeleteActive;
    int selectedIndexPath;
    
    NSMutableArray *flGifImages;
}
@end

@implementation GSLikedGifsCollectionViewController
@synthesize likedGifs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    rightButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style: UIBarButtonItemStylePlain target:self action:@selector(editLiked)];
    [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"AvenirNext-Regular" size:20.0], NSFontAttributeName,[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1] , NSForegroundColorAttributeName,
                                        nil] 
                              forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = rightButton;
    isDeleteActive = FALSE;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (IS_IPHONE_5) {
        flow.minimumLineSpacing = 10;
    } else if (IS_IPHONE_6){
        flow.minimumLineSpacing = self.view.frame.size.width/14;
    } else if (IS_IPHONE_6P) {
        flow.minimumLineSpacing = self.view.frame.size.width/10;
    }
    
    flGifImages = [[NSMutableArray alloc] init];

}

- (void)viewDidAppear:(BOOL)animated {
    for(GSGif *gif in likedGifs) {
        NSURL *gifURL = [NSURL URLWithString:gif.gifLink];
        NSString *gifFileName = [gifURL lastPathComponent];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *gifFileLocation = [NSString stringWithFormat:@"%@/liked_gifs/%@",documentsDirectory, gifFileName];
        NSData *gifData = [NSData dataWithContentsOfFile:gifFileLocation];
        
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
        [flGifImages addObject:gifImage];
        if(flGifImages.count == likedGifs.count) {
            [self.collectionView reloadData];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [likedGifs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"GifCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    GSGif *gif = [likedGifs objectAtIndex: indexPath.row];
    NSLog(@"gif: %@ at index: %li", gif.caption, (long)indexPath.row);
    UIImageView *backgroundImage = (UIImageView *)[cell viewWithTag: 1];
    backgroundImage.image = gif.blurredBackroundImage;
    
    if(flGifImages.count > 0){
        FLAnimatedImage *gifImage = [flGifImages objectAtIndex:indexPath.row];
        FLAnimatedImageView *gifImageView = [[FLAnimatedImageView alloc] initWithFrame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.width)];
        
        gifImageView.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds));
        gifImageView.clipsToBounds = YES;
        gifImageView.contentMode = UIViewContentModeScaleAspectFit;
        gifImageView.animatedImage = gifImage;
        [cell addSubview: gifImageView];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 5.f;
    cell.layer.masksToBounds = YES;
    cell.layer.borderWidth = 2.f;
    cell.layer.borderColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1].CGColor;
    
    UILabel *delete = (UILabel *)[cell viewWithTag: 2];
    if (isDeleteActive) {
        if(delete.alpha == 0.0)
            [UIView animateWithDuration: 0.3 animations: ^ {
                delete.alpha = 1.0;
            }];
    } else {
        if(delete.alpha == 1.0)
            [UIView animateWithDuration: 0.3 animations: ^ {
                delete.alpha = 0.0;
            }];
    }
    [cell addSubview: delete];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    double padding;
    if (IS_IPHONE_5) {
        padding = 10;
    } else if (IS_IPHONE_6) {
        padding = self.view.frame.size.width/14;
    } else if (IS_IPHONE_6P) {
        padding = self.view.frame.size.width/10;
    }
    NSLog(@"%f", self.view.frame.size.width);
    return UIEdgeInsetsMake(padding, padding, padding, padding);

}

-(void)backButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(isDeleteActive){
        selectedIndexPath = (int)indexPath.row;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Are you sure you want to delete this Gif from your liked Gifs?" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        [alert show];
    } else {
        GSPopOutView *gifView = [[GSPopOutView alloc] initWithFrame: CGRectMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame), self.view.frame.size.width/1.5, self.view.frame.size.height/1.5) gif:likedGifs[indexPath.row]];
        gifView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
        gifView.closeActionBlock = ^{
            //put close code here
        };
        gifView.shareActionBlock = ^{
            //put share code here
        };
        [self.view addSubview:gifView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [likedGifs removeObjectAtIndex: selectedIndexPath];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
 
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject: likedGifs];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:@"likedGifs"];
        [defaults synchronize];
    }
}

- (void)editLiked {
    [self.collectionView reloadData];
    if(!isDeleteActive){
        rightButton.title = @"View";
        isDeleteActive = TRUE;
    }else{
        rightButton.title = @"Edit";
        isDeleteActive = FALSE;
    }
}

@end
