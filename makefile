DIR = test_files
MALICIOUS_DIR = quarantine
INTERVAL = 5

all: pre-build
	bash antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)
restore: pre-build 
	bash restore.sh $(DIR) $(MALICIOUS_DIR)
pre-build:
	mkdir -p $(MALICIOUS_DIR)