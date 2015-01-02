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
#import "GSGifManager.h"
#import "GSGifCollectionViewCell.h"

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

#define GS_GIF_CELL_IDENTIFIER @"GS_GIF_CELL_IDENTIFIER"

@interface GSLikedGifsCollectionViewController () {
    UIBarButtonItem *rightButton;
    BOOL isDeleteActive;
    int selectedIndexPath;
    
    NSMutableArray *flGifImages;
    UIVisualEffectView *blurView;
    GSPopOutView *gifView;
}
@end

@implementation GSLikedGifsCollectionViewController {
    UILabel *nullStateLabel;
    FLAnimatedImageView *nullStateImageView;
}
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

    [self.collectionView registerNib:[UINib nibWithNibName:@"GSGifCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GSGifCollectionViewCell"];

    rightButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style: UIBarButtonItemStylePlain target:self action:@selector(editLiked)];
    [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"AvenirNext-Regular" size:20.0], NSFontAttributeName,[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1] , NSForegroundColorAttributeName,
                                        nil] 
                              forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = rightButton;
    isDeleteActive = FALSE;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    [self.collectionView registerClass:[GSGifCollectionViewCell class] forCellWithReuseIdentifier:GS_GIF_CELL_IDENTIFIER];

    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if (IS_IPHONE_5) {
        flow.minimumLineSpacing = 10;
    } else if (IS_IPHONE_6){
        flow.minimumLineSpacing = self.view.frame.size.width/14;
    } else if (IS_IPHONE_6P) {
        flow.minimumLineSpacing = self.view.frame.size.width/10;
    }
    
    flGifImages = [[NSMutableArray alloc] init];

    if(likedGifs.count == 0) {
        [self setupNullState];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if(likedGifs.count != 0) {
        for(GSGif *gif in [likedGifs copy]) {
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
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [likedGifs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    GSGif *gif = [likedGifs objectAtIndex: indexPath.row];
    GSGifCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:GS_GIF_CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.gif = gif;
    if(flGifImages.count > 0){
        cell.gifImage = [flGifImages objectAtIndex:indexPath.row];
    }
    
    if (isDeleteActive) {
        [UIView animateWithDuration: 0.3 animations: ^ {
            cell.deleteLabel.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration: 0.3 animations: ^ {
            cell.deleteLabel.alpha = 0.0;
        }];
    }
    
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
    [likedGifs removeObjectAtIndex:selectedIndexPath];
    [flGifImages removeObjectAtIndex:selectedIndexPath];
    [[GSGifManager sharedInstance].likedGifs removeObjectAtIndex:selectedIndexPath];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        if(self.likedGifs.count == 0) {
            [self setupNullState];
        }
    }];
    
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
        [[GSGifManager sharedInstance].likedGifs removeObjectAtIndex:selectedIndexPath];

        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished) {
            if(self.likedGifs.count == 0) {
                [self setupNullState];
            }
        }];
 
        
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

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url {
    dispatch_async(dispatch_get_main_queue(), ^() {

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
    });
}

- (void)setupNullState {
    nullStateImageView = [[FLAnimatedImageView alloc] init];
    nullStateImageView.frame = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 20, 250, 200);
    nullStateImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 50);
    nullStateImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSString *path=[[NSBundle mainBundle]pathForResource:@"nullstate" ofType:@"gif"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    
    FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
    nullStateImageView.animatedImage = gifImage;
    [self.view addSubview:nullStateImageView];
    
    nullStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 30, 300, 500)];
    nullStateLabel.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 80);
    nullStateLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:30];
    nullStateLabel.textColor = [UIColor darkGrayColor];//[UIColor colorWithRed:232/255.0 green:41/255.0 blue:78/255.0 alpha:1];
    nullStateLabel.numberOfLines = 5;
    nullStateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nullStateLabel.textAlignment = NSTextAlignmentCenter;
    nullStateLabel.text = @"Looks like you haven't swiped right to like any Gifs.";
    
    [self.view addSubview:nullStateLabel];
}

@end
