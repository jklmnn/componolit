
#ifndef _OSK_INPUTMETHOD_H_
#define _OSK_INPUTMETHOD_H_

#include <QObject>
#include <base/log.h>
#include <util/string.h>

class OskInputMethod : public QObject
{
    Q_OBJECT

public:
    explicit OskInputMethod(QObject *parent = 0);
    ~OskInputMethod();
    Q_INVOKABLE void textEvent(QString, int);
};
#endif //_OSK_INPUTMETHOD_H

