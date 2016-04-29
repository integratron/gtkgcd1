#import <gtk/gtk.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@interface TextWindow : NSObject

@property (readwrite) GtkWidget *window;
@property (readwrite) GtkWidget *scrollview;
@property (readwrite) GtkWidget *textview;
@property (readwrite) GtkTextBuffer *buffer;
@property (readwrite) GtkWidget *button;
@property (readwrite) GtkWidget *avbox;

@property (readwrite) GtkTextIter iter;


- (id) init;
- (void) doLog:(NSString*)s;

@end
