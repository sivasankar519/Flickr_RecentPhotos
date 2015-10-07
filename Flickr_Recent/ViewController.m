//
//  ViewController.m
//  Flickr_Recent
//
//  Created by SIVASANKAR DEVABATHINI on 10/3/15.
//  Copyright (c) 2015 SIVASANKAR DEVABATHINI. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"


static NSString * const API_KEY = @"d515b0f9f2c88d498153db3c68649bbe";

static NSString * const recentPhotosURL = @"https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&&api_key=%@&format=json&nojsoncallback=1";
//&per_page=2,,, &page optional parmeters

@interface ViewController (){
    NSArray *recentPhotos;
    NSMutableArray *urlsArray;
    int photoIndex;
    MBProgressHUD *HUD;
   
}
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *picTitle;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForNetwork) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    [self checkForNetwork];
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swipeRight =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)checkForNetwork
{
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    if(myStatus == NotReachable) {
        self.reachable = NO;
        [self.statusButton setImage:[UIImage imageNamed:@"nowifi"] forState:UIControlStateNormal];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection error" message:@"Please check your internet connetion Settings!" delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        self.reachable = YES;
        [self.statusButton setImage:[UIImage imageNamed:@"wifi"] forState:UIControlStateNormal];
        if (!recentPhotos) {[self getRecentPhotos];};
    }
  
}
-(void)getRecentPhotos{
    
    HUD = [[MBProgressHUD alloc]init];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading";
    [HUD show:YES];
    
    photoIndex = 0;
    
    NSString *urlString = [NSString stringWithFormat:recentPhotosURL, API_KEY];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlString]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                recentPhotos =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil][@"photos"][@"photo"];
                
                urlsArray = [[NSMutableArray alloc]init];
                for (int index = 0; index < recentPhotos.count ; index++){
                    [urlsArray addObject:[self generatePhotoURL:recentPhotos[index]]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imgView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:urlsArray[photoIndex]]]];
                    
                    self.picTitle.text = recentPhotos[photoIndex][@"title"];
                    HUD.hidden = YES;
                });
            }]
     resume];
}

-(NSURL*)generatePhotoURL:(NSDictionary*)photoDict{
    
    //https://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
    
    static NSString *baseStr = @"static.flickr.com/";
    
    NSMutableString *URLString = [NSMutableString stringWithString:@"https://"];
    [URLString appendFormat:@"farm%@.",photoDict[@"farm"]];
    

    [URLString appendString:baseStr];
    [URLString appendFormat:@"%@/%@_%@.jpg",photoDict[@"server"],photoDict[@"id"],photoDict[@"secret"]];
    
    return [NSURL URLWithString:URLString];
    
    
}

-(void)swipeLeft:(UIGestureRecognizer*)gesture{
    
    if(photoIndex+1 >= urlsArray.count) return;
    if([self reachable]){
        photoIndex++;
        [UIView transitionWithView:self.imgView duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                               self.imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlsArray[photoIndex]]];
                               self.picTitle.text = recentPhotos[photoIndex][@"title"];
                           } completion:nil];
        
        
    }
}

-(void)swipeRight:(UIGestureRecognizer*)gesture{
    
    if(!photoIndex) return;
    if([self reachable]){
        photoIndex--;
        [UIView transitionWithView:self.imgView duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                               self.imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:urlsArray[photoIndex]]];
                               self.picTitle.text = recentPhotos[photoIndex][@"title"];
                           } completion:nil];
       
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
