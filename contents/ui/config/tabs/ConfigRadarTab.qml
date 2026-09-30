/*
 * Copyright 2026  Petar Nedyalkov
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * ConfigRadarTab.qml - Radar tab content
 *
 * Extracted from configGeneral.qml for readability.
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: radarTab

    /** Reference to the root KCM (configGeneral) for cfg_* properties, functions and state */
    required property var configRoot

    // ═══════════════════════════════════════════════════════════════
    // SECTION: Radar
    // ═══════════════════════════════════════════════════════════════
    Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Radar Settings")
    }

    Item {
        Layout.preferredHeight: Kirigami.Units.smallSpacing
    }

    Switch {
        Kirigami.FormData.label: ""
        text: i18n("Show Radar tab in widget")
        checked: radarTab.configRoot.cfg_radarEnabled
        onToggled: radarTab.configRoot.cfg_radarEnabled = checked
    }

    Item {
        Layout.preferredHeight: Kirigami.Units.smallSpacing
    }

    Switch {
        Kirigami.FormData.label: ""
        visible: radarTab.configRoot.cfg_radarEnabled
        text: i18n("Workaround radar map crashes on hybrid-GPU systems (EXPERIMENTAL)")
        checked: radarTab.configRoot.cfg_radarGpuWorkaround
        onToggled: {
            radarTab.configRoot.cfg_radarGpuWorkaround = checked;
            radarTab.configRoot.radarGpuWorkaroundExec.apply(checked);
            // Re-check either way: turning it on shows whether it needs a
            // logout to become active, turning it off shows whether it's
            // still live for the rest of this session (see the "Off -"
            // message below) rather than just disappearing silently.
            radarTab.configRoot.radarGpuWorkaroundExec.checkStatus();
        }
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarGpuWorkaround
        showCloseButton: false
        type: Kirigami.MessageType.Warning
        text: i18n("<b>Hybrid-GPU / NVIDIA PRIME + Wayland crash workaround</b><br/><br/>" + "On some hybrid-GPU laptops running Wayland, the Radar tab's embedded browser view can crash the whole Plasma shell the moment it first paints, due to a driver-level conflict between the two GPUs. This option disables GPU-accelerated compositing inside that browser view to avoid it.<br/><br/>" + "Only enable this if you're actually experiencing that crash - it costs some rendering performance on the radar map.<br/><br/>" + `<b>This needs a log out and back in to take effect</b>, since it has to be set before Plasma starts. It also applies to the whole session, so any other app that embeds a Chromium-based browser view will pick up the same setting. Turning it back off later needs the same log out/in to fully clear it too.
        <br/><br/>` + "If you enable this option, the following file will be created in: ~/.config/plasma-workspace/env/advanced-weather-widget-radar-gpu-workaround.sh")
        actions: [
            Kirigami.Action {
                text: i18n("Log Out Now…")
                icon.name: "system-log-out"
                onTriggered: radarTab.configRoot.radarGpuWorkaroundExec.logout()
            }
        ]
    }

    RowLayout {
        Kirigami.FormData.label: ""
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarGpuWorkaround
        Layout.fillWidth: true

        Button {
            text: radarTab.configRoot.radarGpuTestState === 1 ? i18n("Checking…") : i18n("Check Status")
            icon.name: "view-refresh"
            enabled: radarTab.configRoot.radarGpuTestState !== 1
            onClicked: radarTab.configRoot.radarGpuWorkaroundExec.checkStatus()
        }
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.radarGpuTestState === 2
        type: Kirigami.MessageType.Positive
        text: radarTab.configRoot.radarGpuTestMessage
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.radarGpuTestState === 3
        type: Kirigami.MessageType.Warning
        text: radarTab.configRoot.radarGpuTestMessage
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.radarGpuTestState === 4
        type: Kirigami.MessageType.Error
        text: radarTab.configRoot.radarGpuTestMessage
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.radarGpuTestState === 5
        showCloseButton: true
        type: Kirigami.MessageType.Information
        text: radarTab.configRoot.radarGpuTestMessage
        actions: [
            Kirigami.Action {
                text: i18n("Log Out Now…")
                icon.name: "system-log-out"
                onTriggered: radarTab.configRoot.radarGpuWorkaroundExec.logout()
            }
        ]
    }

    Item {
        Layout.preferredHeight: Kirigami.Units.smallSpacing
    }

    ComboBox {
        id: radarProviderCombo
        Kirigami.FormData.label: i18n("Radar provider:")
        Layout.preferredWidth: 280
        visible: radarTab.configRoot.cfg_radarEnabled
        model: [
            {
                text: i18n("Rain Viewer"),
                value: "rainviewer"
            },
            {
                text: i18n("LibreWXR"),
                value: "librewxr"
            }
        ]
        textRole: "text"
        currentIndex: radarTab.configRoot.cfg_radarProvider === "librewxr" ? 1 : 0
        onActivated: radarTab.configRoot.cfg_radarProvider = model[currentIndex].value
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarProvider !== "librewxr"
        showCloseButton: true
        type: Kirigami.MessageType.Information
        text: i18n("Radar provider: <a href='https://www.rainviewer.com/'>Rain Viewer</a><br/><br/>" + "The widget uses the free RainViewer API, which provides the past 2 hours of weather radar data in 10-minute intervals. Radar forecast is not supported.<br/><br/>" + "Rain Viewer does not guarantee the availability of radar data. " + "They do not conclude contracts with owners of this data. " + "The reason is that the owners can ask them to remove their data from Rain Viewer, " + "change the format, or stop sharing the data. " + "They are trying to keep radar data for as long as possible, " + "but sometimes the owners just stop providing the images.")
        onLinkActivated: link => Qt.openUrlExternally(link)
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarProvider === "librewxr"
        showCloseButton: true
        type: Kirigami.MessageType.Information
        text: i18n("Radar provider: <a href='https://librewxr.net/'>LibreWXR</a><br/><br/>" + "LibreWXR is a free, open-source weather radar API. It combines real radar composites from NOAA, Canadian, and European sources with a global model fallback, and provides the past 2 hours of radar data plus a short nowcast. It also offers a free satellite (infrared) layer.<br/><br/>" + "Layer mode, radar color scheme, and motion arrows are selected directly in the Radar tab. The map follows your Plasma light/dark theme automatically.")
        onLinkActivated: link => Qt.openUrlExternally(link)
    }

    // LibreWXR is self-hostable, so let the user point the radar and the
    // alerts provider at their own instance instead of the public API.
    ColumnLayout {
        Kirigami.FormData.label: i18n("LibreWXR server:")
        Layout.fillWidth: true
        spacing: 8
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarProvider === "librewxr"

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("Leave this empty to use the public server. Set it to your own address if you run a self-hosted LibreWXR instance.")
        }
        TextField {
            id: librewxrUrlField
            Layout.fillWidth: true
            placeholderText: "https://api.librewxr.net"
            text: radarTab.configRoot.cfg_librewxrUrl
            selectByMouse: true
            onTextEdited: radarTab.configRoot.cfg_librewxrUrl = text
            onEditingFinished: radarTab.configRoot.cfg_librewxrUrl = text.trim()
        }
    }

    // The animated wind layer of the LibreWXR map. Its data comes from
    // Open-Meteo, not from the LibreWXR server. It redraws the map at
    // every frame, so the frame-rate budget is what the CPU cost
    // depends on; the rate rises with the wind speed inside the range.
    ColumnLayout {
        Kirigami.FormData.label: i18n("Wind animation:")
        Layout.fillWidth: true
        spacing: 8
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarProvider === "librewxr"

        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("The Radar tab can animate the wind as moving particles (switch it on there). The wind data comes from <a href='https://open-meteo.com/'>Open-Meteo</a>, independently of the LibreWXR server. This sets the frame rate: lower it on a slow computer, raise it if strong winds look jerky.")
            onLinkActivated: Qt.openUrlExternally(link)
        }
        ComboBox {
            id: windQualityCombo
            Layout.preferredWidth: 280
            model: [
                {
                    text: i18n("Economy (8 to 10 fps)"),
                    value: "economy"
                },
                {
                    text: i18n("Balanced (10 to 20 fps)"),
                    value: "balanced"
                },
                {
                    text: i18n("Smooth (12 to 30 fps)"),
                    value: "smooth"
                }
            ]
            textRole: "text"
            currentIndex: radarTab.configRoot.cfg_librewxrWindQuality === "economy" ? 0 : (radarTab.configRoot.cfg_librewxrWindQuality === "smooth" ? 2 : 1)
            onActivated: radarTab.configRoot.cfg_librewxrWindQuality = model[currentIndex].value
        }
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        showCloseButton: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarProvider !== "librewxr" && radarTab.configRoot.cfg_radarEnabled && (radarTab.configRoot.cfg_owApiKey || "").trim() === ""
        type: Kirigami.MessageType.Information
        text: i18n("To unlock additional map layers (Rain, Clouds, Temperature, Wind, Pressure): " + "disable Adaptive mode from the 'Provider' tab, select OpenWeatherMap as your weather provider, and enter your API key above. When you are ready, you can enable Adaptive mode again.")
    }

    Kirigami.InlineMessage {
        Kirigami.FormData.label: ""
        Layout.fillWidth: true
        showCloseButton: true
        visible: radarTab.configRoot.cfg_radarEnabled && radarTab.configRoot.cfg_radarProvider !== "librewxr" && radarTab.configRoot.cfg_radarEnabled && (radarTab.configRoot.cfg_owApiKey || "").trim() !== ""
        type: Kirigami.MessageType.Warning
        text: i18n("<b>Why OWM layers may not match RainViewer radar</b><br/><br/>" + "OWM precipitation/cloud layers are <b>static model tiles</b> - they show a smoothed NWP (Numerical Weather Prediction) output, not actual radar returns. " + "They represent where the model <i>thinks</i> it is raining based on interpolation between weather stations and model runs.<br/><br/>" + "RainViewer uses <b>real weather radar composites</b> from radar stations - actual measured reflectivity updated every 2-10 minutes. " + "This discrepancy is expected and known.")
    }
}
