import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.1

Item {
    width: Screen.width
    height: inputPanel.height
    
    Item {
        width: Screen.width < Screen.height ? parent.height : parent.width
        height: Screen.width < Screen.height ? parent.width : parent.height
        anchors.centerIn: parent

        InputPanel {
            id: inputPanel
            z: 99
            y: parent.height - height
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }
}
