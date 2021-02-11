#!/usr/bin/env bash

set -o errexit -o nounset

target="/var/vcap/all-releases/jobs-src/nats/nats/templates/nats.conf.erb"
sentinel="${target}.patch_sentinel"
if [[ -f "${sentinel}" ]]; then
  if sha256sum --check "${sentinel}" ; then
    echo "Patch already applied. Skipping"
    exit 0
  fi
  echo "Sentinel mismatch, re-patching"
fi

# Fix bind address of nats server
patch --verbose "${target}" <<'EOT'
@@ -41,7 +41,7 @@
   end
 %>

-net: "<%= spec.address %>"
+net: "<%= ENV['HOSTNAME'] %>"
 port: <%= p("nats.port") %>
 prof_port: <%= p("nats.prof_port") %>
 monitor_port: <%= p("nats.monitor_port") %>
EOT

sha256sum "${target}" > "${sentinel}"
