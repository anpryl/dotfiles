import           Data.Default
import           Data.List
import           Data.Monoid
import           System.Exit
import           System.Taffybar.Hooks.PagerHints (pagerHints)
import           XMonad
import           XMonad.Actions.PhysicalScreens
import           XMonad.Actions.SpawnOn           (manageSpawn, spawnOn)
import           XMonad.Actions.UpdatePointer     (updatePointer)

import           XMonad.Hooks.EwmhDesktops        (ewmh, ewmhDesktopsLogHook)
import           XMonad.Hooks.ManageDocks         (ToggleStruts (..),
                                                   avoidStruts, docks,
                                                   manageDocks)
import           XMonad.Hooks.ManageHelpers       (doCenterFloat, doFullFloat,
                                                   isDialog, isFullscreen,
                                                   transience')
import           XMonad.Hooks.UrgencyHook         (NoUrgencyHook (..),
                                                   RemindWhen (..),
                                                   SuppressWhen (..),
                                                   UrgencyConfig (..),
                                                   remindWhen, suppressWhen,
                                                   withUrgencyHookC)
import           XMonad.Layout.NoBorders          (smartBorders)
import           XMonad.Prompt
import           XMonad.Prompt.Shell
import           XMonad.Util.SpawnOnce            (spawnOnce)

import qualified Data.Map                         as M
import qualified XMonad.StackSet                  as W

main = do
    spawn "pkill taffybar ; taffybar"
    spawn "feh --bg-max /home/anpryl/Dropbox/wallpapers/1443974-boring.png"
    xmonad config'

config' = docks $ pagerHints $ ewmh $ uhook $ def
    { modMask = mod4Mask
    , terminal = terminal'
    , workspaces = workspaces'
    , manageHook = manageHook' <+> manageSpawn <+> manageDocks
    , layoutHook = smartBorders $ avoidStruts $ layout'
    , keys = myKeys <> keys def
    , logHook = updatePointer (0.5, 0.5) (0, 0)
    , borderWidth = 2
    , startupHook = startup' <+> startupHook def
    }
  where
    uhook = withUrgencyHookC NoUrgencyHook urgentConfig
    urgentConfig = UrgencyConfig { suppressWhen = Focused, remindWhen = Dont }

terminal' = "st"

startup' = do
    spawnOn "Web" "firefox"
    spawnOn "Web" "google-chrome-stable"
    spawnOn "Term" terminal'
    spawnOn "IM" "skypeforlinux"
    spawnOn "IM" "rambox"
    spawnOn "Media" "google-play-music-desktop-player"
    spawnOn "Keepass" "keepass"
    spawnOn "Steam" "steam"

workspaces' = wspaces ++ (map show $ drop (length wspaces) [1..9])
  where
    wspaces = ["Web", "Term", "IM", "Work", "Media", "Keepass", "Steam"]

manageHook' = composeAll
    [ isFullscreen           --> doFullFloat
    , name      =? "KeePass" --> moveTo "Keepass"
    , className =? "Vlc"     --> doCenterFloat
    , transience'
    , isDialog               --> doCenterFloat
    , role      =? "pop-up"  --> doCenterFloat
    ]
  where
    moveTo = doF . W.shift
    role = stringProperty "WM_WINDOW_ROLE"
    name = stringProperty "WM_NAME"

layout' = tiled ||| Full
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100


myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, xK_a), onPrevNeighbour W.view)
    , ((modMask, xK_o), onNextNeighbour W.view)
    , ((modMask .|. shiftMask, xK_a), onPrevNeighbour W.shift)
    , ((modMask .|. shiftMask, xK_o), onNextNeighbour W.shift)
    , ((modMask, xK_c), kill)
    , ((modMask, xK_y), spawn "xmonad --restart")
    , ((modMask .|. shiftMask, xK_y), spawn "xmonad --recompile && xmonad --restart")
    , ((modMask, xK_p), shellPrompt promptCfg)
    , ((modMask .|. shiftMask, xK_l     ), io (exitWith ExitSuccess))
    ]
    <>
    [((modMask .|. mask, key), f sc)
      | (key, sc) <- zip [xK_q, xK_w, xK_e] [0..]
      , (f, mask) <- [(viewScreen, 0), (sendToScreen, shiftMask)]]

promptCfg = def
    { position     = Bottom
    , height       = 50
    , font         = "xft:Roboto:size=16"
    , bgColor      = "#002b36"
    , bgHLight     = "#b58900"
    , fgColor      = "#268bd2"
    , fgHLight     = "#002b36"
    , promptBorderWidth = 2
    , borderColor  = "#dc322f"
    }
