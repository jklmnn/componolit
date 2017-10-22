import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.1

import com.componolit.onscreenkeyboard 1.0

Item {
    width: Screen.width
    height: inputPanel.height
    
    Item {
        width: Screen.width < Screen.height ? parent.height : parent.width
        height: Screen.width < Screen.height ? parent.width : parent.height
        anchors.centerIn: parent
/*
        TextInput {
            focus: true
        }
*/

        OskInputMethod {
            id: oskInputMethod
        }

        InputPanel {
            id: inputPanel
            z: 99
            y: parent.height - height
            anchors.left: parent.left
            anchors.right: parent.right
            keyboard.customInputMethod: oskInputMethod
        }
    }
}
