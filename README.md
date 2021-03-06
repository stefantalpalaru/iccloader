## About

Systray widget used to load ICC color profiles with different color
temperatures, either on demand or automatically based on the sun's position.

iccloader's main inspiration is [redshift][1].

## Usage

```sh
iccloader &
```
The program was tested on Linux with ICC profiles generated by [ArgyllCMS][2]
using [dispcalGUI][3] as a front-end.

Various color temperatures in Kelvin were set for the white point. In auto
loading mode, iccloader will use the highest temperature during the day, the
lowest during the night and the rest for the transition period.

The sun's position needed to determine these intervals is computed based on
latitude and longitude using [solpos][4].

## Build

### Generic

```sh
./autogen.sh
./configure VALAC=$(type -P valac-0.36)
make
```

### Gentoo

```sh
layman -a stefantalpalaru
emerge iccloader
```

## Tips

- when adding ICC/ICM files in the "Preferences" window, try the "Auto add"
functionality first. If the files were generated using dispcalGUI and saved in
one of the known directories, the corresponding color temperatures will be
inferred from the file names.

- when using OpenStreetMap to get your position, the latitude and longitude are the last 2 numbers in the URL.
E.g.: for http://www.openstreetmap.org/#map=14/45.4298/9.1936 lat=45.4298 and lon=9.1936

- if you want smoother transitions, create more ICC profiles in the day-night interval

- if you don't need color management and would like seamless transitions, try [redshift][1]

## Screenshots

The screenshots are using the Zukitwo GTK3 theme and Tango icons.

![](screenshots/iccloader_prefs_and_popup.jpg?raw=true "iccloader preferences and popup menu")

![](screenshots/dispcalgui_color_temperature.jpg?raw=true "dispcalGUI - setting the color temperature in an ICC profile")

## Known problems

- "solpos" will stop working after 2050

## License

MPL-2.0

## Credits

- author: Ștefan Talpalaru <stefantalpalaru@yahoo.com>

- homepage: https://github.com/stefantalpalaru/iccloader


[1]: http://jonls.dk/redshift/
[2]: http://www.argyllcms.com/
[3]: http://dispcalgui.hoech.net/
[4]: http://rredc.nrel.gov/solar/codesandalgorithms/solpos/

