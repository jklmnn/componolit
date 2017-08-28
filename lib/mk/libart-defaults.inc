# Filter out GCC 7 options unsupported by GCC 6.3
ANDROID_EXCLUDE_OPT += \
	-Wimplicit-fallthrough \
	-Wint-to-void-pointer-cast \
	-Wthread-safety \
	-Wthread-safety-negative \
	-Wunreachable-code-break \
	-Wunreachable-code-return \
	-Wused-but-marked-unused \
	-Wno-undefined-var-template \
	-Wno-constant-conversion \
	-Wredundant-decls

# Filter out known warnings that cause trouble with our toolchain
# -Wshadow:
#	Prevent errors regarding hidden constructor for struct
# 	sigaction/sigaltstack/sigstack, sigvec and others
ANDROID_EXCLUDE_OPT += \
	-Wshadow
