using Config;
using Config2;
using Gtk;
using Posix;

public class Iccloader : Object {
    private Gdk.Pixbuf icon;
    private Gtk.StatusIcon tray_icon;
    private Gtk.Menu menu;
    private Gtk.Dialog pref_window;
    private Gtk.Box pref_vbox;
    private KeyFile keyfile;
    private string config_path;
    private HashTable<int, string> icc_data;

    /*CompareFunc<int> intcmp = (a, b) => {*/
        /*return (int) (a > b) - (int) (a < b);*/
    /*};*/
    CompareFunc<int> intcmp_reverse = (a, b) => {
        return (int) (a < b) - (int) (a > b);
    };


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
        tray_icon = new Gtk.StatusIcon.from_pixbuf (icon);
        tray_icon.tooltip_text = Config.PACKAGE_NAME;
        tray_icon.visible = true;
    }

    private void error_dialog (string errors) {
        var msg = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.CLOSE, errors);
        msg.icon = icon;
        msg.response.connect ((response_id) => {
                msg.destroy ();
                });
        msg.show ();
    }

    public void setup_system_tray () {
        load_preferences ();
        menu = new Gtk.Menu();
        if (icc_data.size () > 0) {
            var temps = icc_data.get_keys ();
            temps.sort (intcmp_reverse);
            foreach (var temp in temps) {
                var filename = icc_data.get (temp);
                var menu_temp = new Gtk.ImageMenuItem.with_label (temp.to_string ());
                menu_temp.activate.connect (() => {
                    string p_stdout, p_stderr;
                    int p_status;
                    var dispwin = "argyll-dispwin";
                    try {
                        Process.spawn_command_line_sync (@"$(dispwin) -I \"$(filename)\"", out p_stdout, out p_stderr, out p_status);
                        Process.check_exit_status (p_status);
                        Process.spawn_command_line_sync (@"$(dispwin) -L", out p_stdout, out p_stderr, out p_status);
                        Process.check_exit_status (p_status);
                        tray_icon.tooltip_text = @"$(temp)°K";
                    } catch (Error e) {
                        var error_msg = @"Error executing dispwin: $(e.message)\n";
                        GLib.stderr.printf (error_msg);
                        if (p_stdout != null) {
                            GLib.stdout.puts (p_stdout);
                        }
                        if (p_stderr != null) {
                            GLib.stdout.puts (p_stderr);
                        }
                        error_dialog (error_msg + p_stdout + p_stderr);
                    }
                });
                menu.append (menu_temp);
            }
            var menu_sep = new Gtk.SeparatorMenuItem ();
            menu.append (menu_sep);
        }
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
        keyfile = new KeyFile ();
        var path = Path.build_filename (Environment.get_user_config_dir(), Config.PACKAGE);
        DirUtils.create_with_parents (path, 0700);
        config_path = Path.build_filename (path, "config.ini");
        try {
            keyfile.load_from_file(config_path, KeyFileFlags.NONE);
        } catch (Error e) {
            GLib.stderr.printf ("Could not load the config file: %s\n", e.message);
        }
        icc_data = new HashTable<int, string> (direct_hash, direct_equal);
        foreach (unowned string group in keyfile.get_groups ()) {
            var temp = int.parse (group);
            string filename;
            try {
                filename = keyfile.get_string (group, "filename");
            } catch (Error e) {
                GLib.stderr.printf ("Error loading preferences: %s\n", e.message);
                continue;
            }
            icc_data.insert (temp, filename);
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
        pref_window.icon = icon;
        pref_vbox = builder.get_object ("vbox") as Gtk.Box;
        var add_button = builder.get_object ("add_button") as Gtk.Button;
        add_button.clicked.connect (add_pref_row_no_args);
        var cancel_button = builder.get_object ("cancel") as Gtk.Button;
        cancel_button.clicked.connect (() => {
            pref_window.close ();
        });
        var save_button = builder.get_object ("save") as Gtk.Button;
        save_button.clicked.connect (save_preferences);
        // show previously saved preferences
        var temps = icc_data.get_keys ();
        temps.sort (intcmp_reverse);
        foreach (var temp in temps) {
            var filename = icc_data.get (temp);
            add_pref_row (temp.to_string (), filename);
        }

        pref_window.show_all ();
    }

    private void add_pref_row_no_args () {
        // stupid signal listener can't have args even when defaults are provided
        add_pref_row ();
    }

    private void add_pref_row (string default_temp = "", string default_filename = "") {
        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        hbox.expand = false;
        var entry = new Gtk.Entry ();
        if (default_temp != "") {
            entry.set_text (default_temp);
        }
        hbox.add (entry);
        var label = new Gtk.Label ("°K");
        label.set_alignment (0, (float)0.5);
        hbox.add (label);
        var chooser = new Gtk.FileChooserButton ("Select a corresponding ICC file", Gtk.FileChooserAction.OPEN);
        chooser.expand = true;
        chooser.show_hidden = true; // doesn't work for some reason
        chooser.margin_left = 5;
        // only show ICC files
        var filter = new Gtk.FileFilter ();
        filter.add_pattern ("*.icc");
        filter.add_pattern ("*.ICC");
        chooser.set_filter (filter);
        // default directory
        var path = Path.build_filename (Environment.get_user_config_dir(), "color", "icc", "devices", "display");
        if (FileUtils.test (path, FileTest.IS_DIR)) {
            chooser.set_current_folder (path);
        }
        if (default_filename != "") {
            chooser.set_filename (default_filename);
        }
        hbox.add (chooser);
        var remove_button = new Gtk.Button.from_stock (Gtk.Stock.REMOVE);
        remove_button.margin_left = 5;
        remove_button.clicked.connect (() => {
            pref_vbox.remove (hbox);
        });
        hbox.add (remove_button);
        pref_vbox.pack_start (hbox, false);
        pref_window.show_all ();
    }

    private void save_preferences () {
        // empty the keyfile
        keyfile = new KeyFile ();
        var hboxes = pref_vbox.get_children ();
        var errors = "";
        bool good_data;
        foreach (var hbox in hboxes) {
            good_data = true;
            var box = hbox as Gtk.Box;
            var elements = box.get_children ();
            var entry = elements.nth_data (0) as Gtk.Entry;
            var temp = entry.get_text ();
            if (temp.length == 0) {
                errors += "Empty color temperature\n";
                good_data = false;
            } else {
                var temp_val = int.parse (temp);
                if (temp_val == 0) {
                    errors += "Invalid color temperature\n";
                    good_data = false;
                }
            }
            var chooser = elements.nth_data (2) as Gtk.FileChooserButton;
            var filename = chooser.get_filename ();
            if (filename == null) {
                errors += "No ICC file selected\n";
                good_data = false;
            }
            if (good_data) {
                keyfile.set_string (temp, "filename", filename);
            }
        }
        if (errors.length > 0) {
            error_dialog (errors);
        } else {
            size_t length;
            var contents = keyfile.to_data (out length);
            try {
                FileUtils.set_contents (config_path, contents, (ssize_t)length);
            } catch (Error e) {
                GLib.stderr.printf ("Could not save the config file: %s\n", e.message);
            }
        }
        
        pref_window.close ();
        setup_system_tray (); // to update the ICC menu items
    }
}

int main (string[] args) {
    Gtk.init (ref args);
    var iccloader = new Iccloader ();
    iccloader.setup_system_tray ();

    Gtk.main ();
    return 0;
}

