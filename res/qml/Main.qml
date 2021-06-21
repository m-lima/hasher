import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 2.12
import QtQuick.Controls.Fusion 2.12

ApplicationWindow {
    title: 'Hasher'
    visible: true

    width: 400
    height: 400

    palette.window: '#353535'
    palette.windowText: '#cccccc'
    palette.base: '#252525'
    palette.alternateBase: '#353535'
    palette.text: '#cccccc'
    palette.button: '#353535'
    palette.buttonText: '#aaaaaa'
    palette.highlight: 'green'
    palette.highlightedText: '#cccccc'

    Column {
        property Item current: null

        id: content
        y: current ? 0 : (parent.height - next.height) / 2 - (implicitHeight / 2)

        width: parent.width

        // TODO: Avoid initial movement
        // TODO: Avoid lag when resizing window
        Behavior on y {
            NumberAnimation {
                duration: 200
            }
        }

        function toggleExpanded(expanded) {
            if (content.current)
                content.current.expanded = false
            content.current = expanded
        }

        CollapsibleItem {
            id: format
            title: qsTr('Format')
            expanded: parent.current === this
            onClicked: parent.current = this
            innerSpacing: 10

            ComboBox {
                id: formatTemplates
                width: parent.width
                textRole: 'name'
                valueRole: 'length'

                model: ListModel {
                    ListElement {
                        name: qsTr('Custom')
                        prefix: null
                        length: null
                    }
                    ListElement {
                        name: qsTr('TP')
                        prefix: '932'
                        length: 12
                    }
                }
            }

            TextField {
                id: prefix
                width: parent.width
                placeholderText: qsTr('Prefix')
                maximumLength: 25
                // TODO: Get a validator
            }

            RowLayout {
                width: parent.width

                Text {
                    text: qsTr('Length:')
                    color: palette.buttonText
                }

                SpinBox {
                    value: 12
                    from: Math.max(prefix.text.length, 3)
                    to: 25
                    Layout.fillWidth: true
                }
            }
        }

        CollapsibleItem {
            // TODO: Add OPET
            title: qsTr('Salt')
            expanded: parent.current === this
            onClicked: parent.current = this

            Switch {
                id: saltCustom
                text: qsTr('Custom')
                checked: false
                onCheckedChanged: saltCustom.checked && saltValue.forceActiveFocus()
            }

            TextField {
                id: saltValue
                width: parent.width
                enabled: saltCustom.checked
                placeholderText: qsTr('Salt')
                opacity: saltCustom.checked ? 1 : 0.5
            }
        }

        CollapsibleItem {
            title: qsTr('Algorithm')
            expanded: parent.current === this
            onClicked: parent.current = this

            Radio {
                text: qsTr('Sha256')
                checked: true
            }
            Radio {
                text: qsTr('Md5')
            }
        }

        CollapsibleItem {
            title: qsTr('Device')
            showLine: false
            expanded: parent.current === this
            onClicked: parent.current = this

            Switch {
                id: deviceCustom
                text: qsTr('Automatic')
                checked: true
            }
            Radio {
                text: qsTr('GPU')
                enabled: !deviceCustom.checked
                checked: true
                paintDisabled: false
            }
            Radio {
                text: qsTr('CPU')
                enabled: !deviceCustom.checked
                paintDisabled: false
            }
        }
    }

    Button {
        id: next
        height: 50
        y: parent.height - height
        width: parent.width

        contentItem: Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr('Next')
            font.bold: true
            font.pointSize: 18
            color: palette.base
        }

        background: Rectangle {
            anchors.fill: parent
            color: parent.down ? palette.highlight.lighter(1.2) : parent.hovered ? palette.highlight.darker(1.2) : palette.highlight

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            // TODO: Make hover start instantaneous
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.9;height:800;width:600}
}
##^##*/

