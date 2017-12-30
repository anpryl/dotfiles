import           Control.Concurrent                       (forkIO, threadDelay)
import           Data.Char                                (isSpace)
import           Data.IORef
import           Data.List
import           Graphics.UI.Gtk
import           Sound.ALSA.Mixer
import           System.Information.Battery
import           System.Information.CPU
import           System.Information.CPU2                  (getCPUInfo)
import           System.Information.Memory
import           System.Information.Network               (getNetInfo)
import           System.Process
import           System.Taffybar
import           System.Taffybar.Battery
import           System.Taffybar.FreedesktopNotifications
import           System.Taffybar.NetMonitor
import           System.Taffybar.Pager
import           System.Taffybar.SimpleClock
import           System.Taffybar.Systray
import           System.Taffybar.TaffyPager
import           System.Taffybar.Widgets.PollingBar
import           System.Taffybar.Widgets.PollingGraph
import           System.Taffybar.Widgets.PollingLabel
import           Text.Printf

main = do
  defaultTaffybar defaultTaffybarConfig
    { startWidgets = [ pager, note ]
    , endWidgets =
      intercalate [separator]
        [ [tray]
        , [clock]
        , [volume]
        , [netDown, netDownText, netUp, netUpText]
        , [mem, memText, cpu, cpuText]
        , [battery]
        {- , [memP, cpuP] -}
        ]
    }
  where
    clock = textClockNew Nothing ("<span fgcolor='" ++ solarizedBlue ++ "'>%a %b %_d %H:%M</span>") 1
    note = notifyAreaNew defaultNotificationConfig
    cpu = textCPUNew ("…" ++ colorize solarizedBase01 "" "%") "cpu" 1
    cpuText = textWidgetNew "CPU:"
    battery = textBatteryNew ("$percentage$" ++ colorize solarizedBase01 "" "%") 5
    mem = textMemNew 1
    memText = textWidgetNew "MEM:"
    tray = systrayNew
    {- gmailc = shellWidgetNew "…" "gmailc" 5 -}
    volume = textVolumeNew "" "Master" 0.1
    netDown = downNetMonitorNew 1 "enp4s0"
    netDownText = textWidgetNew "D:"
    netUp = upNetMonitorNew 1 "enp4s0"
    netUpText = textWidgetNew "U:"
    separator = textWidgetNew "|"
    pager = taffyPagerNew defaultPagerConfig
      { activeWindow     = escape . shorten 200
      , activeLayout     = escape
      , activeWorkspace  = colorize solarizedBlue "" . wrap "[" "]" . escape
      , hiddenWorkspace  = escape
      , emptyWorkspace   = const ""
      , visibleWorkspace = wrap "(" ")" . escape
      , urgentWorkspace  = colorize solarizedRed solarizedYellow . escape
      , widgetSep        = " : "
      }

    memP = pollingGraphNew memCfg 1 memCallback
    cpuP = pollingGraphNew cpuCfg 0.5 cpuCallback
    memCfg = defaultGraphConfig
      { graphDataColors = [(1, 0, 0, 1)]
      , graphLabel = Just $ "mem"
      }
    cpuCfg = defaultGraphConfig
      { graphDataColors =
          [ (0, 1, 0, 1)
          , (1, 0, 1, 0.5)
          ]
      , graphLabel = Just $ "cpu"
      }

memCallback = do
  mi <- parseMeminfo
  return [memoryUsedRatio mi]

cpuCallback = do
  (userLoad, systemLoad, totalLoad) <- cpuLoad
  return [totalLoad, systemLoad]

labelStr :: String -> IO String -> IO String
labelStr label ioString = do
  str <- ioString
  return $ label ++ (rstrip str)

stripStr :: IO String -> IO String
stripStr ioString = do
  str <- ioString
  return $ rstrip $ str

rstrip = reverse . dropWhile isSpace . reverse

textWidgetNew :: String -> IO Widget
textWidgetNew str = do
  box <- hBoxNew False 0
  label <- labelNew $ Just str
  boxPackStart box label PackNatural 0
  widgetShowAll box
  return $ toWidget box

shellWidgetNew :: String -> String -> Double -> IO Widget
shellWidgetNew defaultStr cmd interval = do
  label <- pollingLabelNew defaultStr interval $ stripStr $ readProcess cmd [] []
  widgetShowAll label
  return $ toWidget label

-- CPU

textCPUNew :: String -> String -> Double -> IO Widget
textCPUNew defaultStr cpu interval = do
  label <- pollingLabelNew defaultStr interval $ cpuPct cpu interval
  widgetShowAll label
  return $ toWidget label

