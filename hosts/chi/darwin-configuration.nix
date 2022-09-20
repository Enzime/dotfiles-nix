{ ... }:

{
  # WORKAROUND: Screensaver starts on the login screen and cannot be closed from VNC
  system.activationScripts.extraActivation.text = ''
    defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0
  '';
}
