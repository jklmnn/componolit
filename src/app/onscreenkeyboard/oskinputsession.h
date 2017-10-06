
#ifndef _OSKINPUTSESSION_H_
#define _OSKINPUTSESSION_H_

#include <base/log.h>

#include <input/event.h>
#include <input/event_queue.h>
#include <input/keycodes.h>

namespace Osk {
    class Virtual_Input;
};

class Osk::Virtual_Input {
private:
    Input::Event_queue &_queue;
public:
    Virtual_Input(Input::Event_queue &);
    void handle_event(char);
    bool event_pending();
};

#endif //_OSKINPUTSESSION_H_
