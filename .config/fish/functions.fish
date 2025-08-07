################################################################################
# Helper Function: find_max_number
#   Usage: find_max_number <base>
#   Description: Scans the current directory for files whose names start with
#                the given <base> followed immediately by digits (e.g. bg1.jpg,
#                bg2.png, etc.). It strips the file extension and the prefix,
#                then returns the highest number found (or 0 if none exist).
function find_max_number
    set base $argv[1]
    set max_number 0
    for f in $base*
        if test -f "$f"
            # Remove the extension from the filename.
            set file_no_ext (string replace -r '\..*$' '' "$f")
            # Remove the base prefix; what remains should be the numeric part.
            set number_str (string replace -r "^$base" "" "$file_no_ext")
            # Check if the remaining part is entirely digits.
            if string match -q -r '^[0-9]+$' "$number_str"
                set number (math $number_str)
                if test $number -gt $max_number
                    set max_number $number
                end
            end
        end
    end
    echo $max_number
end

################################################################################
# GC : Git Commit
#   Usage: gc <commit message>
#   Description: Adds all changes, commits with the joined message, and pushes to main.
# function gc
#     set -l msg (string join " " $argv)
#     git add .
#     git commit -m "$msg"
#     git push origin main
# end

################################################################################
# rewb : Reset Waybar
#   Usage: rewb
#   Description: Kills and restarts the Waybar process.
function rewb
    killall waybar
    waybar &
end

################################################################################
# mnr : Move and Rename Blueprint  
#   Usage: mnr 'file-name'
#   Description: Moves blueprint.json from Downloads to current directory and renames it.
function mnr
    if test (count $argv) -eq 0
        echo "Usage: mnr 'file-name'"
        return 1
    end

    if not test -f ~/Downloads/blueprint.json
        echo "Error: blueprint.json not found in ~/Downloads/"
        return 1
    end

    mv ~/Downloads/blueprint.json "./$argv[1].json"
    echo "✓ Moved and renamed to $argv[1].json"
end

################################################################################
# ESM : Start Espanso Monitor
#   Usage: esm
#   Description: Starts the espanso device monitor in the background
function esm
    bash ~/base/git/scripts/espanso-monitor.sh &
    echo "Espanso monitor started in background"
end

################################################################################
# ESM-STATUS : Check Espanso Monitor Status  
#   Usage: esm-status
#   Description: Shows status of both the monitor script and espanso service.
function esm-status
    echo "=== Espanso Monitor Status ==="
    set monitor_running (ps aux | grep espanso-monitor | grep -v grep | wc -l)
    if test $monitor_running -gt 0
        echo "✓ Monitor running"
        ps aux | grep espanso-monitor | grep -v grep | head -1
    else
        echo "✗ Monitor not running"
    end

    echo ""
    echo "=== Espanso Service Status ==="
    systemctl --user status espanso --no-pager -l
end

################################################################################
# resetusers : Reset User Permissions  
#   Usage: resetusers
#   Description: Resets ownership of home directory to current user and group.
function resetusers
    echo 'Resetting home directory permissions...'
    sudo chown -R $USER:(id -gn) ~/
    echo "✓ Home directory ownership reset to $USER:"(id -gn)
end

################################################################################
# rehp : Reset SwayNC 
#   Usage: rehp
#   Description: Kills and restarts the Hyprpaper process.
function resnc
    killall swaync
    swaync &
end

################################################################################
# RNF : Rename (Fuzzy)
#   Usage: rnf <fuzzy_search_pattern> <replacement_base> [--dry-run]
#   Description:
#       Searches for files in the current directory that fuzzily match the provided
#       pattern (case-insensitive) and previews a renaming plan where each file is
#       renamed to <replacement_base><n><original extension>.
#       The script calls find_max_number to automatically detect existing files
#       that start with the given base, and then calculates the next available number.
#       It then prompts you whether to continue numbering from that point.
#       Use --dry-run to preview without executing changes.
function rnf
    # Process optional dry-run flag.
    set DRY_RUN 0
    set args $argv
    for arg in $argv
        if test "$arg" = --dry-run
            set DRY_RUN 1
            set args (contains --invert --value -- "$arg" $args)
        end
    end

    if test (count $args) -ne 2
        echo "Usage: rnf <fuzzy_search_pattern> <replacement_base> [--dry-run]"
        return 1
    end

    set search $args[1]
    set base $args[2]

    # Build a fuzzy regex pattern from the search string.
    set fuzzy_pattern ".*"
    for char in (string split '' $search)
        set fuzzy_pattern "$fuzzy_pattern$char.*"
    end

    # Collect matching files using grep.
    set matches
    for f in *
        if test -f "$f"
            echo "$f" | grep -Ei "$fuzzy_pattern" >/dev/null
            if test $status -eq 0
                set matches $matches $f
            end
        end
    end

    if test (count $matches) -eq 0
        echo "No matching files found."
        return 1
    end

    # Use the helper function to find the maximum number used for this base.
    set max_used (find_max_number $base)
    if test $max_used -gt 0
        set proposed (math $max_used + 1)
        read -P "Existing files detected with prefix '$base' up to $base$max_used. Start numbering from $proposed? (y/n): " ans
        if test "$ans" = y
            set next_num $proposed
        else
            read -P "Enter custom starting number: " custom
            set next_num $custom
        end
    else
        set next_num 1
    end

    # Preview the renaming plan.
    echo "The following files will be renamed:"
    set i $next_num
    for f in $matches
        set ext (string replace -r '.*(\..+)$' '$1' "$f")
        if test "$ext" = "$f"
            set ext ""
        end
        echo "$f -> $base$i$ext"
        set i (math $i + 1)
    end

    if test $DRY_RUN -eq 1
        echo "Dry run mode: No changes will be made."
        return 0
    end

    read -P "Proceed with renaming? (y/n): " response
    if not test "$response" = y
        echo "Aborted."
        return 0
    end

    # Rename files and log changes.
    set log_file ".rename_log.txt"
    if test -f $log_file
        cp $log_file "$log_file.bak"
    end

    set i $next_num
    for f in $matches
        if test -f "$f"
            set ext (string replace -r '.*(\..+)$' '$1' "$f")
            if test "$ext" = "$f"
                set ext ""
            end
            set new_name "$base$i$ext"
            mv "$f" "$new_name"
            echo "$new_name -> $f" >>$log_file
            set i (math $i + 1)
        end
    end

    echo "Files have been renamed. Log saved to $log_file."
