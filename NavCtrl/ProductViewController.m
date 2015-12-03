//
//  ProductViewController.m
//  NavCtrl
//
//  Created by Aditya Narayan on 10/22/13.
//  Copyright (c) 2013 Aditya Narayan. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductDetailViewController.h"
#import "NewProductViewController.h"
#import "Company.h"
#import "Product.h"
#import "NavCtrlDAO.h"

@interface ProductViewController ()

@property (nonatomic, retain) ProductDetailViewController *detailViewController;
@property (nonatomic, retain) NewProductViewController *addUpdateProductViewController;
@property (nonatomic, retain) UINavigationController *addUpdateViewNavController;

@end

@implementation ProductViewController

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
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *addProductButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAddButton:)];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItems = @[addProductButtonItem, self.editButtonItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NavCtrlDAO sharedInstance] loadProductsForCompany:self.title completionBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *) configureCell: (UITableViewCell *)cell
                          ForObject: (id)object
                            AtIndex: (NSUInteger)index {
    
    Product *product = (Product *)object;
    
    cell.textLabel.text = product.name;
    
    
    UIImage *image = [UIImage imageNamed:product.company.icon];
    if (!image) {
        image = [UIImage imageNamed:@"Sunflower.gif"];
    }
    [[cell imageView] setImage:image];
    
    // Show disclosure and detail acssory buttons
    // Only show disclosure if URL present
    if (product.url && product.url.length > 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell setEditingAccessoryType:UITableViewCellAccessoryDetailButton];
    
    return cell;
}

- (void) openViewForSelectedObject: (id)object  {
    Product *product = (Product *)object;
    
    if (!self.detailViewController) {
        _detailViewController = [[ProductDetailViewController alloc] init];
    }
    self.detailViewController.title = product.name;
    self.detailViewController.URL = product.url;
    
    // Push the view controller.
    // Only allow navigation to detail view when URL present
    if (product.url && product.url.length > 0) {
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[[NavCtrlDAO sharedInstance] getProductsByCompany:self.title] count];
}

- (UITableViewCell *) tableView:(UITableView *) tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    Product *product = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.row forCompanyName:self.title];
    
    return [self configureCell:cell ForObject:product AtIndex:indexPath.row];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[NavCtrlDAO sharedInstance] removeProductAtIndex:indexPath.row forCompanyName:self.title];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)  tableView: (UITableView *)tableView
 moveRowAtIndexPath: (NSIndexPath *)fromIndexPath
        toIndexPath: (NSIndexPath *)toIndexPath {
    
    if (fromIndexPath.row == toIndexPath.row) return;
    
    [[NavCtrlDAO sharedInstance] moveProductFromIndex:fromIndexPath.row
                                              toIndex:toIndexPath.row
                                       forCompanyName:self.title];
    
    /*
    NSDictionary *product = [[self.products objectAtIndex:[fromIndexPath row]] retain];
    [self.products removeObjectAtIndex:[fromIndexPath row]];
    [self.products insertObject:product atIndex:[toIndexPath row]];
    [product release];
     */
}


// Override to support conditional rearranging of the table view.
- (BOOL) tableView: (UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.

    // Pass the selected object to the new view controller.
    id object = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.row forCompanyName:self.title];
    [self openViewForSelectedObject:object];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self createAddUpdateProductViewController];
    
    Product *product = [[NavCtrlDAO sharedInstance] getProductAtIndex:indexPath.row forCompanyName:self.title];
    
    self.addUpdateProductViewController.product = product;
    
    [self showDetailViewController:self.addUpdateProductViewController.navigationController sender:self];
}

- (void) handleAddButton:(UIBarButtonItem *)sender {
    [self createAddUpdateProductViewController];
    
    Product *product = [[NavCtrlDAO sharedInstance] newProductForCompany:self.company];
    product.company = self.company;
    
    self.addUpdateProductViewController.product = product;
    
    [self showDetailViewController:self.addUpdateProductViewController.navigationController sender:self];
}

- (void) createAddUpdateProductViewController {
    if (!self.addUpdateProductViewController) {
        _addUpdateProductViewController = [[NewProductViewController alloc] initWithNibName:@"NewProductViewController" bundle:nil];
        
        _addUpdateViewNavController = [[UINavigationController alloc] initWithRootViewController:self.addUpdateProductViewController];
        
        [self.addUpdateViewNavController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
}

- (void) addProduct:(Product *)product {
    [[NavCtrlDAO sharedInstance] addProduct: product
                             forCompanyName: self.title
                            completionBlock: ^{ [self.tableView reloadData]; }];
}

- (void) updateProduct:(Product *)product {
    [[NavCtrlDAO sharedInstance] updateProduct:product
                                forCompanyName:self.title
                               completionBlock:^{ [self.tableView reloadData]; }];
}

- (void) dealloc {
    [_detailViewController release];
    [_addUpdateProductViewController release];
    [_addUpdateViewNavController release];
    [_company release];
    [super dealloc];
}

@end
