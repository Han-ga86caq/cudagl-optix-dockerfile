#! /usr/bin/expect -f
spawn ./$1
expect "End User License Agreement"
send \x03
expect "Do you accept the previously read EULA? (accept/decline/quit):"
send -- "accept\n"
expect "Install NVIDIA Accelerated Graphics Driver for Linux-x86_64 346.46? ((y)es/(n)o/(q)uit)" 
send -- "no\n"
expect "Do you want to install the OpenGL libraries? ((y)es/(n)o/(q)uit)"
send -- "no\n"
expect "Install the CUDA 7.0 Toolkit? ((y)es/(n)o/(q)uit)"
send -- "yes\n"
expect "Enter Toolkit Location"
send -- "\n"
expect "Do you want to install a symbolic link at /usr/local/cuda? ((y)es/(n)o/(q)uit)"
send -- "yes\n"
expect "Install the CUDA 7.0 Samples? ((y)es/(n)o/(q)uit)"
send -- "no\n"