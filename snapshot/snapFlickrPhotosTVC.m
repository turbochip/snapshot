//
//  snapFlickrPhotosTVC.m
//  snapshot
//
//  Created by Chip Cox on 6/21/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "snapFlickrPhotosTVC.h"
#import "FlickrFetcher.h"

@interface snapFlickrPhotosTVC ()

@end

@implementation snapFlickrPhotosTVC

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
#warning must revisit this if multiple sections
    return [self.photos count];
}

- (void) setPhotos:(NSArray *)photos
{
    _photos=photos;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell" forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *photo = self.photos[indexPath.row];
    cell.textLabel.text=[photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)refreshPullDown:(UIRefreshControl *)sender
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t otherQ=dispatch_queue_create("Q", NULL);
    dispatch_async(otherQ, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    });
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
}

@end
