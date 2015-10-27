//
//  ProductViewController.h
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductViewController : UITableViewController

@property (nonatomic, retain) NSArray *products;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSArray *URLs;

@end
