#include <ostream>

class Klass {
 public:
  Klass(const char& value);
  enum ValueType { first = 0x00, second = 0x02, };
};

std::ostream& operator<<(std::ostream& os, const Klass::ValueType& code);

class Subklass : public Klass {
 public:
  Subklass(const char& value) : Klass(value) {}
};

std::ostream& operator<<(std::ostream& os, const Subklass::ValueType& code);
