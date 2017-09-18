#include <oskinputmethod.h>

OskInputMethod::OskInputMethod(QObject *parent)
{
}

OskInputMethod::~OskInputMethod()
{
}

void OskInputMethod::textEvent(QString text)
{
    qDebug() << __func__ << text;
}

