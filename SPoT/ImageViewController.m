//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Tatiana Kornilova on 2/22/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "ImageViewController.h"
#import "AttributedStringViewController.h"

#define MINIMUM_ZOOM_SCALE 0.2
#define MAXIMUM_ZOOM_SCALE 5.0

@interface ImageViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong,nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *splitViewBarButtonItem;
@property (nonatomic) BOOL stopZooming;
@property (strong, nonatomic) UIPopoverController *urlPopover;

@property (strong, nonatomic) UIPopoverController *myPopoverController;

@end

@implementation ImageViewController

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show URL"]) {
        return self.imageURL && !self.urlPopover.popoverVisible ? YES : NO;
    } else {
        
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue.destinationViewController isKindOfClass:[AttributedStringViewController class]]) {
            AttributedStringViewController *asc = (AttributedStringViewController *)segue.destinationViewController;
            asc.text = [[NSAttributedString alloc] initWithString:[self.imageURL description]];
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
                
            }
        }
     }
}


- (void)setTitle:(NSString *)title
{
    super.title =title;
    self.titleBarButtonItem.title =title;
}

-( void)setImageURL:(NSURL *)imageURL
{
    _imageURL=imageURL;
    [self resetImage];
}

-(void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize =CGSizeZero;
        self.imageView.image =nil;
        self.stopZooming =NO;

        NSData *imageData =[[NSData alloc] initWithContentsOfURL:self.imageURL];
        UIImage *image =[[UIImage alloc] initWithData:imageData];
        if (image) {
            self.scrollView.zoomScale =1.0;
            self.scrollView.contentSize  =image.size;
            self.imageView.image =image;
            self.imageView.frame =CGRectMake(0, 0, image.size.width, image.size.width);
        }
    }
}

// Disable autoZoom after the user performs a zoom (by pinching)
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.stopZooming = YES;
}

// set the image that needs to be scrolled by the scrollview
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

//- (void)viewWillLayoutSubviews {
- (void)viewDidLayoutSubviews{
	// Zoom the image to fill up the view
	if (self.imageView) [self fillView];    
}

- (void)fillView
{
   if (!self.stopZooming) {
        float wScale = self.view.bounds.size.width / self.imageView.bounds.size.width;
        float hScale = self.view.bounds.size.height / self.imageView.bounds.size.height;
        self.scrollView.zoomScale = MAX(wScale, hScale);
    NSLog(@"viewWillLayoutSubviews - Width: %d, Height: %d, Min Zoom Scale: %f",
          (int)self.view.bounds.size.width,
          (int)self.view.bounds.size.height,
          self.scrollView.zoomScale);
   }
}

-(UIImageView *)imageView
{
    if (!_imageView) _imageView =[[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

// viewDidLoad is callled after this view controller has been fully instantiated
//  and its outlets have all been hooked up.

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale =MINIMUM_ZOOM_SCALE ;
    self.scrollView.maximumZoomScale =MAXIMUM_ZOOM_SCALE;
    self.scrollView.delegate =self;
    [self resetImage];
    self.titleBarButtonItem.title =self.title;
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

#pragma mark - Split View Controller

// Puts the splitViewBarButton in our toolbar (and/or removes the old one).
// Must be called when our splitViewBarButtonItem property changes
//  (and also after our view has been loaded from the storyboard (viewDidLoad)).

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolBar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}
/*
- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
 */
@end
