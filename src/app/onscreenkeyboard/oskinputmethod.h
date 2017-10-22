
#ifndef _OSK_INPUTMETHOD_H_
#define _OSK_INPUTMETHOD_H_

#include <QObject>
#include <QList>

#include <base/log.h>
#include <util/string.h>

#include <abstractinputmethod.h>

namespace Osk {
    class Input_Method;
}

class Osk::Input_Method : public QtVirtualKeyboard::AbstractInputMethod
{
    Q_OBJECT
    Q_PROPERTY(QtVirtualKeyboard::InputContext *inputContext READ inputContext CONSTANT)
    Q_PROPERTY(QtVirtualKeyboard::InputEngine *inputEngine READ inputEngine CONSTANT)
private:
public:
    explicit Input_Method(QObject *parent = 0);
    ~Input_Method();

    QList<QtVirtualKeyboard::InputEngine::InputMode> inputModes(const QString &);
    bool setInputMode(const QString &, QtVirtualKeyboard::InputEngine::InputMode);
    bool setTextCase(QtVirtualKeyboard::InputEngine::TextCase);
    bool keyEvent(Qt::Key, const QString &, Qt::KeyboardModifiers);
};
#endif //_OSK_INPUTMETHOD_H

