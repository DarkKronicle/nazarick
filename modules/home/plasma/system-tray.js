// Subtitutes from Nix. 
// Credit https://github.com/Faupi/nixos-configs/blob/7097bdc0d7a2b960b55bbf5ed0b12ca04b147392/home-manager/cfgs/shared/kde-plasma/system-tray.js
// Note from Dark: SUPER COOL!!!
var getSubstitute = (text) => (text.match(/^@.*@$/) ? null : text); // Keep var so it can be redeclared if snippet gets used multiple times
hiddenItems = getSubstitute("@hiddenItems@");
shownItems = getSubstitute("@shownItems@");
extraItems = getSubstitute("@extraItems@");
knownItems = getSubstitute("@extraItems@");
scaleIconsToFit = getSubstitute("@scaleIconsToFit@");
iconSpacing = getSubstitute("@iconSpacing@");
popupWidth = getSubstitute("@popupWidth@");
popupHeight = getSubstitute("@popupHeight@");

// Find system tray config link in the panel, add the rules to it
panel.widgetIds.forEach((appletWidget) => {
  appletWidget = panel.widgetById(appletWidget);

  if (appletWidget.type === "org.kde.plasma.systemtray") {
    systemtrayId = appletWidget.readConfig("SystrayContainmentId");
    if (systemtrayId) {
      const systray = desktopById(systemtrayId);
      systray.currentConfigGroup = ["General"];
      if (hiddenItems != null)
        systray.writeConfig("hiddenItems", hiddenItems.split(","));
      if (shownItems != null)
        systray.writeConfig("shownItems", shownItems.split(","));
      if (extraItems != null)
        systray.writeConfig("extraItems", extraItems.split(","));
      if (knownItems != null)
        systray.writeConfig("knownItems", knownItems.split(","));
      if (scaleIconsToFit != null)
        systray.writeConfig("scaleIconsToFit", scaleIconsToFit === "true");
      if (iconSpacing != null)
        systray.writeConfig("iconSpacing", iconSpacing);
      systray.currentConfigGroup = [];
      if (popupWidth != null)
        systray.writeConfig("popupWidth", popupWidth);
      if (popupHeight != null)
        systray.writeConfig("popupHeight", popupHeight);
      systray.reloadConfig();
    }
  }
});
