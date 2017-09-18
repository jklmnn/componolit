
#include <QQuickView>
#include <QGuiApplication>
#include <QQmlContext>

#include "oskinputmethod.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
    OskInputMethod *oim = new OskInputMethod();
    QGuiApplication app(argc, argv);
    QQuickView view(QString("qrc:/main.qml"));
    QQmlContext *context = view.rootContext();
    context->setContextProperty(QStringLiteral("OskInputMethod"), oim);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}
