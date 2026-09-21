import QtQuick
import QtQuick.Controls

// Password input styled after the caelestia lock screen (modules/lock/
// center/InputField.qml): no box, floating placeholder, one animated dot
// per character. Plain-QML stand-in for caelestia's M3Shapes char list.
TextField {
    id: field

    property color accent: "white"
    property string hint: "Enter your password"

    echoMode: TextInput.Password
    horizontalAlignment: Text.AlignHCenter
    font.pixelSize: 18
    color: "transparent"
    selectByMouse: false
    background: null

    Row {
        anchors.centerIn: parent
        spacing: 9

        Repeater {
            model: field.text.length

            Rectangle {
                id: dot

                width: 13
                height: 13
                radius: 6.5
                color: field.accent
                opacity: 0
                scale: 0

                ParallelAnimation {
                    running: true

                    NumberAnimation {
                        target: dot
                        property: "opacity"
                        to: 1
                        duration: 150
                    }
                    NumberAnimation {
                        target: dot
                        property: "scale"
                        to: 1
                        duration: 250
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: field.hint
        color: "gray"
        font.pixelSize: 16
        font.family: field.font.family
        opacity: field.text ? 0 : 0.55

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }
}
