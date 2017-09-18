
#ifndef _OSK_INPUTMETHOD_H_
#define _OSK_INPUTMETHOD_H_

#include <QDebug>

class OskInputMethod : public QObject
{
    Q_OBJECT

public:
    explicit OskInputMethod(QObject *parent = 0);
    ~OskInputMethod();
    Q_INVOKABLE void textEvent(QString);
};
#endif //_OSK_INPUTMETHOD_H