cpuPct :: String -> Double -> IO String
cpuPct cpu interval = do
  oldInfo <- getCPUInfo cpu
  threadDelay $ floor (interval * 1000000)
  newInfo <- getCPUInfo cpu
  return $ show (round $ fromIntegral ((cpuTotalDiff oldInfo newInfo) - (cpuIdleDiff oldInfo newInfo)) / fromIntegral (cpuTotalDiff oldInfo newInfo) * 100) ++ colorize solarizedBase01 "" "%"

cpuIdleDiff :: [Int] -> [Int] -> Int
cpuIdleDiff old new = new!!3 - old!!3

cpuTotalDiff :: [Int] -> [Int] -> Int
cpuTotalDiff old new = (sum $ take 8 new) - (sum $ take 8 old)

-- Memory

textMemNew :: Double -> IO Widget
textMemNew interval = do
  label <- pollingLabelNew "" interval memPct
  widgetShowAll label
  return $ toWidget label

memPct :: IO String
memPct = do
  mem <- parseMeminfo
  return $ show (round $ (memoryUsedRatio mem) * 100) ++ colorize solarizedBase01 "" "%"

-- Battery

batteryIconFunc :: BatteryContext -> String -> IO String
batteryIconFunc ctxt prefix = do
  ac <- batteryAC ctxt
  percentage <- batteryPercent ctxt
  case () of
    _ | ac == BatteryStateCharging -> return $ prefix ++ "ac_01.xpm"
      | percentage < 0.1 -> return $ prefix ++ "bat_empty_02.xpm"
      | percentage < 0.4 -> return $ prefix ++ "bat_low_02.xpm"
      | otherwise -> return $ prefix ++ "bat_full_02.xpm"

batteryPercent :: BatteryContext -> IO Double
batteryPercent ctxt = do
  Just info <- getBatteryInfo ctxt
  return (batteryPercentage info / 100)

batteryAC :: BatteryContext -> IO BatteryState
batteryAC ctxt = do
  Just info <- getBatteryInfo ctxt
  return $ batteryState info


-- Volume

textVolumeNew :: String -> String -> Double -> IO Widget
textVolumeNew defaultStr name interval = do
  label <- pollingLabelNew defaultStr interval $ getVolume name
  widgetShowAll label
  return $ toWidget label

getVolume :: String -> IO String
getVolume name = withMixer "default" $ \mixer -> do
    Just control <- getControlByName mixer name
    let Just playbackVolume = playback $ volume control
    let Just playbackMute = playback $ switch control
    (_, max) <- getRange playbackVolume
    Just vol <- getChannel FrontLeft $ value $ playbackVolume
    Just mute <- getChannel FrontLeft playbackMute
    if mute == False then return $ colorize solarizedRed "" "Mute"
                     else return $ ("Vol:" ++ show (round $ (fromIntegral vol / fromIntegral max) * 100)) ++ "%"

-- Net

downNetMonitorNew :: Double -> String -> IO Widget
downNetMonitorNew interval interface = do
  sample <- newIORef 0
  label <- pollingLabelNew "" interval $ getNetDown sample interval interface
  widgetShowAll label
  return $ toWidget label

upNetMonitorNew :: Double -> String -> IO Widget
upNetMonitorNew interval interface = do
  sample <- newIORef 0
  label <- pollingLabelNew "" interval $ getNetUp sample interval interface
  widgetShowAll label
  return $ toWidget label

getNetDown :: IORef Integer -> Double -> String -> IO String
getNetDown sample interval interface = do
  Just [new, _] <- getNetInfo interface
  old <- readIORef sample
  writeIORef sample new
  let delta = new - old
      incoming = fromIntegral delta/(interval*1e3)
  if old == 0 then return $ "…………" ++ colorize solarizedBase01 "" "KB/s"
  else return $ (take 4 $ printf "%.2f" incoming) ++ colorize solarizedBase01 "" "KB/s"

getNetUp :: IORef Integer -> Double -> String -> IO String
getNetUp sample interval interface = do
  Just [_, new] <- getNetInfo interface
  old <- readIORef sample
  writeIORef sample new
  let delta = new - old
      outgoing = fromIntegral delta/(interval*1e3)
  if old == 0 then return $ "…………" ++ colorize solarizedBase01 "" "KB/s"
  else return $ (take 4 $ printf "%.2f" outgoing) ++ colorize solarizedBase01 "" "KB/s"


solarizedBase03  = "#002b36"
solarizedBase02  = "#073642"
solarizedBase01  = "#586e75"
solarizedBase00  = "#657b83"
solarizedBase0   = "#839496"
solarizedBase1   = "#93a1a1"
solarizedBase2   = "#eee8d5"
solarizedBase3   = "#fdf6e3"
solarizedYellow  = "#b58900"
solarizedOrange  = "#cb4b16"
solarizedRed     = "#dc322f"
solarizedMagenta = "#d33682"
solarizedViolet  = "#6c71c4"
solarizedBlue    = "#268bd2"
solarizedCyan    = "#2aa198"
solarizedGreen   = "#859900"
