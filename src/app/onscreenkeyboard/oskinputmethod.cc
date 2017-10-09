#include <oskinputmethod.h>

Osk::Input_Method::Input_Method(QObject *parent, Osk::Virtual_Input* vinput)
{
    _vinput = vinput;
}

void Osk::Input_Method::textEvent(QString text, int cursor)
{
    if (cursor == 0 && text.size() == 1)
        return;
    unsigned short c = 0;
    if (cursor == 2)
        c = text.at(1).unicode();
    else
        if (!text.size())
            c = '\r';
    /*
    Genode::log("cursor: ", cursor);
    switch(c){
        case 10:
            Genode::log("return");
            break;
        case 13:
            Genode::log("backspace");
            break;
        case 32:
            Genode::log("space");
            break;
        default:
            Genode::log((void*)c);
            break;
    }
    */
    if(_vinput)
        _vinput->handle_event(c);
    else
        Genode::warning("No virtual input session attached!");
}

void Osk::Input_Method::attach_virtual_input(Virtual_Input *vinput)
{
    _vinput = vinput;
}
