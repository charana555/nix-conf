// macOS-style replacement for caelestia's notification banner.
// Anatomy matches a macOS banner: rounded-square app icon top-left, bold
// title + body to its right, "now" timestamp and a hover close button
// top-right, neutral pill buttons for actions.
// Replaces modules/notifications/Notification.qml via postPatch; the
// interface consumed by Content.qml (modelData, nonAnimHeight, radius,
// implicitWidth from parent, slide-in x) is preserved.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.Notifications
import Caelestia.Components
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.utils

StyledRect {
    id: root

    required property NotifData modelData
    readonly property bool hasImage: modelData.image.length > 0
    readonly property bool hasAppIcon: modelData.appIcon.length > 0
    readonly property int bodyTextFormat: /[<*_`#\[\]]/.test(modelData.body) ? Text.MarkdownText : Text.PlainText
    readonly property int nonAnimHeight: summary.implicitHeight
        + (modelData.body.length > 0 ? Tokens.spacing.extraSmall + body.height : 0)
        + (modelData.actions.length > 0 ? Tokens.spacing.small + actions.implicitHeight : 0)
        + inner.anchors.margins * 2
    property bool expanded: Config.notifs.openExpanded

    color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.tPalette.m3secondaryContainer : Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.large

    implicitHeight: inner.implicitHeight

    x: implicitWidth
    Component.onCompleted: {
        x = 0;
        modelData.lock(this);
    }
    Component.onDestruction: modelData.unlock(this)

    Behavior on x {
        Anim {
            easing: Tokens.anim.emphasizedDecel
        }
    }

    MouseArea {
        id: mouseArea

        property int startY

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.expanded && body.hoveredLink ? Qt.PointingHandCursor : pressed ? Qt.ClosedHandCursor : undefined
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        onEntered: root.modelData.timer.stop()
        onExited: {
            if (!pressed)
                root.modelData.timer.start();
        }

        drag.target: parent
        drag.axis: Drag.XAxis

        onPressed: event => {
            root.modelData.timer.stop();
            startY = event.y;
            if (event.button === Qt.MiddleButton)
                root.modelData.close();
        }
        onReleased: event => {
            if (!containsMouse)
                root.modelData.timer.start();

            if (Math.abs(root.x) < root.implicitWidth * Config.notifs.clearThreshold)
                root.x = 0;
            else
                root.modelData.popup = false;
        }
        onPositionChanged: event => {
            if (pressed) {
                const diffY = event.y - startY;
                if (Math.abs(diffY) > Config.notifs.expandThreshold)
                    root.expanded = diffY > 0;
            }
        }
        onClicked: event => {
            if (event.button !== Qt.LeftButton)
                return;

            if (GlobalConfig.notifs.actionOnClick) {
                const actions = root.modelData.actions;
                if (actions.length === 1)
                    actions[0].invoke();
            } else {
                root.expanded = !root.expanded;
            }
        }

        Item {
            id: inner

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Tokens.padding.medium

            implicitHeight: root.nonAnimHeight

            Behavior on implicitHeight {
                Anim {}
            }

            Loader {
                id: image

                asynchronous: true
                active: root.hasImage

                anchors.left: parent.left
                anchors.top: parent.top
                width: TokenConfig.sizes.notifs.image
                height: TokenConfig.sizes.notifs.image
                visible: root.hasImage || root.hasAppIcon

                sourceComponent: StyledClippingRect {
                    // macOS app icons are rounded squares, not circles
                    radius: Tokens.rounding.small
                    color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 2) : Colours.palette.m3secondaryContainer
                    implicitWidth: TokenConfig.sizes.notifs.image
                    implicitHeight: TokenConfig.sizes.notifs.image

                    Image {
                        anchors.fill: parent
                        source: Qt.resolvedUrl(root.modelData.image)
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: {
                            const size = TokenConfig.sizes.notifs.image * ((QsWindow.window as QsWindow)?.devicePixelRatio ?? 1);
                            return Qt.size(size, size);
                        }
                        cache: false
                        asynchronous: true
                    }
                }
            }

            Loader {
                id: appIcon

                asynchronous: true
                active: root.hasAppIcon || !root.hasImage

                anchors.horizontalCenter: root.hasImage ? undefined : image.horizontalCenter
                anchors.verticalCenter: root.hasImage ? undefined : image.verticalCenter
                anchors.right: root.hasImage ? image.right : undefined
                anchors.bottom: root.hasImage ? image.bottom : undefined

                sourceComponent: StyledRect {
                    radius: Tokens.rounding.small
                    color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3error : root.modelData.urgency === NotificationUrgency.Low ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 2) : Colours.palette.m3secondaryContainer
                    implicitWidth: root.hasImage ? Tokens.sizes.notifs.badge : TokenConfig.sizes.notifs.image
                    implicitHeight: root.hasImage ? Tokens.sizes.notifs.badge : TokenConfig.sizes.notifs.image

                    Loader {
                        id: icon

                        asynchronous: true
                        active: root.hasAppIcon

                        anchors.centerIn: parent

                        width: Math.round(parent.width * 0.6)
                        height: Math.round(parent.width * 0.6)

                        sourceComponent: ColouredIcon {
                            anchors.fill: parent
                            source: Quickshell.iconPath(root.modelData.appIcon)
                            colour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onSecondaryContainer
                            layer.enabled: root.modelData.appIcon.endsWith("symbolic")
                        }
                    }

                    Loader {
                        asynchronous: true
                        active: !root.hasAppIcon
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 1

                        sourceComponent: MaterialIcon {
                            text: Icons.getNotifIcon(root.modelData.summary, root.modelData.urgency)
                            color: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onError : root.modelData.urgency === NotificationUrgency.Low ? Colours.palette.m3onSurface : Colours.palette.m3onSecondaryContainer
                            fontStyle: Tokens.font.icon.medium
                        }
                    }
                }
            }

            Shape {
                id: progressIndicator

                anchors.centerIn: appIcon
                width: appIcon.implicitWidth + progressShape.strokeWidth * 2
                height: appIcon.implicitHeight + progressShape.strokeWidth * 2
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    id: progressShape

                    capStyle: ShapePath.RoundCap
                    fillColor: "transparent"
                    strokeWidth: 2
                    strokeColor: Colours.palette.m3primary

                    PathAngleArc {
                        id: progressArc

                        radiusX: progressIndicator.width / 2 - root.Tokens.padding.extraSmall / 2
                        centerX: progressIndicator.width / 2
                        radiusY: progressIndicator.height / 2 - root.Tokens.padding.extraSmall / 2
                        centerY: progressIndicator.height / 2

                        startAngle: -90
                        sweepAngle: ((root.modelData.hints.value ?? 0) / 100) * 360

                        Behavior on sweepAngle {
                            Anim {
                                easing: Tokens.anim.emphasizedDecel
                            }
                        }
                    }
                }
            }

            StyledText {
                id: time

                anchors.top: parent.top
                anchors.right: parent.right

                animate: true
                text: root.modelData.timeStr
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.label.small
            }

            // Close button, revealed on hover like a macOS banner
            Item {
                id: closeBtn

                anchors.right: time.left
                anchors.top: parent.top
                anchors.topMargin: -Tokens.padding.extraSmall

                implicitWidth: closeIcon.implicitHeight
                implicitHeight: closeIcon.implicitHeight
                opacity: mouseArea.containsMouse ? 1 : 0
                enabled: mouseArea.containsMouse

                StateLayer {
                    radius: Tokens.rounding.full
                    color: Colours.palette.m3onSurface
                    onClicked: root.modelData.close()
                }

                MaterialIcon {
                    id: closeIcon

                    anchors.centerIn: parent
                    text: "close"
                    color: Colours.palette.m3onSurfaceVariant
                    fontStyle: Tokens.font.icon.medium
                }

                Behavior on opacity {
                    Anim {
                        type: Anim.DefaultEffects
                    }
                }
            }

            StyledText {
                id: summary

                anchors.top: parent.top
                anchors.left: image.right
                anchors.leftMargin: Tokens.spacing.medium
                anchors.right: closeBtn.left
                anchors.rightMargin: Tokens.spacing.small

                animate: true
                text: root.modelData.summary
                elide: Text.ElideRight
                maximumLineCount: 1
                height: implicitHeight
                color: Colours.palette.m3onSurface
                font: Tokens.font.title.small
            }

            StyledText {
                id: body

                anchors.left: summary.left
                anchors.right: parent.right
                anchors.top: summary.bottom
                anchors.topMargin: root.modelData.body.length > 0 ? Tokens.spacing.extraSmall : 0

                animate: true
                textFormat: root.bodyTextFormat
                text: root.modelData.body
                color: Colours.palette.m3onSurfaceVariant
                font: Tokens.font.body.medium
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: root.expanded ? 99999 : 3
                height: text ? implicitHeight : 0

                onLinkActivated: link => {
                    if (!root.expanded)
                        return;

                    Qt.openUrlExternally(link);
                    root.modelData.popup = false;
                }
            }

            ButtonRow {
                id: actions

                anchors.left: summary.left
                anchors.right: parent.right
                anchors.top: body.bottom
                anchors.topMargin: Tokens.spacing.small

                spacing: Tokens.spacing.extraSmall

                Repeater {
                    model: root.modelData.actions

                    TextButton {
                        required property var modelData

                        isRound: true
                        shapeMorph: true
                        fillWidth: true
                        inactiveColour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3secondary : Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
                        inactiveOnColour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onSecondary : Colours.palette.m3onSurfaceVariant
                        text: modelData.text
                        font: Tokens.font.body.medium
                        onClicked: modelData.invoke()

                        label.horizontalAlignment: Text.AlignHCenter
                        label.anchors.left: left
                        label.anchors.right: right
                        label.anchors.verticalCenter: verticalCenter
                        label.anchors.centerIn: undefined
                        label.anchors.margins: Tokens.padding.medium
                        label.elide: Text.ElideRight
                    }
                }

                IconButton {
                    isRound: true
                    shapeMorph: true
                    visible: root.expanded
                    inactiveColour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3secondary : Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
                    inactiveOnColour: root.modelData.urgency === NotificationUrgency.Critical ? Colours.palette.m3onSecondary : Colours.palette.m3onSurfaceVariant
                    icon: copyTimer.running ? "inventory" : "content_copy"
                    padding: Tokens.padding.extraSmall
                    onClicked: {
                        Quickshell.clipboardText = root.modelData.body;
                        copyTimer.restart();
                    }

                    Timer {
                        id: copyTimer

                        interval: 3000
                    }
                }
            }
        }
    }
}
