#include <backtrace/Backtrace.h>
#include <sys/types.h>

class BacktraceFake : public Backtrace {

public:
	BacktraceFake(pid_t pid, pid_t tid, BacktraceMap* map) : Backtrace(pid, tid, map) {};
	virtual ~BacktraceFake() {};
	size_t Read(uintptr_t addr, uint8_t* buffer, size_t bytes);
	bool ReadWord(uintptr_t ptr, word_t* out_value);
	bool Unwind(size_t num_ignore_frames, ucontext_t* context);

protected:
	std::string GetFunctionNameRaw(uintptr_t pc, uintptr_t* offset);
};

bool BacktraceFake::Unwind(size_t num_ignore_frames, ucontext_t* context)
{
	return false;
}

bool BacktraceFake::ReadWord(uintptr_t ptr, word_t* out_value)
{
	out_value = 0;
	return false;
}

size_t BacktraceFake::Read(uintptr_t addr, uint8_t* buffer, size_t bytes)
{
	return 0;
}

std::string BacktraceFake::GetFunctionNameRaw(uintptr_t pc, uintptr_t* offset)
{
	return "";
}

Backtrace::Backtrace(pid_t pid, pid_t tid, BacktraceMap* map)
{
}

Backtrace::~Backtrace()
{
}

Backtrace* Backtrace::Create(pid_t pid, pid_t tid, BacktraceMap* map)
{
	return new BacktraceFake(pid, tid, map);
}

void Backtrace::FillInMap(uintptr_t pc, backtrace_map_t* map)
{
	map = NULL;
}

std::string Backtrace::FormatFrameData(size_t frame_num)
{
	return "<dummy>";
}

std::string Backtrace::FormatFrameData(const backtrace_frame_data_t* frame)
{
	return "<dummy>";
}

std::string Backtrace::GetFunctionName(uintptr_t pc, uintptr_t* offset)
{
	return "";
}

bool Backtrace::VerifyReadWordArgs(uintptr_t ptr, word_t* out_value)
{
	return false;
}
