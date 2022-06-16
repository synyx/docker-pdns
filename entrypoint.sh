#!/bin/sh

# Set UID/GID to default user
PDNS_SETGID="${PDNS_SETGID:-pdns}"
PDNS_SETUID="${PDNS_SETUID:-pdns}"

# dynamic extra arguments for the PowerDNS server process
extra_args=""

# Track if we need to add the /etc/pdns.env/ include directory
need_env_include=0

# Create the include directory for potential environment variable configs
mkdir -p /etc/pdns.env.d

# Extract PDNS_ environment variables to their corresponding config variable
for pdns_env_var in $(awk 'BEGIN { for(v in ENVIRON) if (v ~ /^PDNS_/) print v }' | sort); do
  pdnsvar=$(echo $pdns_env_var | sed -e 's/^PDNS_//' | tr '[:upper:]_' '[:lower:]-')
  pdnsval=$(eval "echo \${${pdns_env_var}}")
  printf "%s=%s\n" $pdnsvar $pdnsval >> /etc/pdns.env.d/00-environment.conf
  need_env_include=1
done

if [ $need_env_include -gt 0 ]; then
  extra_args="${extra_args} --include-dir=/etc/pdns.env.d"
fi

exec /usr/sbin/pdns_server \
  --daemon=no \
  --disable-syslog \
  --guardian=no \
  --setgid="${PDNS_SETGID}" \
  --setuid="${PDNS_SETUID}" \
  --write-pid=no \
  ${extra_args} \
  $@
