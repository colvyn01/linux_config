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
                model: ["CPU " + bar.cpu + "%", "RAM " + bar.mem + "%", bar.volText, bar.batText]
                Text {
                    text: modelData
                    color: t.fg
                    font { family: "GeistMono Nerd Font"; pixelSize: 14 }
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
