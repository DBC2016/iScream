//
//  DetailViewController.m
//  iScream
//
//  Created by Demond Childers on 4/18/16.
//  Copyright © 2016 VizNetwork. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (nonatomic,weak) IBOutlet UILabel *flavorNameLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _flavorNameLabel.text = _flavorNameString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
