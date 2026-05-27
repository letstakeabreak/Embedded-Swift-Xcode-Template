#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    // Build the path to monitor.sh based on $HOME
    char *home = getenv("HOME");
    char path[1024];
    snprintf(path, sizeof(path), "%s/.espswift/scripts/monitor.sh", home);
    
    // Replace this process with the shell script
    execl("/bin/bash", "bash", path, NULL);
    
    // If execl returns, it failed
    return 1;
}
