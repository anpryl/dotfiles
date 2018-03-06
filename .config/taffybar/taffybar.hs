import           Control.Concurrent                       (forkIO, threadDelay)
import           Control.Monad.Trans                      (MonadIO, liftIO)
import           Data.Char                                (isSpace)
import           Data.IORef
import           Data.List
import qualified Data.Text                                as T
import           Debug.Trace
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
import           System.Taffybar.Widgets.Util
import           Text.Printf

main = do
    ctx <- batteryContextNew
    defaultTaffybar
        defaultTaffybarConfig
        { barHeight = 24
        , barPosition = Top
        , startWidgets = [pager, note]
        , endWidgets =
              intercalate
                  [separator]
                  [ [tray]
                  , [clock]
        {- , [shellWidgetNew "…" "xkblayout-state print %s" 1] -}
                  , batteries ctx
                  , [volume]
                  , [brightness]
        {- , batteries ctx -}
        {- , [batteryAcpi] -}
        {- , [mem, memText, cpu, cpuText] -}
                  , [memP, cpuP]
        {- , [netUp, netUpText, netDown, netDownText] -}
                  ]
        }
  where
    clock =
        textClockNew Nothing ("<span fgcolor='" ++ solarizedBlue ++ "'>%a %b %_d %H:%M</span>") 1
    batteries (Just bctx) = [batteryBarWidget, batteryCharging bctx]
    batteries Nothing     = [batteryBarWidget]
    tray = systrayNew
    volume = textVolumeNew "" "Master" 0.1
    netDown = downNetMonitorNew 1 "wlp3s0"
    netUp = upNetMonitorNew 1 "wlp3s0"
    netDownText = textWidgetNew "D:"
    netUpText = textWidgetNew "U:"
    separator = textWidgetNew "|"
    memP = pollingGraphNew memCfg 0.5 memCallback
    cpuP = pollingGraphNew cpuCfg 0.5 cpuCallback
    {- batteryAcpi = shellWidgetNew "…" "acpi" 1 -}
    {- batteryStatus batteryContext = pollingLabelNew "…" 1 $ batteryStatusFunc batteryContext -}
    {- battery = textBatteryNew ("$percentage$" ++ colorize solarizedBase01 "" "%") 5 -}
    {- cpu = textCPUNew ("…" ++ colorize solarizedBase01 "" "%") "cpu" 1 -}
    {- cpuText = textWidgetNew "CPU:" -}
    {- mem = textMemNew 1 -}
    {- memText = textWidgetNew "MEM:" -}
    {- gmailc = shellWidgetNew "…" "gmailc" 5 -}
    withAlpha (r, g, b) a = (r, g, b, a)
    memCfg =
        defaultGraphConfig
        {graphDataColors = [withAlpha (rgbToDouble solarizedGreenRGB) 1], graphLabel = Just $ "MEM"}
    cpuCfg =
        defaultGraphConfig
        { graphDataColors = [withAlpha (rgbToDouble solarizedOrangeRGB) 1]
        , graphLabel = Just $ "CPU"
        }

note =
    notifyAreaNew
        defaultNotificationConfig
        { notificationMaxTimeout = 5
        , notificationMaxLength = 120
        , notificationFormatter = notifyFormatter
        }

notifyFormatter :: Notification -> String
notifyFormatter note = msg
  where
    msg =
        case T.null (noteBody note) of
            True  -> T.unpack $ withNote [noteSummary note]
            False -> T.unpack $ withNote [noteSummary note, T.pack ": ", noteBody note]
    withNote vs =
        mconcat $ [T.pack $ "<span fgcolor='" ++ solarizedYellow ++ "'>Note:</span>"] ++ vs

