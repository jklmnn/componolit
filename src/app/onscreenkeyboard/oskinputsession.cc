
#include <oskinputsession.h>

Osk::Virtual_Input::Virtual_Input(Input::Event_queue &queue) : _queue(queue)
{
    Genode::log(__func__);
}

void Osk::Virtual_Input::handle_event(unsigned short c)
{
    switch(c){
        case 0:
            break;
        case 10:
            _queue.add(Input::Event(Input::Event::PRESS, Input::Keycode::KEY_ENTER, 0, 0, 0, 0));
            _queue.add(Input::Event(Input::Event::RELEASE, Input::Keycode::KEY_ENTER, 0, 0, 0, 0));
            Genode::log(__func__, " return");
            break;
        case 13:
            _queue.add(Input::Event(Input::Event::PRESS, Input::Keycode::KEY_BACKSPACE, 0, 0, 0, 0));
            _queue.add(Input::Event(Input::Event::RELEASE, Input::Keycode::KEY_BACKSPACE, 0, 0, 0, 0));
            Genode::log(__func__, " backspace");
            break;
        case 32:
            _queue.add(Input::Event(Input::Event::PRESS, Input::Keycode::KEY_SPACE, 0, 0, 0, 0));
            _queue.add(Input::Event(Input::Event::RELEASE, Input::Keycode::KEY_SPACE, 0, 0, 0, 0));
            Genode::log(__func__, " space");
            break;
        default:
            unsigned char *byte = (unsigned char*)(void*)&c;
            _queue.add(Input::Event(
                        Input::Event::Utf8 { byte[0], byte[1] }
                        ));
            Genode::log(__func__, " ", (void*)c);
            break;
    }
}

bool Osk::Virtual_Input::event_pending()
{
    Genode::log(__func__);
    return false;
}
