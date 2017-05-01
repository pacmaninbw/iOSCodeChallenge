//
//  PCINetworkingDataModel.m
//  PCIDataModelLibrary

// If you decide to build and run this in the simulator please see this article on stackoverflow.com
// http://stackoverflow.com/questions/41273773/nw-host-stats-add-src-recv-too-small-received-24-expected-28
// the Xcode issue occurs in this code.
// You will also need the following in your Info.plist
//      <key>NSAppTransportSecurity</key>
//      <dict>
//          <key>NSAllowsArbitraryLoads</key>
//          <true/>
//      </dict>

/*  Provides an internet connection interface that retrieves the 15 minute delayed price of American Express.
 *  This model uses the Apple's NSURLSession Networking interfaces that are provided by the foundation and
 *  core foundation. 
 *
 *  Due to the nature of the data there is no reason to directly access sockets in the lower layers and Apple
 *  recommends using the highest interfaces possible. This app is written specifically for iOS devices such
 *  as the iPhone and iPad and doesn't need to be concerned with portability. The NSURLSession Networking
 *  interfaces are used because this only needs to access public data on the internet. The NSURLSession
 *  Networking interfaces provide the initial connection and reachabilty checking.
 *
 *  From https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/CommonPitfalls/CommonPitfalls.html#//apple_ref/doc/uid/TP40010220-CH4-SW1
 *      Sockets have many complexities that are handled for you by higher-level APIs. Thus, you will have
 *          to write more code, which usually means more bugs.
 *      In iOS, using sockets directly using POSIX functions or CFSocket does not automatically activate the
 *          device’s cellular modem or on-demand VPN.
 *      The most appropriate times to use sockets directly are when you are developing a cross-platform tool 
 *          or high-performance server software. In other circumstances, you typically should use a higher-level API.
 */

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "PCINetworkingDataModel.h"

// Private interface and private functions.
@interface PCINetworkingDataModel()

@property (nonatomic,strong) NSURLSessionDataTask *retrieveDataStockPriceTask;
@property (nonatomic,strong) NSURLSession *retrieveDataPriceSession;

- (NSURLSession *)createSession;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)stockPriceData;
- (void) setupAndStartdownloadStockPrice;
- (NSString*) ParseDownoadedFileForStockPrice;
- (void) createStockPriceFullFileSpec;
- (NSString*) retrieveStringFromDownloadedFileByUrl;

@end

@implementation PCINetworkingDataModel
// Instance variables
{
    NSString* googleFinanceUrl;
    NSString* stockPriceFilePath;
    NSString* stockPriceFileName;
    NSString* stockPriceFileFullFileSpec;
    NSString* downloadFailedErrorString;
    BOOL downloadHadErrors;
//    BOOL downloadCompleted;
}

//  Create a session using the main operation queue rather than an alternate, this allows synchronous programming
//  rather than asynchronous programming. The session is resumed in the calling function.
- (NSURLSession *)createSession
{
    static NSURLSession *session = nil;
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
            delegate:self
            delegateQueue:[NSOperationQueue mainQueue]];
    
    return session;
}

// Apple developer documentation indicates that this error handler should check reachability after a slight
// wait  (15 minutes) and then restart the download session. Since the original session start was based on
// a button click instead of checking reachability and then restarting the request the error will be reported
// and the task will quit.
// https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/WhyNetworkingIsHard/WhyNetworkingIsHard.html#//apple_ref/doc/uid/TP40010220-CH13-SW3
//  For requests made at the user’s behest:
//      Always attempt to make a connection. Do not attempt to guess whether network service is available, and do not cache that determination.
//      If a connection fails, use the SCNetworkReachability API to help diagnose the cause of the failure. Then:
//      If the connection failed because of a transient error, try making the connection again.
//      If the connection failed because the host is unreachable, wait for the SCNetworkReachability API to call your registered callback.
//          When the host becomes reachable again, your app should retry the connection attempt automatically without user intervention
//          (unless the user has taken some action to cancel the request, such as closing the browser window or clicking a cancel button).
//      Try to display connection status information in a non-modal way. However, if you must display an error dialog, be sure that it does
//          not interfere with your app’s ability to retry automatically when the remote host becomes reachable again. Dismiss the dialog
//          automatically when the host becomes reachable again.

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        downloadHadErrors = YES;
        NSString* errorString = [error localizedFailureReason];
        downloadFailedErrorString = [NSString stringWithFormat:@"An error occurred while downloading the stock price %@", errorString];
        NSLog(@"Data retrieval completed with error: %@\n", error);
        NSLog(@"Data retrieval completed with error: %@", errorString);
    }
    
    // The download failed, release any system resources used by the session, no need to finish any tasks here.
    [self.retrieveDataPriceSession invalidateAndCancel];
}

