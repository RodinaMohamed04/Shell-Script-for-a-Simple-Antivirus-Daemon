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
## Bonus 1: Cron Job

### Overview

The cron-based antivirus scanner performs a scan at scheduled intervals instead of running an infinite monitoring loop.

The `antivirus-cron.sh` script uses the same file classification rules as Part 1. It checks file extensions and file contents for suspicious keywords. If a file is identified as malicious, it is copied to the quarantine directory and removed from the source directory after a successful copy.

### Prerequisites

Before configuring the cron job, make sure that:

- Ubuntu or another Linux distribution is installed and running.
- Bash is available.
- The `cron` service is installed and running.
- The project files, including `antivirus-cron.sh`, are present.
- The source directory to scan exists.
- The user has permission to read the source files and write to the quarantine and log directories.
- The quarantine directory is separate from the source directory.
- The script has executable permissions.

### Configuration

**Step 1: Navigate to the project directory**

Open the terminal and navigate to the project directory:

```bash
cd "$HOME/assignment 1 os/Shell-Script-for-a-Simple-Antivirus-Daemon"
```

**Step 2: Make the script executable**

```bash
chmod +x antivirus-cron.sh
```

**Step 3: Prepare the directories**

Create the source and quarantine directories if they do not already exist:

```bash
mkdir -p test_files quarantine
```

**Step 4: Test the script manually**

Create a test file containing a suspicious keyword:

```bash
echo "This file contains a virus." > test_files/cron_test.txt
```

Run the script manually:

```bash
./antivirus-cron.sh "$PWD/test_files" "$PWD/quarantine"
```

Check that the suspicious file is removed from `test_files` and copied to `quarantine`.

**Step 5: Check the cron service**

Check whether the cron service is running:

```bash
sudo systemctl status cron
```

If cron is installed but not running, enable and start it:

```bash
sudo systemctl enable --now cron
```

If cron is not installed, install it on Ubuntu:

```bash
sudo apt update
sudo apt install cron
sudo systemctl enable --now cron
```

**Step 6: Configure the cron job**

Open the current user's crontab:

```bash
crontab -e
```

Add the following entry as a single line:

```cron
* * * * * sleep 23; cd "/home/rodina-mohamed/assignment 1 os/Shell-Script-for-a-Simple-Antivirus-Daemon" && ./antivirus-cron.sh "$PWD/test_files" "$PWD/quarantine" >> cron.log 2>&1
```

Save the file and exit the editor.

The cron expression `* * * * *` schedules the command every minute. The `sleep 23` command delays the scan by approximately 23 seconds after the cron command begins execution.

Standard cron does not support scheduling a job at an exact second. Therefore, this method provides an approximate delay rather than a guarantee of execution at precisely second 23.

The `cd` command changes to the project directory, allowing the script and directories to be referenced using shorter paths. The output and errors are appended to `cron.log`.

**Step 7: Test automatic scanning**

Create a new suspicious test file:

```bash
echo "This file contains malware." > test_files/automatic_test.txt
```

Wait for the next scheduled scan, then check the directories:

```bash
ls -l test_files
ls -l quarantine
```

The suspicious file should be removed from the source directory and copied to quarantine.

Inspect the log:

```bash
cat cron.log
```

The log records the output and errors produced by the script. If no suspicious files are found and no errors occur, the log may remain empty.

### Cron Expression: Every Third Friday of the Month at 12:31 AM

To run the scan on the third Friday of every month at 12:31 AM, use the following cron entry:

```cron
31 0 15-21 * * [ "$(date +\%u)" -eq 5 ] && cd "/home/rodina-mohamed/assignment 1 os/Shell-Script-for-a-Simple-Antivirus-Daemon" && ./antivirus-cron.sh "$PWD/test_files" "$PWD/quarantine"
```

- `31`: Minute 31.
- `0`: Hour 0, corresponding to 12:00 AM.
- `15-21`: Days 15 through 21 of the month.
- `*`: Every month.
- `*`: Every day of the week, with the weekday restriction enforced by the shell condition.
- `date +\%u`: Returns the weekday number, where Monday is 1 and Friday is 5.

The third Friday of a month always falls between the 15th and the 21st. The condition checks that the selected date is Friday before executing the scan.


