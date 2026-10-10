# Shell Script for a Simple Antivirus Daemon

## 1. Overview

- This project implements a simple antivirus daemon using Bash shell scripting on Ubuntu Linux.
- The antivirus daemon monitors a source directory for changes. When a change is detected, it scans the files for predefined suspicious extensions and keywords,
  files identified as malicious are copied to a quarantine directory and removed from the source directory.
- The project also includes a restore tool that allows users to review quarantined files, restore files that were falsely flagged, or permanently delete files
  considered malicious.
-A Makefile is used to prepare the quarantine directory and run the antivirus daemon or restore tool.

## 2. Project Structure
The project contains the following files and directories:

```text
Shell-Script-for-a-Simple-Antivirus-Daemon/
├── antivirusd.sh
├── restore.sh
├── makefile
├── .gitignore
├── directory-info.last
├── directory-info.new
├── quarantine/
└── test_files/
```

### File and Directory Description

- `antivirusd.sh`: Monitors the source directory, detects changes, scans files, and quarantines files identified as malicious.
- `restore.sh`: Provides an interactive menu for reviewing quarantined files, restoring files, permanently deleting them or leave the files as it is.
- `makefile`: Defines targets for running the antivirus daemon and restore tool and creating the quarantine directory.
- `.gitignore`: Specifies files and directories that Git should ignore.
- `directory-info.last`: Stores the previous directory snapshot used for comparison.
- `directory-info.new`: Stores the latest directory snapshot.
- `test_files/`: The source directory monitored by the antivirus daemon.
- `quarantine/`: The destination directory for files identified as malicious.

The two directory snapshot files are generated during execution. They are used to detect changes between checks.

## 3. Prerequisites and Installation

### Prerequisites

The project requires:
- Ubuntu Linux.
- Bash shell.
- GNU Make.
- Standard Linux utilities, including `ls`, `cmp`, `grep`, `cp`, `rm`, `mv`, and `sleep`.

### Installing GNU Make

If GNU Make is not installed, open a terminal and run:

```bash
sudo apt update
sudo apt install make
```

To verify the installation, run:

```bash
make --version
```

## 4. Antivirus Detection Rules

The detection rules are defined inside the `scan()` function in `antivirusd.sh`.

### Flagged Extensions

The script checks file extensions using a `case` statement. The required extensions are:

- `.exe`
- `.bat`
- `.vbs`
- `.scr`
- `.ps1`

### Flagged Keywords

The script searches file contents using `grep -qi`. The required keywords are:

- `virus`
- `trojan`
- `malware`
- `worm`
- `ransomware`

The `-i` option makes the search case-insensitive, while `-q` suppresses normal search output.
A file is considered malicious if it matches at least one of the required extension or content rules.

## 5. How the Antivirus Daemon Works

The antivirus daemon accepts three command-line arguments:

1. `dir`: The source directory to monitor.
2. `malicious_dir`: The destination directory for quarantined files.
3. `interval-secs`: The time to wait between checks, in seconds.

The script first checks whether `directory-info.last` exists. If it does not exist, the daemon scans the source directory immediately 
and creates the initial directory snapshot.

After the initial scan, the daemon enters an infinite loop:

1. It waits for the specified interval.
2. It creates a new snapshot of the source directory using `ls -l`.
3. It compares `directory-info.new` with `directory-info.last` using `cmp -s`.
4. If the snapshots are identical, it waits for the next check without scanning.
5. If the snapshots differ, it scans the source directory for malicious files.
6. It updates `directory-info.last` with the latest snapshot.

When a file matches either detection rule, the script prints a message, copies the file to the quarantine directory and removes the original file
from the source directory.

The daemon continues running until it is stopped.

## 6. How the Restore Tool Works

The restore tool accepts two command-line arguments:

1. `dir`: The original source directory.
2. `malicious_dir`: The quarantine directory.

The script displays the files currently in the quarantine directory as a numbered list. The user selects a file and chooses one of three options:

1. **Restore the file:** Moves the selected file back to the source directory.
2. **Permanently delete the file:** Removes the selected file from the quarantine directory.
3. **Leave the file unchanged:** Keeps the file in quarantine and returns to the list.

If the quarantine directory is empty when the tool starts, the script displays a message indicating that there are no malicious files to review.

## 7. Running the Project

The Makefile uses the following configuration:

- Source directory: `test_files`
- Quarantine directory: `quarantine`
- Monitoring interval: 5 seconds

### 7.1 Run the Antivirus Daemon

Execute:

```bash
make
```

The Makefile first creates the quarantine directory if it does not already exist. 
It then starts `antivirusd.sh` with the configured source directory, quarantine directory, and interval.
The daemon continues running in the terminal.

### 7.2 Run the Restore Tool

Stop the antivirus daemon before starting the restore tool.

Execute:

```bash
make restore
```

The restore tool displays the quarantined files and allows the user to select an action for each file.

### 7.3 Run the Scripts Directly

The antivirus daemon can also be started without using Make:

```bash
bash antivirusd.sh test_files quarantine 5
```

The restore tool can be started directly using:

```bash
bash restore.sh test_files quarantine
```
