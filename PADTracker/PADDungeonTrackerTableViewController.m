//
//  PADDungeonTrackerTableViewController.m
//  PADTracker
//
//  Created by Carl Lam on 2014-08-09.
//
//

#import "PADDungeonTrackerTableViewController.h"
#import "PADGroupSettingsViewController.h"
#import "PADDungeonDetailsViewController.h"
#import "PADDungeonEvent.h"
#import "TFHpple.h"
#import "SBJSON.h"

@interface PADDungeonTrackerTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *detail;
- (IBAction)clockButton:(UIButton *)sender;

@property NSMutableArray *dungeonEvents;
@property PADDungeonEvent *eventToSend;
@property NSString *utcDifference;
@property NSDictionary *dungeonGroups;
@property BOOL refreshing;
@property NSDate *selectedDate;
@property PADDungeonEvent *datePickerDungeon;
@property int alertOffset;
@property int beforeOrAfter;


@end

@implementation PADDungeonTrackerTableViewController

-(IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.starter = [userDefaults integerForKey:@"key1"];
    self.group = [userDefaults integerForKey:@"key2"];
    self.utcDifference = [userDefaults objectForKey:@"key3"];
    
    [self updateDungeons];
    [self.tableView reloadData];
    
}

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Fetching new data");
    [self updateDungeons];
    [self.tableView reloadData];
    completionHandler(UIBackgroundFetchResultNewData);
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.starter = [userDefaults integerForKey:@"key1"];
    self.group = [userDefaults integerForKey:@"key2"];
    self.utcDifference = [userDefaults objectForKey:@"key3"];
    self.dungeonEvents = [[NSMutableArray alloc] init];
    self.refreshing = false;

    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshDungeons) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self updateDungeons];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)refreshDungeons {
    self.refreshing = true;
    [self updateDungeons];
}

- (void)updateDungeons {
    //Create the request
    
    //url for adrian's server:http://creatifcubed.com:8081/metal_dungeons
    
//    NSString *urlString = [NSString stringWithFormat:@"http://puzzledragonx.com/?utc=%@",self.utcDifference];
    NSString *urlString = [NSString stringWithFormat:@"http://creatifcubed.com:8081/metal_dungeons"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                          URLWithString:[NSString stringWithFormat:@"%@",urlString]]];
    
    //Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    conn = nil;
}

- (void)loadInitialData {
    PADDungeonEvent *dungeon1 = [[PADDungeonEvent alloc] init];
    dungeon1.dungeonName = @"Alert! Metal Dragons";
    dungeon1.dungeonTime = @"4 pm";
    [self.dungeonEvents addObject:dungeon1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //The request is complete and data has been received
    //You can parse the stuff in your instance variable now
    
    //grab the array holding their specific group's dungeon info
    NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSDictionary *responseDict = [responseString JSONValue];
    NSDictionary *dungeonsDict = [responseDict objectForKey:@"dungeons"];
    
    static NSString* dates[] = { @"today", @"tomorrow" };
    static NSString* foo[] = { @"a", @"b", @"c", @"d", @"e" };
    
    NSMutableArray *newDungeonEvents = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [dungeonsDict count]; i++){
        NSDictionary *datesDict = [dungeonsDict objectForKey:dates[i]];
        NSArray *groupDungeons = [datesDict objectForKey:foo[self.group]];
    
    
        NSMutableArray *newDungeonSection = [[NSMutableArray alloc] initWithCapacity:0];
    
        for(NSMutableDictionary *event in groupDungeons){
            PADDungeonEvent *dungeonEvent = [[PADDungeonEvent alloc] init];
            
            if ([[event objectForKey:@"time"] class] != [NSNull class]){
                //takes the unix time and converts it to a date object
                NSNumber *unixTime = [event objectForKey:@"time"];
                int64_t time = [unixTime longLongValue];
                dungeonEvent.dungeonDate = [NSDate dateWithTimeIntervalSince1970:time];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                dungeonEvent.dungeonTime = [dateFormatter stringFromDate:dungeonEvent.dungeonDate];
            } else{
                dungeonEvent.dungeonTime = @"--";
            }

        
            dungeonEvent.dungeonLink = [event objectForKey:@"link"];
            dungeonEvent.dungeonImageURL = [event objectForKey:@"image"];
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: dungeonEvent.dungeonImageURL]];
            dungeonEvent.dungeonImage = [UIImage imageWithData: imageData];

            dungeonEvent.dungeonName = [event objectForKey:@"name"];

        
            dungeonEvent.clockClicked = NO;
            dungeonEvent.clockImage = [UIImage imageNamed:@"clock34.png"];
            [newDungeonSection addObject:dungeonEvent];

        
        }
        [newDungeonEvents addObject:newDungeonSection];
    }
    self.dungeonEvents = newDungeonEvents;
    [self.tableView reloadData];
    
    if (self.refreshing){
        [self.refreshControl endRefreshing];
        self.refreshing = false;
    }
    
    
    
    
    

