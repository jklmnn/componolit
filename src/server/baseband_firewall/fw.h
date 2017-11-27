
#ifndef _FW_H_
#define _FW_H_

extern "C" {

void baseband_fw__filter(void*, const void*, const int, const int);

void log_int(const int);
void log(const char *);
void warn(const char *);
void error(const char *);

// gnat exceptions

void __gnat_last_chance_handler();

} // C

#endif
