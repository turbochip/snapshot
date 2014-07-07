//
//  ccImageViewController.m
//  imaginarium
//
//  Created by Chip Cox on 6/21/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "ccImageViewController.h"

@interface ccImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ccImageViewController

- (void) setImageURL:(NSURL *)imageURL
{
    _imageURL=imageURL;
    [self startDownloadingImage];
}

- (void) startDownloadingImage
{
    self.image = nil;
    if (self.imageURL) {
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                if([request.URL isEqual:self.imageURL]) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^{ self.image=image;});
                }
            }
        }];
        [task resume];
    }
}

- (UIImageView *) imageView
{
    if(!_imageView) _imageView=[[UIImageView alloc] init];
    return _imageView;
}

- (void) setScrollView:(UIScrollView *)scrollView
{
    _scrollView=scrollView;
    self.scrollView.contentSize=self.image ? self.image.size : CGSizeZero;
    self.scrollView.minimumZoomScale=0.2;
    self.scrollView.maximumZoomScale=2.0;
    [self.scrollView setDelegate:self];
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (UIImage *) image
{
    return self.imageView.image;
}

- (void) setImage:(UIImage *)image
{
    self.scrollView.zoomScale=1.0;
    self.imageView.image=image;
    self.imageView.frame=CGRectMake(0,0,image.size.width,image.size.height);
    self.scrollView.contentSize=self.image ? self.image.size :CGSizeZero ;
    float scale=self.scrollView.frame.size.width/self.image.size.width;
    self.scrollView.zoomScale=scale;
    [self.spinner stopAnimating];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void) awakeFromNib
{
    self.splitViewController.delegate=self;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

-(void) splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    if(aViewController.title)
        barButtonItem.title=aViewController.title;
    else
        barButtonItem.title=@"Show Menu";
    self.navigationItem.leftBarButtonItem=barButtonItem;
}

-(void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem=nil;
}

@end
