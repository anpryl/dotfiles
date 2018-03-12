import           Data.Default
import           Data.List
import           Data.Monoid
import           Data.Time                        (getCurrentTime)
import           Data.Time.Format                 (defaultTimeLocale, formatTime)
import           GHC.IO.Exception                 (IOException (..))
import           Graphics.X11.ExtraTypes.XF86
import           System.Directory                 (createDirectoryIfMissing, getHomeDirectory,
                                                   renameFile)
import           System.Exit
import           System.FilePath.Posix            (joinPath, (<.>))
import           System.Taffybar.Hooks.PagerHints (pagerHints)
import           XMonad
import           XMonad.Actions.PhysicalScreens
import           XMonad.Actions.SpawnOn           (manageSpawn, spawnOn)
import           XMonad.Actions.UpdatePointer     (updatePointer)
import           XMonad.Actions.Volume
import           XMonad.Hooks.EwmhDesktops        (ewmh, ewmhDesktopsLogHook)
import           XMonad.Hooks.ManageDocks         (ToggleStruts (..), avoidStruts, docks,
                                                   manageDocks)
import           XMonad.Hooks.ManageHelpers       (doCenterFloat, doFullFloat, isDialog,
                                                   isFullscreen, transience', (/=?))
import           XMonad.Hooks.UrgencyHook         (NoUrgencyHook (..), RemindWhen (..),
                                                   SuppressWhen (..), UrgencyConfig (..),
                                                   remindWhen, suppressWhen, withUrgencyHookC)
import           XMonad.Layout.NoBorders          (smartBorders)
import           XMonad.Prompt
import           XMonad.Prompt.Shell
import           XMonad.Util.Paste
import           XMonad.Util.SpawnOnce            (spawnOnce)

import qualified Data.Map                         as M
import           XMonad.Actions.CycleWS           as CW
import qualified XMonad.StackSet                  as W

main = do
    spawn "pkill taffybar ; taffybar"
    spawn $ "autorandr -c ; " ++ setWallpaper
    spawn $ "sleep 10 ; keepassxc"
    xmonad config'

setWallpaper = "feh --bg-fill /home/anpryl/Dropbox/wallpapers/1443974-boring.png"

config' =
    docks $
    pagerHints $
    ewmh $
    uhook $
    def
    { modMask = mod4Mask
    , terminal = terminal'
    , workspaces = workspaces'
    , manageHook = manageHook' <+> manageSpawn <+> manageDocks
    , layoutHook = smartBorders $ avoidStruts $ layout'
    , keys = myKeys <> keys def
    , logHook = updatePointer (0.5, 0.5) (0, 0)
    , borderWidth = 2
    , focusedBorderColor = solarizedRed
    , startupHook = startup' <+> startupHook def
    }
  where
    uhook = withUrgencyHookC NoUrgencyHook urgentConfig
    urgentConfig = UrgencyConfig {suppressWhen = Focused, remindWhen = Dont}

terminal' = "st"

startup' = do
    spawnOn "Term" terminal'
    spawnOn "Web" "firefox"
    spawnOn "IM" "rambox"
    spawnOn "IM" "thunderbird"
    spawnOn "Media" "google-play-music-desktop-player"
    spawnOn "Media" "google-chrome-stable --app=https://playbeta.pocketcasts.com/web/"
    {- spawnOn "Media" "firefox --new-window https://playbeta.pocketcasts.com/web/" -}
  {- spawnOn "IM" "skypeforlinux" -}
  {- spawnOn "Web" "google-chrome-stable" -}
    {- spawnOn "Keepass" "keepassxc" -}
    pure ()

workspaces' = wspaces ++ (map show $ drop (length wspaces) [1 .. 8]) ++ ["IM"]
  where
    wspaces = ["Term", "Web", "Work", "Media", "Misc", "Keepass"]

manageHook' =
    composeAll
        [ isFullscreen                                        --> doFullFloat
        , name =? "KeePass"                                   --> moveTo "Keepass"
        , name =? "KeePassX - Password Manager"               --> moveTo "Keepass"
        , className =? "keepassxc"                            --> moveTo "Keepass"
        , className =? "Mail"                                 --> moveTo "IM"
        , className =? "Vlc"                                  --> doCenterFloat
        , className =? "Timeguard"                            --> doCenterFloat
        , name =? "Pocket Casts"                              --> moveTo "Media"
        , transience'
        , isDialog                                            --> doCenterFloat
        , className /=? "Google-chrome" <&&> role =? "pop-up" --> doCenterFloat
        ]
  where
    moveTo = doF . W.shift
    role = stringProperty "WM_WINDOW_ROLE"
    name = stringProperty "WM_NAME"

layout' = tiled ||| Full
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    ratio = 1 / 2
    delta = 3 / 100

myKeys conf@(XConfig {XMonad.modMask = modMask}) =
    M.fromList $
    [ ((modMask, xK_a), CW.toggleWS)
    , ((modMask, xK_q), onNextNeighbour W.view)

    , ((altMask .|. shiftMask, xK_h), sendKey altMask xK_Left) -- Back
    , ((altMask .|. shiftMask, xK_l), sendKey altMask xK_Right) -- Forward
    , ((altMask .|. shiftMask, xK_j), sendKey controlMask xK_Page_Up) -- Next tab
    , ((altMask .|. shiftMask, xK_k), sendKey controlMask xK_Page_Down) -- Prev tab


    , ((altMask, xK_h), sendKey noModMask xK_Left)
    , ((altMask, xK_l), sendKey noModMask xK_Right)
    , ((altMask, xK_j), sendKey noModMask xK_Down)
    , ((altMask, xK_k), sendKey noModMask xK_Up)
    , ((altMask, xK_b), sendKey noModMask xK_Home)
    , ((altMask, xK_e), sendKey noModMask xK_End)
    , ((altMask, xK_d), sendKey noModMask xK_Page_Down)
    , ((altMask, xK_u), sendKey noModMask xK_Page_Up)

    , ((modMask, xK_c), kill)
    , ((modMask, xK_u), autorandr "-c")
    , ((modMask .|. controlMask, xK_u), autorandr "-l docked-gaming")
    , ((modMask .|. shiftMask, xK_u), autorandr "-l double-docked")
    , ((modMask .|. shiftMask, xK_l), spawn "slock")
    , ((modMask .|. controlMask, xK_l), io (exitWith ExitSuccess))
    , ((modMask, xK_y), spawn "xmonad --recompile")
    , ((modMask .|. shiftMask, xK_y), spawn "xmonad --restart")
    , ((modMask, xK_p), shellPrompt promptCfg)
    , ((modMask .|. shiftMask, xK_m), spawnScript "toggle_all_sources.sh" >> pure ())
    , ((noModMask, xF86XK_AudioLowerVolume), changeVolume "-5%" >> pure())
    , ((noModMask, xF86XK_AudioRaiseVolume), changeVolume "+5%" >> pure())
    , ((noModMask, xF86XK_AudioMute), spawnScript "toggle_all_sinks.sh" >> pure ())
    , ((noModMask, xF86XK_MonBrightnessDown), spawn "light -U 5")
    , ((noModMask, xF86XK_MonBrightnessUp), spawn "light -A 5")
    , ((noModMask, xK_Print), screenshotAll)
    , ((modMask, xK_Print), liftIO screenshotToFolder)
    , ((modMask .|. shiftMask, xK_Print), screenshotZone)
    ] <>
    [ ((modMask .|. mask, key), f sc)
    | (key, sc) <- zip [xK_w, xK_e, xK_r] [0 ..]
    , (f, mask) <- [(viewScreen, 0), (sendToScreen, shiftMask)]
    ]
  where
    spawnScript name = spawn ("/home/anpryl/scripts/" <> name)
    changeVolume value =
        spawnScript "unmute_all_sinks.sh" >>
        spawnScript ("change_volume_all_sinks.sh '" <> value <> "'")
    altMask = mod1Mask
    autorandr flags = spawn ("autorandr " <> flags) >> spawn setWallpaper
    andNotifySend msg = " && notify-send \"" <> msg <> "\""
    screenshotZone =
        spawn $
        "import 'png:-' | xclip -selection clipboard -target image/png -i" <>
        andNotifySend "screenshot zone"
    screenshotAll =
        spawn $
        "import -window root 'png:-' | xclip -selection clipboard -target image/png -i" <>
        andNotifySend "screenshot to clipboard"
    screenshotToFolder = do
        hd <- getHomeDirectory
        date <- formatTime defaultTimeLocale "%F-%X-%q" <$> getCurrentTime
        let folder = joinPath [hd, "screenshots"]
            newFileName = joinPath [folder, date] <.> "png"
        createDirectoryIfMissing True folder
        spawn $ "import -window root " <> show newFileName <> andNotifySend "screenshot to folder"

promptCfg =
    def
    { position = Bottom
    , height = 50
    , font = "xft:Roboto:size=16"
    , bgColor = solarizedBase03
    , bgHLight = solarizedYellow
    , fgColor = solarizedBlue
    , fgHLight = solarizedBase03
    , promptBorderWidth = 2
    , borderColor = solarizedRed
    }

solarizedBase03 = "#002b36"

solarizedBase02 = "#073642"

solarizedBase01 = "#586e75"

solarizedBase00 = "#657b83"

solarizedBase0 = "#839496"

solarizedBase1 = "#93a1a1"

solarizedBase2 = "#eee8d5"

solarizedBase3 = "#fdf6e3"

solarizedYellow = "#b58900"

solarizedOrange = "#cb4b16"

solarizedRed = "#dc322f"

solarizedMagenta = "#d33682"

solarizedViolet = "#6c71c4"

solarizedBlue = "#268bd2"

solarizedCyan = "#2aa198"

solarizedGreen = "#859900"
