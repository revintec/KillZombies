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
#define PRETTYLOG(fmt,...) NSLog([fmt stringByAppendingString:@"    at %s(line %d)"],##__VA_ARGS__,__PRETTY_FUNCTION__,__LINE__)
-(CFTypeRef)filterItems:(CFTypeRef)parent title:(NSString*)title{
    CFTypeRef children;if(AXUIElementCopyAttributeValue(parent,kAXChildrenAttribute,&children))return nil;
    for(CFIndex i=CFArrayGetCount(children)-1;i>=0;--i){
        CFTypeRef t,child=CFArrayGetValueAtIndex(children,i);
        if(AXUIElementCopyAttributeValue(child,kAXTitleAttribute,&t))return nil;
        if([title isEqual:(__bridge id)(t)])
            return child;
    }return nil;
}
-(void)delayedRAOperations:(NSRunningApplication*)ra{
    if([ra isTerminated])return;
    if([ra isActive]){
        NSString*name=[ra localizedName];
        PRETTYLOG(@"%s(%@): ERROR","unexcepted execution branch",name);
        AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
        return;
    }
    NSString*name=[ra localizedName];
    if(self.snagitRunning&&[@"SnagitHelper" isEqual:name]){
        self.snagitRunning=false;
        if(self.snagitMod){
            self.snagitMod=false;
            toggleSnagitEditorState(true);
        }return;
    }
    if(!self.dict[name])return;
    AXUIElementRef xa=AXUIElementCreateApplication([ra processIdentifier]);
    AXError error;
#define bailout(msg) {PRETTYLOG(@"%s(%@): %d",msg,name,error);AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);return;}
#define bailout2(msg) {PRETTYLOG(@"%s(%@): got nil",msg,name);AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);return;}
    CFTypeRef menus;if((error=AXUIElementCopyAttributeValue(xa,kAXMenuBarAttribute,&menus)))bailout("get kAXMenuBarAttribute");
    CFTypeRef menux;if(!(menux=[self filterItems:menus title:@"Window"]))bailout2("get Window(Menu)");
    CFTypeRef itemx;if((error=AXUIElementCopyAttributeValue(menux,kAXChildrenAttribute,&itemx)))bailout("get menu content");
    if(CFArrayGetCount(itemx)!=1)bailout("check menu content");
    CFTypeRef item;if(!(item=[self filterItems:CFArrayGetValueAtIndex(itemx,0) title:@"Bring All to Front"]))bailout2("get Bring All to Front(Menu)");
    CFTypeRef enabled;if((error=AXUIElementCopyAttributeValue(item,kAXEnabledAttribute,&enabled)))bailout("is menu item enabled");
    if(enabled!=kCFBooleanFalse)return;
    CFTypeRef windows,extras;
    if(!(error=AXUIElementCopyAttributeValue(xa,kAXWindowsAttribute,&windows))){
        if(CFArrayGetCount(windows))return;
    }else bailout("get kAXWindowsAttribute");
    if(!(error=AXUIElementCopyAttributeValue(xa,kAXExtrasMenuBarAttribute,&extras)))return;
    else if(kAXErrorNoValue!=error)bailout("get AXExtrasMenuBarAttribute");
    [ra terminate];
}
-(void)someotherAppGotDeactivated:(NSNotification*)notification{
    NSDictionary*_n=[notification userInfo];if(!_n)return;
    NSRunningApplication*ra=[_n objectForKey:NSWorkspaceApplicationKey];if(!ra)return;
    [self performSelector:@selector(delayedRAOperations:) withObject:ra afterDelay:0.8];
}
-(void)someotherAppGotActivated:(NSNotification*)notification{
    NSDictionary*_n=[notification userInfo];if(!_n)return;
    NSRunningApplication*ra=[_n objectForKey:NSWorkspaceApplicationKey];if(!ra)return;
    NSString*name=[ra localizedName];
    if([@"SnagitHelper" isEqual:name])
        self.snagitRunning=true;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedRAOperations:) object:ra];
}
// update configuration inside this file
-(void)applicationWillBecomeActive:(NSNotification*)notification{
    // TODO read configuration from file instead of hard-coded
    self.dict=[NSMutableDictionary dictionary];
    id opt=(id)kCFBooleanTrue;
    self.dict[@"Xcode"]=opt;
    self.dict[@"Console"]=opt;
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

    self.dict[@"Keychain Access"]=opt;
    self.dict[@"VMware Fusion"]=opt;
    self.dict[@"Transmit"]=opt;
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
