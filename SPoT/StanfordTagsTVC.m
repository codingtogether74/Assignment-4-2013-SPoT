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
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic, strong) NSArray *Tags;
@property (nonatomic, strong) NSDictionary *photosByTags;
@property (nonatomic, strong) NSSet *ignoredTags;
@end

@implementation StanfordTagsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [super viewDidLoad];
    self.photos = [FlickrFetcher stanfordPhotos];
    self.photosByTags =[self arrangedByTagsPhotos:self.photos];
    self.Tags =[[self.photosByTags allKeys] sortedArrayUsingSelector:@selector(compare:)];

 //   self.Tags =[self.photosByTags allKeys];
}

-(NSDictionary *)photosByTags
{
    if (!_photosByTags)
        _photosByTags =[[NSMutableDictionary alloc] init];
    return _photosByTags;
}
- (NSSet *)ignoredTags
{
    return [[NSSet alloc] initWithObjects:@"cs193pspot", @"portrait", @"landscape", nil];
}

-(NSDictionary *)arrangedByTagsPhotos:(NSArray *)photos
{
    // We want to divide the photos up by tag, so we can use a dictionary with the
	// tag name as key and the array of photos as values
	NSMutableDictionary *photosByTag = [NSMutableDictionary dictionary];
    
    NSMutableSet *tags =[[NSMutableSet alloc] init]; // set of tags for one photo
    for (NSDictionary *photo in photos) {
        NSArray *photoTags=[photo[FLICKR_TAGS] componentsSeparatedByString:@" "];
        [tags addObjectsFromArray:photoTags];
        [tags minusSet:self.ignoredTags];
        for (NSString *tag in tags) {
            // If tag isn't already in the dictionary, add it with a new array
            
            if (![photosByTag objectForKey:tag]) {
                [photosByTag setObject:[NSMutableArray array] forKey:tag];
            }
            // Add the photo to the tags' value array
            [(NSMutableArray *)[photosByTag  objectForKey:tag] addObject:photo];
        }
    }
	return [NSDictionary dictionaryWithDictionary:photosByTag];
    
    //   return [[NSArray alloc] initWithArray:[tags allObjects]];
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
            if ([segue.identifier isEqualToString:@"Show Photos For Tag"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
 //                   NSArray *photos = [self arrayOfPhotosWithTag:[[self titleForRow:indexPath.row] lowercaseString]];
                    NSArray *photos = [NSArray arrayWithArray:(NSMutableArray *)[self.photosByTags  objectForKey:self.Tags[indexPath.row]]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photos];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}

@end