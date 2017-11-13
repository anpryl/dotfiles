import XMonad

import XMonad.Hooks.EwmhDesktops (ewmh, ewmhDesktopsLogHook)
import XMonad.Hooks.ManageDocks (manageDocks, docks)
import XMonad.Hooks.DynamicLog (statusBar, PP(..))
import XMonad.Hooks.UrgencyHook
import XMonad.Util.NamedWindows
import XMonad.Util.SpawnOnce
import XMonad.Actions.PhysicalScreens
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.Run

import System.Taffybar.Hooks.PagerHints (pagerHints)

import Data.Monoid
import Data.Default

import qualified Data.Map        as M
import qualified XMonad.StackSet as W


main = xmonad =<< statusBar "taffybar" def toggleStrutsKey config'

config' = docks $ pagerHints $ ewmh $ def
  { modMask = mod4Mask
  , terminal = "st"
  , manageHook = manageDocks
  , keys = myKeys <> keys def
  , logHook = ewmhDesktopsLogHook
  , borderWidth = 2
  }

toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  [ ((modMask, xK_a), onPrevNeighbour W.view)
  , ((modMask, xK_o), onNextNeighbour W.view)
  , ((modMask .|. shiftMask, xK_a), onPrevNeighbour W.shift)
  , ((modMask .|. shiftMask, xK_o), onNextNeighbour W.shift)
  , ((modMask, xK_r), spawn "xmonad --restart")
  , ((modMask .|. shiftMask, xK_r), spawn "xmonad --recompile && xmonad --restart")
  , ((modMask, xK_p), shellPrompt promptCfg)
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
