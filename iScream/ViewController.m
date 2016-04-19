//
//  ViewController.m
//  iScream
//
//  Created by Thomas Crawford on 6/7/15.
//  Copyright (c) 2015 VizNetwork. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Flavors.h"
#import "InventoryItems.h"
#import "DetailViewController.h"

@interface ViewController ()

@property (nonatomic, strong) AppDelegate            *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray                *flavorsArray;
@property (nonatomic, strong) IBOutlet UITableView   *flavorsTableView;

@end

@implementation ViewController

#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _flavorsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *iCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Flavors *currentFlavor = _flavorsArray[indexPath.row];
    iCell.imageView.image = [UIImage imageNamed:currentFlavor.flavorImage];
    iCell.textLabel.text = [currentFlavor flavorName];
    iCell.detailTextLabel.text = [NSString stringWithFormat:@"Gallons %0.2f",[self totalInventoryForFlavor:currentFlavor]];
    return iCell;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *destController = [segue destinationViewController];
    NSIndexPath *indexPath = [_flavorsTableView indexPathForSelectedRow];
    destController.flavorNameString = [_flavorsArray[indexPath.row] flavorName];
}

#pragma mark - Core Methods

- (NSArray *)fetchFlavors {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Flavors" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"flavorName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *fetchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Fetched %lu Flavors",(unsigned long)[fetchResults count]);

    return [NSMutableArray arrayWithArray:fetchResults];
}

- (float)totalInventoryForFlavor:(Flavors *)flavor {
    float totalInGallons = 0.0;
    NSArray *flavorInventoryArray = [[flavor relationshipFlavorInventoryItems] allObjects];
    for (InventoryItems *inventoryItem in flavorInventoryArray) {
        totalInGallons = totalInGallons + [[inventoryItem sizeInGallons] floatValue];
    }
    return totalInGallons;
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = _appDelegate.managedObjectContext;
    _flavorsArray = [self fetchFlavors];
    for (Flavors *flavor in _flavorsArray) {
        NSLog(@"Flavor: %@ Gallons: %.2f",[flavor flavorName],[self totalInventoryForFlavor:flavor]);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
