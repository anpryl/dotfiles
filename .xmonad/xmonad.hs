import XMonad

import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Actions.PhysicalScreens

import XMonad.Prompt
import XMonad.Prompt.Shell

import Data.Monoid

import qualified Data.Map        as M
import qualified XMonad.StackSet as W


main = xmonad =<< statusBar "taffybar" defaultPP toggleStrutsKey conf
-- main = xmonad =<< statusBar "/home/anpryl/.cache/taffybar/taffybar-linux-x86_64" defaultPP toggleStrutsKey conf

conf = ewmh $ defaultConfig
         { modMask = mod4Mask
         , terminal = "urxvt -e tmux"
         , manageHook = manageDocks
	 , keys = myKeys <> keys defaultConfig
         }

toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  [ ((modMask, xK_a), onPrevNeighbour W.view)
  , ((modMask, xK_o), onNextNeighbour W.view)
  , ((modMask .|. shiftMask, xK_a), onPrevNeighbour W.shift)
  , ((modMask .|. shiftMask, xK_o), onNextNeighbour W.shift)
  , ((modMask, xK_r), spawn "xmonad --restart")
  , ((modMask .|. shiftMask, xK_r), spawn "xmonad --recompile && xmonad --restart")
  , ((modMask, xK_p), shellPrompt def { position =  Top, height = 50 })
  ]
  ++
  [((modMask .|. mask, key), f sc)
    | (key, sc) <- zip [xK_q, xK_w, xK_e] [0..]
    , (f, mask) <- [(viewScreen, 0), (sendToScreen, shiftMask)]]
