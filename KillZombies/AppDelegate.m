//
//  AppDelegate.m
//  KillZombies
//
//  Created by revin on Dec.3,2014.
//  Copyright (c) 2014 revin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property NSMutableDictionary*dict;
@property bool snagitRunning,snagitMod;
@end

@implementation AppDelegate
#define EXECPATH "/Applications/Snagit.app/Contents/MacOS/Snagit"
static inline void toggleSnagitEditorState(bool x){
    if(x)system("chmod +x "EXECPATH);
    else system("chmod -x "EXECPATH);
}
-(void)someotherAppGotDeactivated:(NSNotification*)notification{
    NSDictionary*_n=[notification userInfo];if(_n==nil)return;
    NSRunningApplication*ra=[_n objectForKey:NSWorkspaceApplicationKey];if(ra==nil)return;
    NSString*name=[ra localizedName];
#define bailout(msg) {NSLog(@"%s(%d): %@",msg,error,name);if(!supressWrns)AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);return;}
    if(self.snagitRunning&&[@"SnagitHelper" isEqual:name]){
        self.snagitRunning=false;
        if(self.snagitMod){
            self.snagitMod=false;
            toggleSnagitEditorState(true);
        }return;
    }
    if(!self.dict[name])return;
    bool supressWrns=[@"VLC" isEqual:name];
    AXUIElementRef xa=AXUIElementCreateApplication([ra processIdentifier]);
    AXError error;CFTypeRef dontCare;
    error=AXUIElementCopyAttributeValue(xa,kAXWindowsAttribute,&dontCare);
    if(error)bailout("get kAXWindowsAttribute");
    if([(__bridge NSArray*)dontCare count])return;
    error=AXUIElementCopyAttributeValue(xa,kAXMainWindowAttribute,&dontCare);
    if(!error)return;else if(kAXErrorNoValue!=error)bailout("get kAXMainWindowAttribute");
    error=AXUIElementCopyAttributeValue(xa,kAXFocusedWindowAttribute,&dontCare);
    if(!error)return;else if(kAXErrorNoValue!=error)bailout("get kAXFocusedWindowAttribute");
    error=AXUIElementCopyAttributeValue(xa,kAXExtrasMenuBarAttribute,&dontCare);
    if(!error)return;else if(kAXErrorNoValue!=error)bailout("get AXExtrasMenuBarAttribute");
    [ra terminate];
}
-(void)someotherAppGotActivated:(NSNotification*)notification{
    NSDictionary*_n=[notification userInfo];if(_n==nil)return;
    NSRunningApplication*ra=[_n objectForKey:NSWorkspaceApplicationKey];if(ra==nil)return;
    NSString*name=[ra localizedName];
    if([@"SnagitHelper" isEqual:name])
        self.snagitRunning=true;
}
-(void)applicationWillBecomeActive:(NSNotification*)notification{
    self.dict=[NSMutableDictionary dictionary];
    id opt=(id)kCFBooleanTrue;
    self.dict[@"Xcode"]=opt;
    self.dict[@"Kaleidoscope"]=opt;
    self.dict[@"GitHub"]=opt;
    self.dict[@"TextEdit"]=opt;
    self.dict[@"Automator"]=opt;
    self.dict[@"Script Editor"]=opt;
    self.dict[@"Sublime Text"]=opt;
    
    self.dict[@"Terminal"]=opt;
    self.dict[@"Activity Monitor"]=opt;
    self.dict[@"QuickTime Player"]=opt;
    self.dict[@"MPlayer OSX Extended"]=opt;
    self.dict[@"VLC"]=opt;
    
    self.dict[@"Preview"]=opt;
    self.dict[@"Pages"]=opt;
    self.dict[@"Numbers"]=opt;
    self.dict[@"Keynote"]=opt;
    
    self.dict[@"VMware Fusion"]=opt;
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToForegroundApplication);
}
-(IBAction)buttonTapped:(NSButton*)sender
{
    [NSApp terminate:self];
}
-(void)applicationDidResignActive:(NSNotification*)notification{
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToUIElementApplication);
}
-(void)applicationDidFinishLaunching:(NSNotification*)notification{
    if(!AXIsProcessTrusted()){
        [self.window close];
        NSAlert*alert=[[NSAlert alloc]init];
        [alert addButtonWithTitle:@"Quit"];
        [alert setMessageText:@"KillZombies"];
        [alert setInformativeText:@"Can't acquire Accessibility Permissions"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [NSApp terminate:self];
    }else{
        NSNotificationCenter*ncc=[[NSWorkspace sharedWorkspace]notificationCenter];
        [ncc addObserver:self selector:@selector(someotherAppGotDeactivated:) name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
        [ncc addObserver:self selector:@selector(someotherAppGotActivated:)   name:NSWorkspaceDidActivateApplicationNotification   object:nil];
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent*ev){
            if(self.snagitRunning)toggleSnagitEditorState(!(self.snagitMod=[ev modifierFlags]&NSAlternateKeyMask));
        }];
    }
}
-(void)applicationWillTerminate:(NSNotification*)notification{
    // Insert code here to tear down your application
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication{
    return true;
}
@end
