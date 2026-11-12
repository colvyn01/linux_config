import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import QtQuick

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: "transparent"

    Theme { id: t }
    SystemClock { id: clock; precision: SystemClock.Seconds }
    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    property int cpu: 0
    property int mem: 0
    property real prevTotal: 0
    property real prevIdle: 0
    property var sink: Pipewire.defaultAudioSink
    property string volText: (sink && sink.audio) ? (sink.audio.muted ? "MUTED" : "VOL " + Math.round(sink.audio.volume * 100) + "%") : "VOL --"
    property string batText: "BAT " + Math.round(UPower.displayDevice.percentage * 100) + "%"

    function volumeDisplay() {
        if (!sink || !sink.audio) return "\uf026 --"
        var volume = Math.round(sink.audio.volume * 100)
        if (sink.audio.muted) return "\uf026 MUTE"
        var icon = volume === 0 ? "\uf026"
                 : volume < 50 ? "\uf027" : "\uf028"
        return icon + " " + volume + "%"
    }

    function powerProfileName() {
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "performance"
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "power-saver"
        return "balanced"
    }

    function batteryDisplay(hovered) {
        var battery = UPower.displayDevice
        if (!battery.ready) return "BAT --"

        var percent = Math.round(battery.percentage * 100)
        var icon = percent <= 10 ? "\uf244"
                 : percent <= 35 ? "\uf243"
                 : percent <= 60 ? "\uf242"
                 : percent <= 85 ? "\uf241" : "\uf240"

        var charging = battery.state === UPowerDeviceState.Charging ? "+" : ""
        var profileIcon = PowerProfiles.profile === PowerProfile.PowerSaver
                          ? "\uf06c"
                          : PowerProfiles.profile === PowerProfile.Performance
                          ? "\uf0e7" : "\uf24e"

        return icon + charging + " " + percent + "%  " + profileIcon
               + (hovered ? " " + powerProfileName() : "")
    }

    function stepPowerProfile(direction) {
        var profiles = [PowerProfile.PowerSaver, PowerProfile.Balanced]
        if (PowerProfiles.hasPerformanceProfile)
            profiles.push(PowerProfile.Performance)

        var current = profiles.indexOf(PowerProfiles.profile)
        if (current < 0) return
        var next = Math.max(0, Math.min(profiles.length - 1, current + direction))
        if (next !== current)
            PowerProfiles.profile = profiles[next]
    }

    property var player: {
        var list = Mpris.players.values
        for (var i = 0; i < list.length; i++) {
            if (list[i].isPlaying) return list[i]
        }
        return list.length > 0 ? list[0] : null
    }

    Process {
        id: stats
        command: ["sh", "-c", "grep -m1 '^cpu ' /proc/stat; awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%d\\n\", (t-a)*100/t}' /proc/meminfo"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("cpu")) {
                    var p = data.trim().split(/\s+/).slice(1).map(Number)
                    var idle = p[3] + p[4]
                    var total = p.reduce((a, b) => a + b, 0)
                    if (bar.prevTotal > 0 && total > bar.prevTotal)
                        bar.cpu = Math.round(100 * (1 - (idle - bar.prevIdle) / (total - bar.prevTotal)))
                    bar.prevTotal = total
                    bar.prevIdle = idle
                } else {
                    bar.mem = parseInt(data)
                }
            }
        }
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: stats.running = true }

    Rectangle {
        anchors.fill: parent
        color: t.bg

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 2
            color: t.border
        }

        Text {
            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
            text: "󰣇"
            color: t.accent
            font { family: "GeistMono Nerd Font"; pixelSize: 20 }
        }

        Rectangle {
            id: media
            visible: bar.player !== null && bar.player.trackTitle !== ""
            anchors.centerIn: parent
            height: 22
            radius: 11
            width: Math.min(mediaText.implicitWidth, 460) + 28
            color: Qt.rgba(t.accent.r, t.accent.g, t.accent.b, 0.18)
            border { color: t.accent; width: 1 }
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            Text {
                id: mediaText
                anchors.centerIn: parent
                width: Math.min(implicitWidth, 460)
                elide: Text.ElideRight
                maximumLineCount: 1
                color: t.fg
                font { family: "GeistMono Nerd Font"; pixelSize: 13 }
                text: bar.player ? ((bar.player.isPlaying ? "\u25B6  " : "\u275A\u275A  ") + bar.player.trackTitle + (bar.player.trackArtist !== "" ? " - " + bar.player.trackArtist : "")) : ""
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (!bar.player) return
                    if (mouse.button === Qt.RightButton) bar.player.next()
                    else bar.player.togglePlaying()
                }
            }
        }

        Row {
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            spacing: 18
            Repeater {
                model: 4

                Item {
                    id: statItem
                    required property int index
                    implicitWidth: statLabel.implicitWidth
                    implicitHeight: 24

                    Text {
                        id: statLabel
                        anchors.verticalCenter: parent.verticalCenter
                        color: statMouse.containsMouse && statItem.index >= 2
                               ? t.accent : t.fg
                        font { family: "GeistMono Nerd Font"; pixelSize: 14 }

                        text: {
                            if (statItem.index === 0)
                                return "CPU " + bar.cpu + "%"
                            if (statItem.index === 1)
                                return "RAM " + bar.mem + "%"
                            if (statItem.index === 2)
                                return bar.volumeDisplay()
                            return bar.batteryDisplay(statMouse.containsMouse)
                        }
                    }

                    MouseArea {
                        id: statMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        cursorShape: statItem.index >= 2
                                     ? Qt.PointingHandCursor : Qt.ArrowCursor

                        onClicked: {
                            if (statItem.index === 2 && bar.sink && bar.sink.audio)
                                bar.sink.audio.muted = !bar.sink.audio.muted
                        }

                        onWheel: wheel => {
                            if (statItem.index < 2 || wheel.angleDelta.y === 0) {
                                wheel.accepted = false
                                return
                            }

                            var direction = wheel.angleDelta.y > 0 ? 1 : -1
                            if (statItem.index === 2) {
                                if (bar.sink && bar.sink.audio) {
                                    bar.sink.audio.volume = Math.max(0, Math.min(
                                        1, bar.sink.audio.volume + direction * 0.05))
                                }
                            } else {
                                bar.stepPowerProfile(direction)
                            }
                            wheel.accepted = true
                        }
                    }
                }
            }
            Text {
                text: Qt.formatDateTime(clock.date, "MM/dd/yyyy  hh:mm:ss AP")
                color: t.accent
                font { family: "GeistMono Nerd Font"; pixelSize: 14 }
            }
        }
    }
}