//    TFHpple *dungeonParser = [TFHpple hppleWithHTMLData:_responseData];
//    
//    NSString *dungeonTodayXpathQueryString = @"//div[@id='metal1a']/span/table";
//    NSArray *dungeonNodes = [dungeonParser searchWithXPathQuery:dungeonTodayXpathQueryString];
//    NSArray *dungeonTodayNodes = [[dungeonNodes firstObject] children];
//
//    NSLog(@"today");
//    NSMutableArray *newDungeonEvents = [[NSMutableArray alloc] initWithCapacity:0];
//    NSMutableArray *newDungeonSection = [[NSMutableArray alloc] initWithCapacity:0];
//    NSUInteger i = 0;
//    NSUInteger j = 1;
//    for (i = 0; i < ([dungeonTodayNodes count] - 1) / 2; i++) {
//        PADDungeonEvent *dungeonEvent = [[PADDungeonEvent alloc] init];
//        TFHppleElement *element = [dungeonTodayNodes objectAtIndex:j];
//        TFHppleElement *elementChild = [element firstChildWithClassName:@"monstericon2"];
//                                        
//        if ([elementChild hasChildren]){
//            PADDungeonEvent *dungeonEvent2 = [[PADDungeonEvent alloc] init];
//            
//            TFHppleElement *elementChild2 = [[element firstChildWithClassName:@"monstericon1"] firstChild];
//            TFHppleElement *elementChild1 = [elementChild firstChild];
//            
//            dungeonEvent.dungeonLink = [elementChild1 objectForKey:@"href"];
//            dungeonEvent2.dungeonLink = [elementChild2 objectForKey:@"href"];
//            
//            NSString *dungeonNameLink1XpathQueryString =
//            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent.dungeonLink];
//            NSString *dungeonNameLink2XpathQueryString =
//            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent2.dungeonLink];
//            
//            TFHppleElement *elementChild1Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink1XpathQueryString] lastObject];
//            TFHppleElement *elementChild2Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink2XpathQueryString] lastObject];
//            
//            dungeonEvent.dungeonName = [[[elementChild1Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            dungeonEvent2.dungeonName = [[[elementChild2Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            
//            j++;
//            TFHppleElement *timeElement = [[[dungeonTodayNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
//            NSMutableString *time = [[[timeElement firstChild] content] mutableCopy];
//            if ([time length] <= 5 && [time length] > 2) {
//                [time insertString:@":00" atIndex:([time length] -3)];
//            }
//            dungeonEvent.dungeonTime = time;
//            dungeonEvent2.dungeonTime = time;
//            j++;
//            
//            dungeonEvent2.clockClicked = NO;
//            dungeonEvent2.clockImage = [UIImage imageNamed:@"clock34.png"];
//            
//            [newDungeonSection addObject:dungeonEvent2];
//
//            
//        } else {
//            TFHppleElement *elementChild0 = [[element firstChildWithClassName:@"monstericon0"] firstChild];
//            NSString *dungeonNameLink0XpathQueryString =
//            [NSString stringWithFormat:@"//a[@href='%@']", [elementChild0 objectForKey:@"href"]];
//            TFHppleElement *elementChild0Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink0XpathQueryString] lastObject];
//            dungeonEvent.dungeonName = [[[elementChild0Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            j++;
//            TFHppleElement *timeElement = [[[dungeonTodayNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
//            NSMutableString *time = [[[timeElement firstChild] content] mutableCopy];
//            if ([time length] <= 5 && [time length] > 2) {
//                [time insertString:@":00" atIndex:([time length] -3)];
//            }
//            dungeonEvent.dungeonTime = time;
//            j++;
//        }
//        
//        dungeonEvent.clockClicked = NO;
//        dungeonEvent.clockImage = [UIImage imageNamed:@"clock34.png"];
//        [newDungeonSection addObject:dungeonEvent];
//        
//    }
//    [newDungeonEvents addObject:newDungeonSection];
//    
//    NSLog(@"tomorrow");
//    NSString *dungeonTomorrowXpathQueryString = @"//div[@id='metal1b']/span/table";
//    NSArray *dungeonNodes2 = [dungeonParser searchWithXPathQuery:dungeonTomorrowXpathQueryString];
//    NSArray *dungeonTomorrowNodes = [[dungeonNodes2 firstObject] children];
//    
//    
//    NSMutableArray *newDungeonSection2 = [[NSMutableArray alloc] initWithCapacity:0];
//    i = 0;
//    j = 1;
//    
//    
//    for (i = 0; i < ([dungeonTomorrowNodes count] - 1) / 2; i++) {
//        PADDungeonEvent *dungeonEvent = [[PADDungeonEvent alloc] init];
//        TFHppleElement *element = [dungeonTomorrowNodes objectAtIndex:j];
//        TFHppleElement *elementChild = [element firstChildWithClassName:@"monstericon2"];
//        
//        if ([elementChild hasChildren]){
//            PADDungeonEvent *dungeonEvent2 = [[PADDungeonEvent alloc] init];
//            
//            TFHppleElement *elementChild2 = [[element firstChildWithClassName:@"monstericon1"] firstChild];
//            TFHppleElement *elementChild1 = [elementChild firstChild];
//            
//            dungeonEvent.dungeonLink = [elementChild1 objectForKey:@"href"];
//            dungeonEvent2.dungeonLink = [elementChild2 objectForKey:@"href"];
//            
//            NSString *dungeonNameLink1XpathQueryString =
//            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent.dungeonLink];
//            NSString *dungeonNameLink2XpathQueryString =
//            [NSString stringWithFormat:@"//a[@href='%@']", dungeonEvent2.dungeonLink];
//            
//            TFHppleElement *elementChild1Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink1XpathQueryString] lastObject];
//            TFHppleElement *elementChild2Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink2XpathQueryString] lastObject];
//            
//            dungeonEvent.dungeonName = [[[elementChild1Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            dungeonEvent2.dungeonName = [[[elementChild2Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            
//            j++;
//            TFHppleElement *timeElement = [[[dungeonTomorrowNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
//            NSMutableString *time = [[[timeElement firstChild] content] mutableCopy];
//            if ([time length] <= 5 && [time length] > 2) {
//                [time insertString:@":00" atIndex:([time length] -3)];
//            }
//            dungeonEvent.dungeonTime = time;
//            dungeonEvent2.dungeonTime = time;
//            j++;
//            
//            [newDungeonSection2 addObject:dungeonEvent2];
//
//            
//        } else {
//            TFHppleElement *elementChild0 = [[element firstChildWithClassName:@"monstericon0"] firstChild];
//            NSString *dungeonNameLink0XpathQueryString =
//            [NSString stringWithFormat:@"//a[@href='%@']", [elementChild0 objectForKey:@"href"]];
//            TFHppleElement *elementChild0Name = [[dungeonParser searchWithXPathQuery:dungeonNameLink0XpathQueryString] lastObject];
//            dungeonEvent.dungeonName = [[[elementChild0Name firstChild] content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            j++;
//            TFHppleElement *timeElement = [[[dungeonTomorrowNodes objectAtIndex:j] childrenWithClassName:@"metaltime"] objectAtIndex:(self.group)];
//            NSMutableString *time = [[[timeElement firstChild] content] mutableCopy];
//            if ([time length] <= 5 && [time length] > 2) {
//                [time insertString:@":00" atIndex:([time length] -3)];
//            }
//            dungeonEvent.dungeonTime = time;
//            
//            
//            j++;
//        }
//        
//        [newDungeonSection2 addObject:dungeonEvent];
//        
//    }
//    [newDungeonEvents addObject:newDungeonSection2];
//   
//    
//    self.dungeonEvents = newDungeonEvents;
//
//    [self.tableView reloadData];
    
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //Request failed for some reason!
    //Check the error var
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dungeonEvents count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [[self.dungeonEvents objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DungeonEventsCell" forIndexPath:indexPath];
    
    UILabel *label;
    
    // Configure the cell...
    
    NSArray *dungeonSection = [self.dungeonEvents objectAtIndex:indexPath.section];
    PADDungeonEvent *dungeonEvent = [dungeonSection objectAtIndex:indexPath.row];
    
    

        UIButton *clockButton = (UIButton *)[cell viewWithTag:1];
    
    if (indexPath.section == 0){
        [clockButton setTitle:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forState:UIControlStateNormal];
        [clockButton setImage:dungeonEvent.clockImage forState:UIControlStateNormal];
    
    } else{
        [clockButton setTitle:@" " forState:UIControlStateNormal];
    }
    
    label = (UILabel *)[cell viewWithTag:100];
    label.text = dungeonEvent.dungeonTime;
    
    label = (UILabel *)[cell viewWithTag:200];
    label.text = dungeonEvent.dungeonName;
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Tomorrow's Metal Dungeon Schedule";
    }
    return @"Today's Metal Dungeon Schedule";
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        self.eventToSend = [[self.dungeonEvents objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"detailSegue" sender:self.eventToSend];
        

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"detailSegue"]){
        PADDungeonDetailsViewController *vc = [segue destinationViewController];
        
        [vc setDungeonEvent:self.eventToSend];
        

        
        
    }
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return 8;
            break;
            
        case 1:
            return 2;
            break;

        default:
            break;

    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    static NSString *titles[] = {@"0 mins", @"5 mins", @"10 mins", @"20 mins", @"30 mins", @"40 mins", @"50 mins", @"60 mins"};
    static NSString *options[] = {@"before", @"after"};
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        tView.textAlignment = NSTextAlignmentCenter;
        tView.adjustsFontSizeToFitWidth = YES;

    }
    if(component == 0){
        tView.text = titles[row];

    }else {
        tView.text = options[row];
    }
    return tView;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;{
    if(component == 0){
        return 90;
    } else{
        return 90;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        static int offsets[] = {0, 300, 600, 1200, 1800, 2400, 3000, 3600};
        self.alertOffset = offsets[row];
        
    } else {
        if (row == 0) {
            self.beforeOrAfter = -1;
        } else {
            self.beforeOrAfter = 1;
        }
    }
    
}

