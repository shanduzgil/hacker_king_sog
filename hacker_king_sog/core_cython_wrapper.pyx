cdef extern int trigger_payload(const char* target_host)

def run_exploit(target_host):
    return trigger_payload(target_host.encode('utf-8'))
