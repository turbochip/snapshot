//
//  snapHistoryTVC.h
//  snapshot
//
//  Created by Chip Cox on 7/2/14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface snapHistoryTVC : UITableViewController
@property (nonatomic,strong) NSMutableArray* historyArray;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,strong) id location_id;
@end
