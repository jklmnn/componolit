
#include <QQuickView>
#include <QGuiApplication>
#include <QQmlEngine>

#include <oskinputmethod.h>

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
    qmlRegisterType<Osk::Input_Method>("com.componolit.onscreenkeyboard", 1, 0, "OskInputMethod");
    
    QGuiApplication app(argc, argv);
    QQuickView view(QString("qrc:/main.qml"));

    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}
