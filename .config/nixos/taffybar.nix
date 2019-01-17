{ mkDerivation, base, cairo, ConfigFile, containers, dbus
, dbus-hslogger, directory, dyre, either, enclosed-exceptions
, filepath, gi-cairo, gi-gdk, gi-gdkpixbuf, gi-gdkx11, gi-glib
, gi-gtk, gi-gtk-hs, glib, gtk-sni-tray, gtk-strut, gtk-traymanager
, gtk3, haskell-gi, haskell-gi-base, hslogger, HStringTemplate
, HTTP, multimap, network, network-uri, old-locale
, optparse-applicative, parsec, process, rate-limit, regex-compat
, safe, split, status-notifier-item, stdenv, stm, template-haskell
, text, time, time-locale-compat, time-units, transformers
, transformers-base, tuple, unix, utf8-string, X11, xdg-basedir
, xml, xml-helpers, xmonad, xmonad-contrib
}:
mkDerivation {
  pname = "taffybar";
  version = "2.1.2";
  sha256 = "c4826da6677d2b08153663a5d2586cb61447f4ec26116a4f4776cf8134501f83";
  isLibrary = true;
  isExecutable = true;
  enableSeparateDataOutput = true;
  libraryHaskellDepends = [
    base cairo ConfigFile containers dbus dbus-hslogger directory dyre
    either enclosed-exceptions filepath gi-cairo gi-gdk gi-gdkpixbuf
    gi-gdkx11 gi-glib gi-gtk gi-gtk-hs glib gtk-sni-tray gtk-strut
    gtk-traymanager gtk3 haskell-gi haskell-gi-base hslogger
    HStringTemplate HTTP multimap network network-uri old-locale parsec
    process rate-limit regex-compat safe split status-notifier-item stm
    template-haskell text time time-locale-compat time-units
    transformers transformers-base tuple unix utf8-string X11
    xdg-basedir xml xml-helpers xmonad xmonad-contrib
  ];
  executableHaskellDepends = [ base hslogger optparse-applicative ];
  homepage = "http://github.com/taffybar/taffybar";
  description = "A desktop bar similar to xmobar, but with more GUI";
  license = stdenv.lib.licenses.bsd3;
}
