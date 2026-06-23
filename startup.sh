#!/bin/sh
set -e

# Substituovanie env premennych do homeserver.yaml
# Pouzivame heredoc s 'PYEOF' aby shell neexpandoval ${...} v Python kode
python3 << 'PYEOF'
import os, re
template = open('/config/homeserver.yaml').read()
result = re.sub(r'\${([^}]+)}', lambda m: os.environ.get(m.group(1), m.group(0)), template)
open('/data/homeserver.yaml', 'w').write(result)
print('homeserver.yaml generated from template')
PYEOF

# Jednoduchy log config — stdout only (Docker best practice)
cat > /data/matrix.system15.win.log.config << 'LOGEOF'
version: 1
formatters:
    precise:
        format: "%(asctime)s - %(name)s - %(lineno)d - %(levelname)s - %(request)s - %(message)s"
handlers:
    console:
        class: logging.StreamHandler
        formatter: precise
loggers:
    synapse.storage.SQL:
        level: INFO
root:
    level: INFO
    handlers: [console]
disable_existing_loggers: false
LOGEOF

exec python -m synapse.app.homeserver --config-path /data/homeserver.yaml
