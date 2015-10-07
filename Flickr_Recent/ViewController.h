//
//  ViewController.h
//  Flickr_Recent
//
//  Created by SIVASANKAR DEVABATHINI on 10/3/15.
//  Copyright (c) 2015 SIVASANKAR DEVABATHINI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic) Reachability *reachability;
@property (nonatomic) BOOL reachable;
@end

