
#include <libc/component.h>

#include <QQuickView>
#include <QGuiApplication>
#include <QQmlContext>

#include "oskinputmethod.h"

extern void initialize_qt_core(Genode::Env &);
extern void initialize_qt_gui(Genode::Env &);

void Libc::Component::construct(Libc::Env &env)
{

    Libc::with_libc([&]{
            initialize_qt_core(env);
            initialize_qt_gui(env);
            int argc = 1;
            char *argv[] = {"osk"};
            qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
            OskInputMethod *oim = new OskInputMethod();
            QGuiApplication app(argc, argv);
            QQuickView view(QString("qrc:/main.qml"));
            QQmlContext *context = view.rootContext();
            context->setContextProperty(QStringLiteral("OskInputMethod"), oim);
            view.setResizeMode(QQuickView::SizeRootObjectToView);
            view.show();
            return app.exec();
    });
}