- (void)changeDate:(UIDatePicker *)sender {
    NSLog(@"New Date: %@", sender.date);
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
    [[self.view viewWithTag:12] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(120, self.view.bounds.size.height+44, 200, 216);
    CGRect labelTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 120, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [self.view viewWithTag:12].frame = labelTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

-(void)setAlarm:(id)sender{
    NSDate *currentDate = [NSDate date];
    
    NSDate *alarmDate = [self.datePickerDungeon.dungeonDate dateByAddingTimeInterval:(self.alertOffset * self.beforeOrAfter)];
    if ([alarmDate compare:currentDate] == NSOrderedDescending) {
        //alarm date is later than current date so set the alarm
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = alarmDate;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        // Notification details
        if ((self.alertOffset == 3600) && (self.beforeOrAfter == 1)) {
            localNotif.alertBody = [NSString stringWithFormat:@"Your %@ has just ended!", self.datePickerDungeon.dungeonName];
            
        } else if (self.alertOffset == 0){
            localNotif.alertBody = [NSString stringWithFormat:@"Your %@ has started!", self.datePickerDungeon.dungeonName];
            
        } else if (self.beforeOrAfter > 0){
            localNotif.alertBody = [NSString stringWithFormat:@"Your %@ ends in %d mins!", self.datePickerDungeon.dungeonName, (3600-self.alertOffset)/60 ];
        } else {
            localNotif.alertBody = [NSString stringWithFormat:@"Your %@ starts in %d mins!", self.datePickerDungeon.dungeonName, self.alertOffset/60];
        }
        // Set the action button
        localNotif.alertAction = @"View";
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        
        // Specify custom data for the notification
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
        localNotif.userInfo = infoDict;
        
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        
        self.datePickerDungeon.alarmDate = alarmDate;
        self.datePickerDungeon.alarmNotification = localNotif;
        self.datePickerDungeon.clockImage = [UIImage imageNamed:@"clock37.png"];
        self.datePickerDungeon.clockClicked = YES;
        [self.tableView reloadData];
            [self performSelector:@selector(dismissDatePicker:) withObject:sender];
        
    } else{
        //date has already passed or it's currently that time
        NSString *message = @"Sorry, time not valid";
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil, nil];
        [toast show];
        
        int duration = 1; // duration in seconds
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
    

    
}



- (IBAction)clockButton:(UIButton *)sender {
    
    if (![sender.currentTitle isEqualToString:@" "]){
    
        NSUInteger number = [sender.currentTitle integerValue];
        NSArray *dungeonSection = [self.dungeonEvents objectAtIndex:0];
        self.datePickerDungeon = [dungeonSection objectAtIndex:number];
        if (self.datePickerDungeon.clockClicked == NO) {
            //setting a datepicker to popup
            if ([self.view viewWithTag:9]) {
                return;
            }

            //These are the target frames for the animation (after position)
            CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-252-44, 320, 44);
            CGRect datePickerTargetFrame = CGRectMake(120, self.view.bounds.size.height-252-16, 200, 216);
            CGRect labelTargetFrame = CGRectMake(0, self.view.bounds.size.height-252-16, 120, 216);
            
            //Make the background darker
            UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
            darkView.alpha = 1;
            darkView.backgroundColor = [UIColor blackColor];
            darkView.tag = 9;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
            [darkView addGestureRecognizer:tapGesture];
            [self.view addSubview:darkView];
            
            //Setup pickerview to choose alarm time
            UIPickerView *alarmPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(120, self.view.bounds.size.height+44, 200, 252)];
            alarmPicker.tag = 10;
            alarmPicker.delegate = self;
            alarmPicker.showsSelectionIndicator = YES;
            [self.view addSubview:alarmPicker];
            
            //Setup label before the pickerView
            UILabel *alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44,  120, 216)];
            alarmLabel.tag = 12;
            alarmLabel.backgroundColor = [UIColor whiteColor];
            alarmLabel.text = @"Alert me";
            alarmLabel.textAlignment = NSTextAlignmentCenter;
            alarmLabel.adjustsFontSizeToFitWidth = YES;
            [self.view addSubview:alarmLabel];

            //Setup toolBar for the alarmSetting
            UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
            toolBar.tag = 11;
            toolBar.barStyle = UIBarStyleDefault;
            
            UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissDatePicker:)];
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(setAlarm:)];
            
            [toolBar setItems:[NSArray arrayWithObjects:cancelButton, spacer, doneButton, nil]];
            [self.view addSubview:toolBar];
            
            
            [UIView beginAnimations:@"MoveIn" context:nil];
            toolBar.frame = toolbarTargetFrame;
            alarmPicker.frame = datePickerTargetFrame;
            alarmLabel.frame = labelTargetFrame;
            [alarmPicker setBackgroundColor:[UIColor whiteColor]];
            darkView.alpha = 0.5;
            [UIView commitAnimations];
           
            
            
        } else {
            self.datePickerDungeon.clockImage = [UIImage imageNamed:@"clock34.png"];
            self.datePickerDungeon.clockClicked = NO;
            [[UIApplication sharedApplication] cancelLocalNotification:self.datePickerDungeon.alarmNotification];
        }
    [self.tableView reloadData];
    }
    
}
@end
