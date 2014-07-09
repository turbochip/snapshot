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
//@property (nonatomic,strong) NSMutableArray *country;
@property (nonatomic,strong) NSMutableDictionary *tableDictionary;

@end

@implementation snapLocationTVC

- (NSMutableDictionary *) tableDictionary
{
    if(!_tableDictionary) _tableDictionary=[[NSMutableDictionary alloc] init];
    return _tableDictionary;
}


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
        });
    });
}

//- (void) addCountry: (NSString *) ctry
//{
//    if([self.country indexOfObject:ctry]==NSNotFound) {
//        [self.country addObject:ctry];
//    }
//}

// Build an array of contries
//- (NSMutableArray *) country
//{
//    if(!_country) _country=[[NSMutableArray alloc] init];
//    return _country;
//}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *) flickrCountryFromDictionary:(NSDictionary *) d
{
    return [[[d valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@","] lastObject];
}

- (void) setLocations:(NSArray *)locations
{
    NSMutableArray *loc=[[NSMutableArray alloc] init];
    NSSortDescriptor *country = [NSSortDescriptor sortDescriptorWithKey:@"Country" ascending:YES];
    NSSortDescriptor *place = [NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_WOE_NAME ascending:YES];
    NSArray *descriptors = @[place,country];
    
    // add country as a key in the flickr dictionary
    for(int i=0;i<[locations count]; i++) {
        NSMutableDictionary *d=[[locations objectAtIndex:i] mutableCopy];
        [d setValue:[self flickrCountryFromDictionary:d] forKeyPath:@"Country"];
        //build a new array holding new dictionaries
        [loc addObject:d];
    }
    //replace locations with the array we just created.
    _locations=[loc sortedArrayUsingDescriptors:descriptors];
    
    loc=nil;
    loc=[[NSMutableArray alloc] init];

    
    for(NSMutableDictionary *fa in _locations){   // loop through flickr array
        NSString *countryName=[fa objectForKey:@"Country"];  // get the animal type for each creature as we go through
        if([self.tableDictionary objectForKey:countryName]) {  // if there is an key that matches that animal type
            [[self.tableDictionary objectForKey:countryName] addObject:fa];  // add an object to that array
        } else {   // the key for the type of animal doesn't exist
            self.tableDictionary[countryName]=[[NSMutableArray alloc] init];  // initialize it as an array
            [[self.tableDictionary objectForKey:countryName] addObject:fa];   // add the object to the array
        }
    }
    

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
    return [self.tableDictionary count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // allKeys returns an array of the keys in the dictionary
    // get the array and go to the index based on section and get the string value for it
    NSString *key=[[self.tableDictionary allKeys] objectAtIndex:section];
    // now use that string to get the value for that key and count
    NSInteger rows=[[self.tableDictionary valueForKey:key ] count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Location Cell" forIndexPath:indexPath];
    // Configure the cell...
//    NSDictionary *location = self.locations[indexPath.row];
    // get the key for the section
    NSString *key=[[self.tableDictionary allKeys] objectAtIndex:indexPath.section];
    // now get the array associated with that key
    NSMutableArray *keyDict=[self.tableDictionary valueForKey:key];
    NSMutableDictionary *location=[keyDict objectAtIndex:indexPath.row];
    cell.textLabel.text=[location valueForKeyPath:FLICKR_PLACE_WOE_NAME];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key=[[self.tableDictionary allKeys] objectAtIndex:section];
    [tableView headerViewForSection:section].backgroundColor=[UIColor blueColor];
    return key;
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
