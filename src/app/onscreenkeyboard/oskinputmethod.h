
#ifndef _OSK_INPUTMETHOD_H_
#define _OSK_INPUTMETHOD_H_

#include <QObject>
#include <base/log.h>
#include <util/string.h>

#include <oskinputsession.h>

namespace Osk {
    class Input_Method;
}

class Osk::Input_Method : public QObject
{
    Q_OBJECT
private:
    Osk::Virtual_Input *_vinput;
public:
    explicit Input_Method(QObject *parent = 0, Osk::Virtual_Input *vinput = 0);
    void attach_virtual_input(Osk::Virtual_Input*);
    Q_INVOKABLE void textEvent(QString, int);
};
#endif //_OSK_INPUTMETHOD_H

