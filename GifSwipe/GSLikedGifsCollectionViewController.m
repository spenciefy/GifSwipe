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
    UIVisualEffectView *blurView;
    GSPopOutView *gifView;
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
        if(gifImage) {
            [flGifImages addObject:gifImage];
        } else {
            [likedGifs removeObject:gif];
        }
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
        GSGif *gif = likedGifs[indexPath.row];
        gifView = [[GSPopOutView alloc] initWithFrame: CGRectMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame), self.view.frame.size.width/1.15, self.view.frame.size.height/1.15 - self.navigationController.navigationBar.frame.size.height) gif:gif];
        gifView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) + 20);
        gifView.alpha = 0;
 
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
        blurView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
        [blurView setFrame:[[[UIApplication sharedApplication] delegate] window].frame];
        [blurView addSubview:gifView];
        
        UIToolbar *gifViewToolbar = [[UIToolbar alloc] init];
        gifViewToolbar.frame = CGRectMake(gifView.frame.origin.x + 10, gifView.frame.origin.y - 54, (self.view.frame.size.width/1.15) - 20 , 44);
        [gifViewToolbar setBackgroundImage:[UIImage new]
                      forToolbarPosition:UIBarPositionAny
                              barMetrics:UIBarMetricsDefault];
        [gifViewToolbar setShadowImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny];
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareGif)];
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteGif)];
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissPopoutGifView)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        NSMutableArray *items = [@[shareButton,flexibleSpace, deleteButton,flexibleSpace,closeButton] mutableCopy];
        [gifViewToolbar setItems:items animated:NO];
        gifViewToolbar.tintColor = [UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
        [blurView addSubview:gifViewToolbar];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dismissPopoutGifView)];
        [blurView addGestureRecognizer:tap];
        [UIView transitionWithView:[[[UIApplication sharedApplication] delegate] window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations: ^ {
            blurView.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.0];
            [[[[UIApplication sharedApplication] delegate] window] addSubview:blurView];
        } completion:nil];
        
        [UIView animateWithDuration:0.5f animations:^{
            gifView.alpha = 1;
        }];
    }
}

- (void)dismissPopoutGifView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            gifView.alpha = 0;
            blurView.alpha = 0;
        } completion:^(BOOL finished) {
            [blurView removeFromSuperview];
        }];
    });
}

- (void)shareGif {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            gifView.alpha = 0;
            blurView.alpha = 0;
        } completion:^(BOOL finished) {
            [blurView removeFromSuperview];
            NSString *shareString = [NSString stringWithFormat:@"Check out this Gif I found via GifSwipe!\r\r%@\r",gifView.gif.caption];
            [self shareText:shareString andImage:nil andUrl:[NSURL URLWithString:gifView.gif.gifLink]];
        }];
    });

}

- (void)deleteGif {
    [likedGifs removeObjectAtIndex: selectedIndexPath];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: likedGifs];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"likedGifs"];
    [defaults synchronize];
    
    NSURL *gifURL = [NSURL URLWithString:gifView.gif.gifLink];
    NSString *gifFileName = [gifURL lastPathComponent];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gifFileLocation = [NSString stringWithFormat:@"%@/liked_gifs/%@",documentsDirectory, gifFileName];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:gifFileLocation error:&error];
    if(error) {
        NSLog(@"error in deleting: %@", error.description);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            gifView.alpha = 0;
            blurView.alpha = 0;
        } completion:^(BOOL finished) {
            [blurView removeFromSuperview];
        }];
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        GSGif *gif = likedGifs[selectedIndexPath];
 
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject: likedGifs];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:@"likedGifs"];
        [defaults synchronize];
        
        NSURL *gifURL = [NSURL URLWithString:gif.gifLink];
        NSString *gifFileName = [gifURL lastPathComponent];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *gifFileLocation = [NSString stringWithFormat:@"%@/liked_gifs/%@",documentsDirectory, gifFileName];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:gifFileLocation error:&error];
        
        [likedGifs removeObjectAtIndex: selectedIndexPath];
        [flGifImages removeObjectAtIndex:selectedIndexPath];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
 
        
        if(error) {
            NSLog(@"error in deleting: %@", error.description);
        }
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

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
