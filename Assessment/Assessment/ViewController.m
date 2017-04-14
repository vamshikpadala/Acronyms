//
//  ViewController.m
//  Assessment
//
//  Created by Vamshi krishna Padala on 4/12/17.
//  Copyright © 2017 Vamshi krishna Padala. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "ResponseTableViewCell.h"
#import "AcronymTableViewCell.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.title = @"ACRONYMS FINDER";
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

    self.results = [[NSMutableArray alloc] init];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (![textField.text isEqualToString:@""]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *request = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@",textField.text];

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        [manager GET:request parameters:nil progress: nil success:^(NSURLSessionTask *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            if ([responseObject count]==0) {
                NSLog(@"no objects");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    textField.text = @"";
                    [self showAlertWithTitle:@"Sorry!" andMessage:@"We couldn't find the abbreviation for this acronym"];
                });
                
            }else{
                self.results = [[[responseObject objectAtIndex:0] objectForKey:@"lfs"] mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView reloadData];
                });
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                textField.text = @"";
                [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
                
            });
        }];
    }
    
    
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
        [self.results removeAllObjects];
        [self.tableView reloadData];

    }
    return YES;
}

-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              self.results = [[NSMutableArray alloc] init];
                                                              [self.tableView reloadData];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *CellIdentifier = @"SearchHeader";
    AcronymTableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    headerView.searchTextField.delegate = self;
    UIView *wrapper = [[UIView alloc] initWithFrame:[headerView frame]];
    [wrapper addSubview:headerView];
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"The cell is nil"];
    }
    return wrapper;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return [self.results count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResponseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Result" forIndexPath:indexPath];
    cell.abbreviation.text = [[self.results objectAtIndex:indexPath.row] objectForKey:@"lf"];
    
    return cell;
}


@end
