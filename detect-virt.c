#include <stdint.h>

#if defined (__i386__)
#define REG_a "eax"
#define REG_b "ebx"
#elif defined (__amd64__)
#define REG_a "rax"
#define REG_b "rbx"
#endif

int main(void)
{
	uint32_t eax, ecx;

	eax = 1;
	__asm__ __volatile__ (
		"  push %%" REG_b " \n\t"
		"  cpuid            \n\t"
		"  pop %%" REG_b "  \n\t"

		: "=a" (eax), "=c" (ecx)
		: "0" (eax)
	);

	return !!!(ecx & 0x80000000U);
}