pager :: IO Widget
pager =
    taffyPagerNew
        defaultPagerConfig
  {- { activeWindow     = const "" -}
        { activeWindow = escape . shorten 20
  {- { activeWindow     = escape -}
        , activeLayout = escape
        , activeWorkspace = colorize solarizedBlue "" . wrap "[" "]" . escape
        , hiddenWorkspace = escape
        , emptyWorkspace = const ""
        , visibleWorkspace = wrap "(" ")" . escape
        , urgentWorkspace = colorize solarizedRed solarizedYellow . escape
        , widgetSep = " | "
        }

memCallback :: IO [Double]
memCallback = do
    mi <- parseMeminfo
    pure [memoryUsedRatio mi]

cpuCallback :: IO [Double]
cpuCallback = do
    (userLoad, systemLoad, totalLoad) <- cpuLoad
    pure [totalLoad]

labelStr :: String -> IO String -> IO String
labelStr label ioString = do
    str <- ioString
    pure $ label ++ (rstrip str)

stripStr :: IO String -> IO String
stripStr ioString = do
    str <- ioString
    pure $ rstrip $ str

rstrip :: String -> String
rstrip = reverse . dropWhile isSpace . reverse

textWidgetNew :: String -> IO Widget
textWidgetNew str = do
    box <- hBoxNew False 0
    label <- labelNew $ Just str
    boxPackStart box label PackNatural 0
    widgetShowAll box
    pure $ toWidget box

shellWidgetNew :: String -> String -> Double -> IO Widget
shellWidgetNew defaultStr cmd interval = do
    label <- pollingLabelNew defaultStr interval $ stripStr $ readProcess cmd [] []
    widgetShowAll label
    pure $ toWidget label

-- CPU
textCPUNew :: String -> String -> Double -> IO Widget
textCPUNew defaultStr cpu interval = do
    label <- pollingLabelNew defaultStr interval $ cpuPct cpu interval
    widgetShowAll label
    pure $ toWidget label

cpuPct :: String -> Double -> IO String
cpuPct cpu interval = do
    oldInfo <- getCPUInfo cpu
    threadDelay $ floor (interval * 1000000)
    newInfo <- getCPUInfo cpu
    pure $
        show
            (round $
             fromIntegral ((cpuTotalDiff oldInfo newInfo) - (cpuIdleDiff oldInfo newInfo)) /
             fromIntegral (cpuTotalDiff oldInfo newInfo) *
             100) ++
        colorize solarizedBase01 "" "%"

cpuIdleDiff :: [Int] -> [Int] -> Int
cpuIdleDiff old new = new !! 3 - old !! 3

cpuTotalDiff :: [Int] -> [Int] -> Int
cpuTotalDiff old new = (sum $ take 8 new) - (sum $ take 8 old)

-- Brightness
brightness :: IO Widget
brightness = do
    max <- maxBrightness
    label <-
        pollingLabelNew "" 0.1 $ do
            current <- currentBrightness
            pure $ ("B:" ++) . (++ "%") . show . ceiling $ 100 * current / max
    widgetShowAll label
    pure $ toWidget label

maxBrightness :: IO Double
maxBrightness = read <$> readFile "/sys/class/backlight/intel_backlight/max_brightness"

currentBrightness :: IO Double
currentBrightness = read <$> readFile "/sys/class/backlight/intel_backlight/brightness"

-- Memory
textMemNew :: Double -> IO Widget
textMemNew interval = do
    label <- pollingLabelNew "" interval memPct
    widgetShowAll label
    pure $ toWidget label

memPct :: IO String
memPct = do
    mem <- parseMeminfo
    pure $ show (round $ (memoryUsedRatio mem) * 100) ++ colorize solarizedBase01 "" "%"

-- Battery
batteryCharging :: BatteryContext -> IO Widget
batteryCharging bctx = do
    label <- pollingLabelNew "" 10 $ batteryChargingFunc bctx
    widgetShowAll label
    pure $ toWidget label

batteryChargingFunc :: BatteryContext -> IO String
batteryChargingFunc bctx = do
    ac <- batteryAC bctx
    case ac of
        BatteryStateCharging     -> pure "C"
        BatteryStateFullyCharged -> pure "F"
        _                        -> pure "D"

batteryBarWidget :: IO Widget
batteryBarWidget = do
    bar <- batteryBarNew batteryBarConfig 1
    ebox <- eventBoxNew
    containerAdd ebox bar
    eventBoxSetVisibleWindow ebox False
    bat <- makeBattery
    _ <- on ebox buttonPressEvent $ onClick [SingleClick] (toggleWindow bar bat)
    widgetShowAll ebox
    pure (toWidget ebox)

batteryBarConfig :: BarConfig
batteryBarConfig = defaultBarConfig colorFunc
  where
    colorFunc pct
        | pct < 0.1 = rgbToDouble solarizedRedRGB
        | pct < 0.9 = rgbToDouble solarizedBlueRGB
        | otherwise = rgbToDouble solarizedGreenRGB

makeBattery :: IO Window
makeBattery = do
    w <- windowNew
    label <- labelNew (Nothing :: Maybe String)
    labelSetMarkup label "Battery info"
    containerAdd w $ toWidget label
    _ <-
        onShow w $
        liftIO $ do
            batteryInfo <- stripStr $ readProcess "acpi" [] []
            labelSetMarkup label batteryInfo
    pure w

toggleWindow :: WidgetClass w => w -> Window -> IO Bool
toggleWindow w c = do
    isVis <- get c widgetVisible
    if isVis
        then widgetHideAll c
        else do
            attachPopup w "Battery info" c
            displayPopup w c
    pure True

batteryPercent :: BatteryContext -> IO Double
batteryPercent ctxt = do
    Just info <- getBatteryInfo ctxt
    pure (batteryPercentage info / 100)

batteryAC :: BatteryContext -> IO BatteryState
batteryAC ctxt = do
    Just info <- getBatteryInfo ctxt
    pure $ batteryState info

-- Volume
textVolumeNew :: String -> String -> Double -> IO Widget
textVolumeNew defaultStr name interval = do
    label <- pollingLabelNew defaultStr interval $ getVolume name
    widgetShowAll label
    pure $ toWidget label

getVolume :: String -> IO String
getVolume name =
    withMixer "default" $ \mixer -> do
        Just control <- getControlByName mixer name
        let Just playbackVolume = playback $ volume control
        let Just playbackMute = playback $ switch control
        (_, max) <- getRange playbackVolume
        Just vol <- getChannel FrontLeft $ value $ playbackVolume
        Just mute <- getChannel FrontLeft playbackMute
        if mute == False
            then pure $ colorize solarizedRed "" "Mute"
            else pure $ ("V:" ++ show (round $ (fromIntegral vol / fromIntegral max) * 100)) ++ "%"

-- Net
downNetMonitorNew :: Double -> String -> IO Widget
downNetMonitorNew interval interface = do
    sample <- newIORef 0
    label <- pollingLabelNew "" interval $ getNetDown sample interval interface
    widgetShowAll label
    pure $ toWidget label

upNetMonitorNew :: Double -> String -> IO Widget
upNetMonitorNew interval interface = do
    sample <- newIORef 0
    label <- pollingLabelNew "" interval $ getNetUp sample interval interface
    widgetShowAll label
    pure $ toWidget label

getNetDown :: IORef Integer -> Double -> String -> IO String
getNetDown sample interval interface = do
    Just [new, _] <- getNetInfo interface
    old <- readIORef sample
    writeIORef sample new
    let delta = new - old
        incoming = fromIntegral delta / (interval * 1e3)
    if old == 0
        then pure $ "…………" ++ colorize solarizedBase01 "" "KB/s"
        else pure $ (take 4 $ printf "%.2f" incoming) ++ colorize solarizedBase01 "" "KB/s"

getNetUp :: IORef Integer -> Double -> String -> IO String
getNetUp sample interval interface = do
    Just [_, new] <- getNetInfo interface
    old <- readIORef sample
    writeIORef sample new
    let delta = new - old
        outgoing = fromIntegral delta / (interval * 1e3)
    if old == 0
        then pure $ "…………" ++ colorize solarizedBase01 "" "KB/s"
        else pure $ (take 4 $ printf "%.2f" outgoing) ++ colorize solarizedBase01 "" "KB/s"

rgbToDouble :: (Double, Double, Double) -> (Double, Double, Double)
rgbToDouble (r, g, b) = (color r, color g, color b)
  where
    color = (/ 255)

solarizedBase03RGB = (0, 43, 54)

solarizedBase02RGB = (7, 54, 66)

solarizedBase01RGB = (88, 110, 117)

solarizedBase00RGB = (101, 123, 131)

solarizedBase0RGB = (131, 148, 150)

solarizedBase1RGB = (147, 161, 161)

solarizedBase2RGB = (238, 232, 213)

solarizedBase3RGB = (253, 246, 227)

solarizedYellowRGB = (181, 137, 0)

solarizedOrangeRGB = (203, 75, 22)

solarizedRedRGB = (220, 50, 47)

solarizedMagentaRGB = (211, 54, 130)

solarizedVioletRGB = (108, 113, 196)

solarizedBlueRGB = (38, 139, 210)

solarizedCyanRGB = (42, 161, 152)

solarizedGreenRGB = (133, 153, 0)

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
