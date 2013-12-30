using Config;
using Config2;
using Gtk;
using Posix;

public class Iccloader : Object {
    private Gtk.Window window;
    private Gdk.Pixbuf icon;
    private Gtk.StatusIcon tray_icon;
    private Gtk.Menu menu;
    private Gtk.Dialog pref_window;
    private Gtk.Box pref_vbox;
    private GLib.KeyFile keyfile;
    private string config_path;

    public Iccloader () {
        // window and tray icon
        try {
            icon = Gtk.IconTheme.get_default ().load_icon (Config.PACKAGE, 48, 0);
        } catch (Error e) {
            // GLib.stderr.printf ("Could not load the window icon from the default theme: %s\n", e.message);
            try {
                icon = new Gdk.Pixbuf.from_file (Path.build_filename (Config2.ICON_DIR, @"$(Config.PACKAGE).svg"));
            } catch (Error e) {
                GLib.stderr.printf ("Could not load the window icon from the SVG file: %s\n", e.message);
            }
        }
    }

    public void setup_window () {
        // UI
        var builder = new Gtk.Builder ();
        try {
            builder.add_from_file (Path.build_filename (Config2.DATA_DIR, "main.ui"));
        } catch (Error e) {
            GLib.stderr.printf ("UI loading error: %s\n", e.message);
            Posix.exit (1);
        }
        window = builder.get_object ("window1") as Window;
        var label = builder.get_object ("label1") as Label;
        window.title = Config.PACKAGE_NAME;
        window.icon = icon;
        label.label = "Hello, world!";
        window.destroy.connect (Gtk.main_quit);

        window.show_all ();
    }

    public void setup_system_tray () {
        tray_icon = new Gtk.StatusIcon.from_pixbuf (icon);
        tray_icon.tooltip_text = Config.PACKAGE_NAME;
        tray_icon.visible = true;
        menu = new Gtk.Menu();
        var menu_foo = new Gtk.ImageMenuItem.with_mnemonic ("_Foo");
        menu.append (menu_foo);
        var menu_pref = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.PREFERENCES, null);
        menu_pref.activate.connect (show_preferences);
        menu.append (menu_pref);
        var menu_sep = new Gtk.SeparatorMenuItem ();
        menu.append (menu_sep);
        var menu_quit = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.QUIT, null);
        menu_quit.activate.connect (Gtk.main_quit);
        menu.append (menu_quit);
        menu.show_all ();
        tray_icon.popup_menu.connect (menu_popup);
    }
    
    private void menu_popup (uint button, uint time) {
        menu.popup (null, null, null, button, time);
    }

    private void load_preferences () {
        keyfile = new GLib.KeyFile ();
        var path = GLib.Path.build_filename (GLib.Environment.get_user_config_dir(), Config.PACKAGE);
        GLib.DirUtils.create_with_parents (path, 0700);
        config_path = GLib.Path.build_filename (path, "config.ini");
        try {
            keyfile.load_from_file(config_path, KeyFileFlags.NONE);
        } catch (Error e) {
            GLib.stderr.printf ("Could not load the config file: %s\n", e.message);
        }
    }

    private void show_preferences () {
        load_preferences ();
        var builder = new Gtk.Builder ();
        try {
            builder.add_from_file (Path.build_filename (Config2.DATA_DIR, "preferences.ui"));
        } catch (Error e) {
            GLib.stderr.printf ("UI loading error: %s\n", e.message);
            Posix.exit (1);
        }
        pref_window = builder.get_object ("dialog1") as Gtk.Dialog;
        pref_vbox = builder.get_object ("vbox") as Gtk.Box;
        var add_button = builder.get_object ("add_button") as Gtk.Button;
        add_button.clicked.connect (add_pref_row);
        var cancel_button = builder.get_object ("cancel") as Gtk.Button;
        cancel_button.clicked.connect (() => {
            pref_window.close ();
        });
        var save_button = builder.get_object ("save") as Gtk.Button;
        save_button.clicked.connect (save_preferences);

        pref_window.show_all ();
    }

    private void save_preferences () {
        // empty the keyfile
        keyfile = new GLib.KeyFile ();
        var hboxes = pref_vbox.get_children ();
        foreach (var hbox in hboxes) {
            print (hbox.name + "\n");
        }
        
        pref_window.close ();
    }

    private void add_pref_row () {
        var hbox = create_hbox ();
        pref_vbox.pack_start (hbox, false);
        pref_window.show_all ();
    }

    private Gtk.Box create_hbox () {
        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        hbox.expand = false;
        var entry = new Gtk.Entry ();
        hbox.add (entry);
        var label = new Gtk.Label ("°K");
        label.set_alignment (0, (float)0.5);
        hbox.add (label);
        var chooser = new Gtk.FileChooserButton ("Select a corresponding ICC file", Gtk.FileChooserAction.OPEN);
        chooser.expand = true;
        chooser.margin_left = 5;
        var filter = new Gtk.FileFilter ();
        filter.add_pattern ("*.icc");
        chooser.set_filter (filter);
        hbox.add (chooser);
        var remove_button = new Gtk.Button.from_stock (Gtk.Stock.REMOVE);
        remove_button.margin_left = 5;
        remove_button.clicked.connect (() => {
            pref_vbox.remove (hbox);
        });
        hbox.add (remove_button);
        return hbox;
    }
}

int main (string[] args) {
    Gtk.init (ref args);
    var iccloader = new Iccloader ();
    /*iccloader.setup_window ();*/
    iccloader.setup_system_tray ();

    Gtk.main ();
    return 0;
}