end

################################################################################
# RNR : Rename (Recent)
#   Usage: rnr <number_of_files> <replacement_base> [--dry-run]
#   Description:
#       Selects the N most recent files in the current directory using eza (sorted by
#       modified time), previews a renaming plan with new names formatted as
#       <replacement_base><n><original extension>, and renames after confirmation.
#       The script calls find_max_number to detect existing files with the given base,
#       and then calculates the next available number.
#       Use --dry-run to see the preview without actually renaming.
function rnr
    set DRY_RUN 0
    set args $argv
    for arg in $argv
        if test "$arg" = --dry-run
            set DRY_RUN 1
            set args (contains --invert --value -- "$arg" $args)
        end
    end

    if test (count $args) -ne 2
        echo "Usage: rnr <number_of_files> <replacement_base> [--dry-run]"
        return 1
    end

    set num_files $args[1]
    set base $args[2]

    # Get N most recent files using eza.
    set files (eza -t modified -1 | head -n $num_files | while read f
        if test -f "$f"
            echo "$f"
        end
    end)

    if test (count $files) -eq 0
        echo "No files found."
        return 1
    end

    # Use the helper to detect the maximum number already used.
    set max_used (find_max_number $base)
    if test $max_used -gt 0
        set proposed (math $max_used + 1)
        read -P "Existing files detected with prefix '$base' up to $base$max_used. Start numbering from $proposed? (y/n): " ans
        if test "$ans" = y
            set next_num $proposed
        else
            read -P "Enter custom starting number: " custom
            set next_num $custom
        end
    else
        set next_num 1
    end

    echo "The following files will be renamed:"
    set i $next_num
    for f in $files
        set ext (string replace -r '.*(\..+)$' '$1' "$f")
        if test "$ext" = "$f"
            set ext ""
        end
        echo "$f -> $base$i$ext"
        set i (math $i + 1)
    end

    if test $DRY_RUN -eq 1
        echo "Dry run mode: No changes will be made."
        return 0
    end

    read -P "Proceed with renaming? (y/n): " response
    if not test "$response" = y
        echo "Aborted."
        return 0
    end

    set log_file ".rename_log.txt"
    if test -f $log_file
        cp $log_file "$log_file.bak"
    end

    set i $next_num
    for f in $files
        if test -f "$f"
            set ext (string replace -r '.*(\..+)$' '$1' "$f")
            if test "$ext" = "$f"
                set ext ""
            end
            set new_name "$base$i$ext"
            mv "$f" "$new_name"
            echo "$new_name -> $f" >>$log_file
            set i (math $i + 1)
        end
    end

    echo "Files have been renamed. Log saved to $log_file."
end

################################################################################
# RNU : Rename Undo
#   Usage: rnu
#   Description:
#       Reverts the renaming operations recorded in .rename_log.txt.
#       Each line in the log should have the format: <new_name> -> <original_name>.
#       This function will prompt for confirmation before reverting each change.
function rnu
    set log_file ".rename_log.txt"
    if not test -f $log_file
        echo "No rename log found."
        return 1
    end

    echo "The following renames will be reverted:"
    cat $log_file

    read -P "Proceed with undoing the renames? (y/n): " confirm
    if not test "$confirm" = y
        echo "Aborted undo."
        return 0
    end

    for line in (cat $log_file)
        set new_name (echo $line | awk '{print $1}')
        set original_name (echo $line | awk '{print $3}')
        if test -f "$new_name"
            mv "$new_name" "$original_name"
            echo "Reverted: $new_name -> $original_name"
        else
            echo "File $new_name not found. Skipping."
        end
    end

    echo "Undo complete. Consider reviewing $log_file before clearing."
end

################################################################################
# MD : Make Directory and Change Into It
#   Usage: md <directory_name>
#   Description: Creates the specified directory (if it doesn't exist) and cd's into it.
function md
    mkdir -p $argv
    cd $argv
end

################################################################################
# BKP : Backup a File
#   Usage: bkp <file>
#   Description:
#       Creates a backup copy of the specified file in the same directory
#       with ".bak" appended, or with an incremented number if multiple backups exist.
function bkp
    set original $argv[1]
    if not test -f $original
        echo "Error: File '$original' does not exist." 1>&2
        return 1
    end

    set filename (basename $original)
    set filedir (dirname $original)

    set backup "$filedir/$filename.bak"
    set backup_num 1
    if test -f $backup
        while test -f "$filedir/$filename.bak$backup_num"
            set backup_num (math $backup_num + 1)
        end
        set backup "$filedir/$filename.bak$backup_num"
    end

    cp -p $original $backup && echo "Backup created: $backup"
end
