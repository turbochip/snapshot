//
//  snapLocationTVC.m
//  snapshot
//
//  Created by Chip Cox on 7/1/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "snapLocationTVC.h"
#import "FlickrFetcher.h"
#import "ccImageViewController.h"
#import "snapJustPostedFlickrPhotosTVCViewController.h"

@interface snapLocationTVC ()
@property (nonatomic,strong) NSMutableArray *country;
@property (nonatomic,strong) NSMutableArray *locationsInCountry;
@property (nonatomic,strong) NSMutableArray *loc;
@end

@implementation snapLocationTVC


- (void) fetchPhotos
{
    [self.refreshControl beginRefreshing];
    NSURL *url= [FlickrFetcher URLforTopPlaces];
    dispatch_queue_t fetchQ=dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ,^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
        NSLog(@"Flickr results = %@", propertyListResults);
        NSArray *locations=[propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.locations=locations;
            for(int i=0;i<[self.locations count]; i++) {
                NSMutableDictionary *d=[[self.locations objectAtIndex:i] mutableCopy];
                [d setValue:[[[d valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@","] lastObject] forKeyPath:@"Country"];
                [self.loc addObject:d];
            }
            self.locations=self.loc;
        });
    });
}

- (NSMutableArray *) country
{
    if(!_country) _country=[[NSMutableArray alloc] init];
    return _country;
}

- (NSMutableArray *) locationsInCountry
{
    if(!_locationsInCountry) _locationsInCountry=[[NSMutableArray alloc] init];
    return _locationsInCountry;
}

- (NSMutableArray *) loc
{
    if(!_loc) _loc=[[NSMutableArray alloc] init];
    return _loc;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setLocations:(NSArray *)locations
{
    NSSortDescriptor *country = [NSSortDescriptor sortDescriptorWithKey:@"Country" ascending:YES];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_WOE_NAME ascending:YES];
    NSSortDescriptor *count = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_PHOTO_COUNT ascending:NO];
    NSArray *descriptors = @[country, sort, count];

    _locations=[locations sortedArrayUsingDescriptors:descriptors];
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self fetchPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Location Cell" forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *location = self.locations[indexPath.row];
    
    cell.textLabel.text=[location valueForKeyPath:FLICKR_PLACE_WOE_NAME];
    cell.detailTextLabel.text =[location valueForKeyPath:@"Country"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    // deal with ipad split controller
    if([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    if([detail isKindOfClass:[ccImageViewController class]]) {
        [self prepareImageViewController:detail toDisplayPhoto:self.locations[indexPath.row]];
    }
}

- (void) prepareImageViewController:(ccImageViewController *)ivc toDisplayPhoto:(NSDictionary *)location
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:location format:FlickrPhotoFormatLarge];
    ivc.title = [location valueForKeyPath:FLICKR_PHOTO_TITLE];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if([segue.identifier isEqualToString:@"LocationSegue"]) {
                if([segue.destinationViewController isKindOfClass:[snapJustPostedFlickrPhotosTVCViewController class]]) {
                    NSDictionary *location = self.locations[indexPath.row];
                    [segue.destinationViewController setLocation_id:[location valueForKeyPath:FLICKR_PLACE_ID] ];
                }
            }
        }
    }
}


@end
