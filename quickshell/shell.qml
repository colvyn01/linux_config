import Quickshell
import QtQuick

PanelWindow {
    anchors { top: true; left: true; right: true }
    implicitHeight: 30
    color: "transparent"

    Theme { id: t }
    SystemClock { id: clock; precision: SystemClock.Minutes }

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
        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "ddd MMM d   hh:mm AP")
            color: t.fg
            font { family: "GeistMono Nerd Font"; pixelSize: 14 }
        }
    }
}
