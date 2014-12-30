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

@interface GSLikedGifsCollectionViewController () {
    GSGif *gifObject;
    UIBarButtonItem *rightButton;
    BOOL isDeleteActive;
    int selectedIndexPath;
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
    self.navigationItem.rightBarButtonItem = rightButton;
    isDeleteActive = FALSE;
}

- (void)viewDidAppear:(BOOL)animated {

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [likedGifs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"GifCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    GSGifView *gifView = [likedGifs objectAtIndex: indexPath.row];
    
    UIImageView *backgroundImage = (UIImageView *)[cell viewWithTag: 1];
    backgroundImage.image = gifView.backgroundImageView.image;
    
    FLAnimatedImageView *gifImageView = gifView.gifImageView;
    gifImageView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.width);
    gifImageView.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds));
    gifImageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview: gifImageView];
    
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
    
    return cell;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

-(void)backButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(isDeleteActive){
        selectedIndexPath = indexPath.row;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Are you sure you want to delete this movie from your liked movies?" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        [alert show];
    } else {
        gifObject = [likedGifs objectAtIndex: indexPath.row];
        [self performSegueWithIdentifier:@"pushDetailFromLiked" sender:self];
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
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

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
