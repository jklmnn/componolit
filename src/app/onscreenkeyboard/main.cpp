
#include <qpa/qplatforminputcontext.h>
#include <platforminputcontext.h>
#include <desktopinputpanel.h>

#include <QGuiApplication>

using namespace QtVirtualKeyboard;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QPointer<AbstractInputPanel> m_inputPanel = new DesktopInputPanel(&app);
    m_inputPanel->createView();
    return app.exec();
}
