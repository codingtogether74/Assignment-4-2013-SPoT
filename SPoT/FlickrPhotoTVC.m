//
//  FlickrPhotoTVC.m
//  Shutterbug
//
//  Created by Tatiana Kornilova on 2/22/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "FlickrPhotoTVC.h"
#import "FlickrFetcher.h"
#import "RecentsUserDefaults.h"

@interface FlickrPhotoTVC ()

@end

@implementation FlickrPhotoTVC

-(void)setPhotos:(NSArray *)photos
{
    _photos =photos;
    [self.tableView reloadData];
}

#pragma mark - Segue 


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            //-----------------------------------
            if ([segue.identifier isEqualToString:@"Show image"]) {
                NSURL *url =[FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                    [RecentsUserDefaults saveRecentsUserDefaults:self.photos[indexPath.row]];
                }
            } else if ([segue.identifier isEqualToString:@"MyReplaceSegue"]){
                
                [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
                NSURL *url =[FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                    [RecentsUserDefaults saveRecentsUserDefaults:self.photos[indexPath.row]];
                }
            }
            //------------------------------
        }
    }
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photos count];
}

-(NSString *)titleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description];
}
-(NSString *)subTitleForRow:(NSUInteger)row
{
    // return [self.photos[row][FLICKR_PHOTO_OWNER] description];
    return [[self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description]; // description because could be NSNull
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];
    return cell;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // only iPad
        NSURL *url =[FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
        //----
        ImageViewController *photoViewController =
        (ImageViewController *) [[self.splitViewController viewControllers] lastObject];
        //-----
        if (photoViewController) {
            if ([photoViewController respondsToSelector:@selector(setImageURL:)]) {
                [photoViewController  performSelector:@selector(setImageURL:) withObject:url];
                [photoViewController  setTitle:[self titleForRow:indexPath.row]];
                [RecentsUserDefaults saveRecentsUserDefaults:self.photos[indexPath.row]];
            }
        }
    }
}
 */
-(id) splitViewDetailWithBarButtonItem
{
    id detail =[self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail =nil;
    return detail;
}
-(void) transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem =[[self splitViewDetailWithBarButtonItem] performSelector:@selector(splitViewBarButtonItem)];
    [[self splitViewDetailWithBarButtonItem] performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:splitViewBarButtonItem];
    }
}
/*
- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{

    barButtonItem.title = @"Tags";
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    [detailViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    [detailViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject: nil];

}

 -(BOOL)splitViewController:(UISplitViewController *)svc
 shouldHideViewController:(UIViewController *)vc
 inOrientation:(UIInterfaceOrientation)orientation
 {
    return UIInterfaceOrientationIsPortrait(orientation) ;
 }
*/ 

@end
