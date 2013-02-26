//
//  StanfordTagsTVC.m
//  SPoT
//
//  Created by Tatiana Kornilova on 2/22/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "StanfordTagsTVC.h"
#import "FlickrFetcher.h"


@interface StanfordTagsTVC ()

@property (nonatomic, strong) NSArray *Tags;
@property (nonatomic, strong) NSDictionary *photosByTags;
@property (nonatomic, strong) NSArray *ignoredTags;
@end

@implementation StanfordTagsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.photosByTags =[self arrangedByTagsPhotos:[FlickrFetcher stanfordPhotos]];
    self.Tags =[[self.photosByTags allKeys] sortedArrayUsingSelector:@selector(compare:)];
 }

-(NSDictionary *)photosByTags
{
    if (!_photosByTags)
        _photosByTags =[[NSMutableDictionary alloc] init];
    return _photosByTags;
}
- (NSArray *)ignoredTags
{
    return [[NSArray alloc] initWithObjects:@"cs193pspot", @"portrait", @"landscape", nil];
}

-(NSDictionary *)arrangedByTagsPhotos:(NSArray *)photos
{
    // We want to divide the photos up by tag, so we can use a dictionary with the
	// tag name as key and the array of photos as values
    
	NSMutableDictionary *photosByTag = [NSMutableDictionary dictionary];
    
    for (NSDictionary *photo in photos) {
 //-------
        NSMutableArray *photoTags=[[photo[FLICKR_TAGS] componentsSeparatedByString:@" "] mutableCopy]; //one photo tags
        [photoTags removeObjectsInArray:self.ignoredTags];
        //------
        for (NSString *tag in photoTags) {
            // If tag isn't already in the dictionary, add it with a new array
            
            if (![photosByTag objectForKey:tag]) {
                [photosByTag setObject:[NSMutableArray array] forKey:tag];
            }
            // Add the photo to the tags' value array
            [(NSMutableArray *)[photosByTag  objectForKey:tag] addObject:photo];
        }
    }
    return photosByTag;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return [self.Tags count];
}

-(NSString *)titleForRow:(NSUInteger)row
{
    return [self.Tags[row] capitalizedString];
}
-(NSString *)subTitleForRow:(NSUInteger)row
{
    int tagCount =[(NSMutableArray *)[self.photosByTags  objectForKey:self.Tags[row]] count];
    return [NSString stringWithFormat:@"%d photo%@",tagCount,(tagCount == 1) ? @"" : @"s"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subTitleForRow:indexPath.row];  // 
    
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            //-----------------------
            if ([segue.identifier isEqualToString:@"Show Photos For Tag"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSArray *photos = [NSArray arrayWithArray:(NSMutableArray *)[self.photosByTags  objectForKey:self.Tags[indexPath.row]]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photos];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
                //----------------------------
            }
        }
    }
}
@end
