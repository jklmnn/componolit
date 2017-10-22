#include <oskinputmethod.h>

Osk::Input_Method::Input_Method(QObject *parent) :
    QtVirtualKeyboard::AbstractInputMethod(parent)
{
    Genode::log(__func__);
}

Osk::Input_Method::~Input_Method()
{ }

QList<QtVirtualKeyboard::InputEngine::InputMode> Osk::Input_Method::inputModes(const QString &)
{
    Genode::log(__func__);
    return QList<QtVirtualKeyboard::InputEngine::InputMode>();
}

bool Osk::Input_Method::setInputMode(const QString &, QtVirtualKeyboard::InputEngine::InputMode)
{
    Genode::log(__func__);
    return false;
}

bool Osk::Input_Method::setTextCase(QtVirtualKeyboard::InputEngine::TextCase)
{
    Genode::log(__func__);
    return false;
}

bool Osk::Input_Method::keyEvent(Qt::Key, const QString &, Qt::KeyboardModifiers)
{
    Genode::log(__func__);
    return false;
}
