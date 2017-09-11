#include <stdlib.h>
#include <pthread.h>

int pthread_rwlock_timedwrlock(pthread_rwlock_t *l, const struct timespec *ts)
{
	printf("FIXME: pthread_rwlock_timedwrlock implemented without timeout.\n");
	abort();
};

int pthread_attr_setstack(pthread_attr_t *attr, void *stackaddr, size_t	stacksize)
{
	printf("FIXME: pthread_attr_getstack called\n");
	abort();
};

int pthread_getschedparam(pthread_t thread, int *policy, struct sched_param *param)
{
	printf("FIXME: pthread_getschedparam called\n");
	abort();
}
