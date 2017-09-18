
import QtQuick 2.0
//import QtQuick.VirtualKeyboard 2.1

InputMethod {

    function inputModes(locale)
    {
        return [InputEngine.Latin];
    }

    function setInputMode(locale)
    {
        return true;
    }

    function setTextCase(textCase)
    {
        return true;
    }

    function reset()
    {
    }

    function update()
    {
    }

    function keyEvent(key, text, modifiers)
    {
        var accept = false;
        return accept;
    }
}
