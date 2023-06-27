# GPU_monitoring
A simple gpu monitoring system each 30secs with shell scripting

## gpu_m.sh

The main function that reads the nvidia-smi command and retrieve a csv file with usage information

## gpu_monitoring.sh

Silly monitoring system that calls __gpu_m.sh__ each 30 secs.
