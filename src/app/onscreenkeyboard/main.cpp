
#include <QQuickView>
#include <QGuiApplication>
#include <QQmlEngine>

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
    QGuiApplication app(argc, argv);
    QQuickView view(QString("qrc:/main.qml"));
    view.show();
    return app.exec();
}
