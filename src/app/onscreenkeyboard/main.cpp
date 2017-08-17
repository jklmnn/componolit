
#include <qpa/qplatforminputcontext.h>
#include <platforminputcontext.h>
#include <desktopinputpanel.h>

using namespace QtVirtualKeyboard;

int main(int argc, char *argv[])
{
    QPointer<AbstractInputPanel> m_inputPanel = new DesktopInputPanel();
    m_inputPanel->createView();
    return 0;
}
