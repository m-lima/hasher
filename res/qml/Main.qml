import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Fusion
import QtQuick.Window

ApplicationWindow {
    id: root
    title: 'Hasher'
    visible: true

    width: 400
    height: 400
    x: Screen.width / 2 - 200
    y: Screen.height / 2 - 200

    palette.window: '#353535'
    palette.windowText: '#cccccc'
    palette.base: '#252525'
    palette.alternateBase: '#353535'
    palette.text: '#cccccc'
    palette.button: '#353535'
    palette.buttonText: '#aaaaaa'
    palette.highlight: 'green'
    palette.highlightedText: '#cccccc'

    SwipeView {
        id: content

        anchors {
            top: parent.top
            bottom: footer.top
            left: parent.left
            right: parent.right
        }

        currentIndex: 0
        interactive: false

        Parameters {}

        BigButton {
            text: 'Yooooo'
        }
    }

    Item {
        id: footer

        anchors.bottom: parent.bottom
        width: parent.width
        height: 50

        BigButton {
            id: back

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }

            visible: width > 0
            width: content.currentIndex > 0 ? 50 : 0

            icon.source: 'qrc:/img/left.svg'
            icon.color: palette.buttonText
            onClicked: content.currentIndex--
            palette.button: root.palette.button.lighter(1.3)

            Behavior on width {
                NumberAnimation {
                    duration: 200
                }
            }
        }

        BigButton {
            id: next

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: back.right
            }

            text: 'Next'
            onClicked: content.currentIndex++
            state: content.currentIndex > 0 ? 'Crack' : ''

            palette.button: 'darkgreen'
            palette.buttonText: '#252525'
            font.bold: true
            font.pointSize: 18

            states: State {
                name: 'Crack'
                PropertyChanges {
                    target: next

                    onClicked: console.log('Crack')
                }
            }

            transitions: [
                Transition {
                    to: ''
                    SequentialAnimation {
                        NumberAnimation {
                            target: next
                            duration: 100
                            to: 1
                            property: 'font.pointSize'
                        }
                        PropertyAction {
                            target: next
                            value: 'Next'
                            property: 'text'
                        }
                        NumberAnimation {
                            target: next
                            duration: 100
                            to: 18
                            property: 'font.pointSize'
                        }
                    }
                },
                Transition {
                    to: 'Crack'
                    SequentialAnimation {
                        NumberAnimation {
                            target: next
                            duration: 100
                            to: 1
                            property: 'font.pointSize'
                        }
                        PropertyAction {
                            target: next
                            value: 'Crack'
                            property: 'text'
                        }
                        NumberAnimation {
                            target: next
                            duration: 100
                            to: 18
                            property: 'font.pointSize'
                        }
                    }
                }
            ]
        }
    }
}
