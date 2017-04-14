//
//  ViewController.h
//  Assessment
//
//  Created by Vamshi krishna Padala on 4/12/17.
//  Copyright © 2017 Vamshi krishna Padala. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,strong) NSMutableArray *results;
@end