//  We got the stock price data from the web interface, save it to a file so that it can be processed later.
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)stockPriceData {
    NSError *writeError;
    
    if (stockPriceData) {
        NSString *stockPriceRequestReply = [[NSString alloc] initWithData:stockPriceData encoding:NSUTF8StringEncoding];
        downloadHadErrors = NO;
        
        NSString* urlOfstockPriceFileFullFileSpec = [NSString stringWithFormat:@"file://%@", stockPriceFileFullFileSpec];
        NSURL *downloadedDataInFile = [NSURL URLWithString:urlOfstockPriceFileFullFileSpec];
        
        if (![stockPriceRequestReply  writeToURL:downloadedDataInFile atomically:NO encoding:NSUTF8StringEncoding error: &writeError]) {
            NSString* errorString = [writeError localizedFailureReason];
            downloadFailedErrorString = [NSString stringWithFormat:@"An error occurred while writing file %@", writeError];
            downloadHadErrors = YES;
        }
    }
    else {
        NSString* errorString = [writeError localizedFailureReason];
        downloadFailedErrorString = [NSString stringWithFormat:@"An error occurred while receiving the data %@", writeError];
        downloadHadErrors = YES;
    }

    // Since the download seems to have completed, finish any unfinished business and then invalidate the session
    // to release any resources that need to be released.
    [self.retrieveDataPriceSession invalidateAndCancel];
    
}

// Set up a delegate based HTTP download and start the download
- (void) setupAndStartdownloadStockPrice {
    downloadHadErrors = NO;
    downloadFailedErrorString = nil;
    
    // Set up a NSURLSession to do an HTTP Download from the google finance
    self.retrieveDataPriceSession = [self createSession];
    NSURL *stockPriceURL = [NSURL URLWithString:googleFinanceUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:stockPriceURL];
    
    self.retrieveDataStockPriceTask = [self.retrieveDataPriceSession dataTaskWithRequest:request];
    [self.retrieveDataStockPriceTask resume];
    
}

/*
 * The data returned and stored in the file looks like:
 // [
 {
 "id": "1033"
 ,"t" : "AXP"
 ,"e" : "NYSE"
 ,"l" : "80.11"
 ,"l_fix" : "80.11"
 ,"l_cur" : "80.11"
 ,"s": "0"
 ,"ltt":"3:30PM EDT"
 ,"lt" : "Apr 20, 3:30PM EDT"
 ,"lt_dts" : "2017-04-20T15:30:24Z"
 ,"c" : "+4.56"
 ,"c_fix" : "4.56"
 ,"cp" : "6.04"
 ,"cp_fix" : "6.04"
 ,"ccol" : "chg"
 ,"pcls_fix" : "75.55"
 }
 ]
 *
 * The only relavent data is ,"l" : "80.11"
 * The data needs to be parsed so that it only returns 80.11
 */
