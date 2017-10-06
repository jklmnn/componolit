
#include <libc/component.h>
#include <input/component.h>
#include <input/root.h>

#include <QQuickView>
#include <QGuiApplication>
#include <QQmlContext>

#include "oskinputmethod.h"
#include "oskinputsession.h"

extern void initialize_qt_core(Genode::Env &);
extern void initialize_qt_gui(Genode::Env &);

namespace Osk {
    struct Main;
};

struct Osk::Main {

    Genode::Env &_env;

    Input::Session_component _session {
        _env,
        _env.ram()
    };

    Input::Root_component _root {
        _env.ep().rpc_ep(),
        _session
    };

    Osk::Virtual_Input _vinput { _session.event_queue() };

    Osk::Input_Method _oim { 0, &_vinput }; 

    Main(Genode::Env &env) : _env(env)
    {
        env.parent().announce(env.ep().manage(_root));
        Libc::with_libc([&]{
            initialize_qt_core(env);
            initialize_qt_gui(env);
            int argc = 1;
            char *argv[] = {"osk"};
            qputenv("QT_IM_MODULE", "qtvirtualkeyboard");
            QGuiApplication app(argc, argv);
            QQuickView view(QString("qrc:/main.qml"));
            QQmlContext *context = view.rootContext();
            context->setContextProperty(QStringLiteral("OskInputMethod"), &_oim);
            view.setResizeMode(QQuickView::SizeRootObjectToView);
            view.show();
            return app.exec();
        });
    };
};

void Libc::Component::construct(Libc::Env &env)
{
    static Osk::Main main(env);
}
