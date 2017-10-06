
#include <oskinputsession.h>

Osk::Virtual_Input::Virtual_Input(Input::Event_queue &queue) : _queue(queue)
{
    Genode::log(__func__);
}

void Osk::Virtual_Input::handle_event()
{
    Genode::log(__func__);
}

bool Osk::Virtual_Input::event_pending()
{
    Genode::log(__func__);
    return false;
}
