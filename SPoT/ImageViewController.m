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

@interface ImageViewController ()<UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong,nonatomic) UIImageView *imageView;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale =MINIMUM_ZOOM_SCALE ;
    self.scrollView.maximumZoomScale =MAXIMUM_ZOOM_SCALE;
    self.scrollView.delegate =self;
    [self resetImage];
    self.titleBarButtonItem.title =self.title;
}
#pragma mark - Split View Controller

- (void)awakeFromNib  // always try to be the split view's delegate
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void) splitViewController:(UISplitViewController *)svc
      willHideViewController:(UIViewController *)aViewController
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)pc
{
    // add button to toolbar
    barButtonItem.title = @"Tags";
    // tell the detail view to put this button up
    NSMutableArray *items = [[self.toolBar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolBar setItems:items animated:YES];
    self.myPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove button from toolbar
    NSMutableArray *items = [[self.toolBar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolBar setItems:items animated:YES];
    self.myPopoverController = nil;
}
- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    if (self.splitViewController) {
        // iPad
        return UIInterfaceOrientationIsPortrait(orientation);
    } else {
        // iPhone
        return NO;
    }
}

@end
