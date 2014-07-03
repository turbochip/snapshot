//
//  snapHistoryTVC.m
//  snapshot
//
//  Created by Chip Cox on 7/2/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import "snapHistoryTVC.h"
#import "FlickrFetcher.h"
#import "ccImageViewController.h"

@interface snapHistoryTVC ()
@property (nonatomic,strong) NSUserDefaults *usrDef;
@end

@implementation snapHistoryTVC
@synthesize historyArray=_historyArray;

-(NSMutableArray *) historyArray
{
    if(!_historyArray) _historyArray=[[NSMutableArray alloc] init];
    return _historyArray;
}

- (void) setHistoryArray:(NSMutableArray *)historyArray
{
    _historyArray=historyArray;
    [self.tableView reloadData];
}

-(NSUserDefaults *) usrDef
{
    if(!_usrDef) _usrDef=[[NSUserDefaults alloc] init];
    return _usrDef;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setHistoryArray:[[self.usrDef arrayForKey:@"LastViewed"] mutableCopy]];
    for (int i=0;i<self.historyArray.count;i++)
    {
        NSLog(@"historyArray[%d]=%@",i,self.historyArray[i]);
    }
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.historyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *photo = self.historyArray[indexPath.row];
    cell.textLabel.text=[photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    return cell;
}


#pragma mark - Navigation
- (void) prepareImageViewController:(ccImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:sender];
        if (indexPath) {
            if([segue.identifier isEqualToString:@"DisplayPhotoHistory"]) {
                if([segue.destinationViewController isKindOfClass:[ccImageViewController class]]) {
                    [self prepareImageViewController:segue.destinationViewController
                                      toDisplayPhoto:self.historyArray[indexPath.row]];
                }
            }
        }
    }
}


@end