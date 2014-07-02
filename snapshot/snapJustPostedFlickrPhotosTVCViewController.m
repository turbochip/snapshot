//
//  snapJustPostedFlickrPhotosTVCViewController.m
//  snapshot
//
//  Created by Chip Cox on 6/21/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "snapJustPostedFlickrPhotosTVCViewController.h"
#import "FlickrFetcher.h"

@interface snapJustPostedFlickrPhotosTVCViewController ()
   
@end

@implementation snapJustPostedFlickrPhotosTVCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchPhotos];
}

- (void) fetchPhotos
{
    [self.refreshControl beginRefreshing];
    NSURL *url= [FlickrFetcher URLforRecentGeoreferencedPhotos];
    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ,^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
        NSLog(@"Flickr results = %@", propertyListResults);
        NSArray *photos=[propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.photos=photos;
        });
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