- (NSString*) retrieveStringFromDownloadedFileByUrl {
    NSString* fileContents = nil;
    NSString* urlOfstockPriceFileFullFileSpec = [NSString stringWithFormat:@"file://%@", stockPriceFileFullFileSpec];
    NSURL *downloadedFile = [NSURL URLWithString:urlOfstockPriceFileFullFileSpec];
    NSError *readErrors;
    
    fileContents = [[NSString alloc] initWithContentsOfURL:downloadedFile encoding:NSUTF8StringEncoding error:&readErrors];
    if (fileContents == nil) {
        downloadFailedErrorString = [readErrors localizedFailureReason];
        NSLog(@"Error reading file at %@\n%@", downloadedFile, [readErrors localizedFailureReason]);
        downloadHadErrors = YES;
        return downloadFailedErrorString;
    }
    else {
        NSRange range = [fileContents rangeOfString:@",\"l\" : \""];
        NSString *hackedFileContents = [fileContents substringFromIndex:NSMaxRange(range)];
        NSArray *hackedStringComponents = [hackedFileContents componentsSeparatedByString:@"\""];
        fileContents = hackedStringComponents[0];
    }
    
    return fileContents;
}

// Read the downloaded file into a string, then parse the string.
// This is implemented without a check that the download task completed. Since the main operation
// queue is being used rather than an alternate queue it is assumed that this program is
// synchronous rather than asynchronous
- (NSString*) ParseDownoadedFileForStockPrice {
    NSString* returnAmexStockPrice = nil;
    
    //  If there were errors, just report the errors, don't attempt to parse the data in the file
    //  since it may not be there or it may be incomplete.
    if (downloadHadErrors) {
        return downloadFailedErrorString;
    }
    
    returnAmexStockPrice = [self retrieveStringFromDownloadedFileByUrl];
    

    return returnAmexStockPrice;
}

//  Returns a string for the label in the user interface when the Networking button is clicked.
//  Attempt to connect using WiFi first because this uses less power than the cellphone (WWAN)
//  connection and does't add cost to the user (data charge on cell phone usage).
//  Download a file containing the current delayed American Express stock price. Parse the file
//  to get only the stock price. Embed the stock price within the text to be returned.
//
//  The download is not performed in the background, it is a download initiated when the user
//  clicks on the button. Any errors such as no connection, or the URL can't be reached are
//  therefore reported to the user.
- (NSString*) provideANetworkAccess {
    NSString* networkAccessDisplayString = @"Network access not implemented yet";
    
    [self setupAndStartdownloadStockPrice];

    // Since the download is implemented on the main queue this is a synchronous rather
    // than asynchronous program. It is therefore safe to process the data here rather
    // than in a delegate.
    NSString* amexStockPrice = [self ParseDownoadedFileForStockPrice];

    if (!downloadHadErrors) {
        NSString* preface = @"The current American Express stock price with a 15 minute delay is ";
        networkAccessDisplayString = [NSString stringWithFormat:@"%@ $%@", preface, amexStockPrice];
    }
    else {
        networkAccessDisplayString = amexStockPrice;
    }
    
    return networkAccessDisplayString;
}

- (void) createStockPriceFullFileSpec {
    // find a path to a writable directory to store the downloaded file. This is done once
    // so that button clicks are not affected by a directory search.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    stockPriceFilePath = [paths objectAtIndex:0];
    stockPriceFileName = @"latestStockQuote.txt";
    stockPriceFileFullFileSpec = [stockPriceFilePath stringByAppendingPathComponent:stockPriceFileName];
    
}

// Simple setup since all networking actions will be performed when the user clicks a button in the
// application interface. The alternate to this would be to set up a timed loop that would download
// the information on a periodic basis in the background using the features of NSUrlSession (not an
// explict loop in this file).

// While implementing this as a loop would show the results of the in the background would allow the
// button click to perform more quickly, it would use more power, and if the user isn't close to a WiFi
// connection it would add more cost to the users data charges. Since the amount of data expected is
// less than 1K in size, it shouldn't take more than 5 seconds to download. If it was larger than 1K
// this would be implemented as a loop to repeated download the data in the background every 15 minutes.
- (id) init {
    googleFinanceUrl = @"http://finance.google.com/finance/info?client=ig&q=NSE:AXP";
    downloadHadErrors = NO;
    downloadFailedErrorString = nil;
    stockPriceFilePath = nil;
    stockPriceFileName = nil;
    stockPriceFileFullFileSpec = nil;
    
    [self createStockPriceFullFileSpec];
    
    return self;
}

@end
