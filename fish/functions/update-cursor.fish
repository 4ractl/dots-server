function update-cursor
    echo "🔄 Updating Cursor AI IDE..."
    
    set cursor_dir ~/Applications
    set cursor_path $cursor_dir/cursor.AppImage
    
    # Create Applications directory if it doesn't exist
    mkdir -p $cursor_dir
    
    # Backup current version if it exists
    if test -f $cursor_path
        set backup_name cursor.AppImage.(date +%Y%m%d_%H%M%S).bak
        echo "📦 Backing up current version to $backup_name"
        mv $cursor_path $cursor_dir/$backup_name
    end
    
    # Download new version
    echo "⬇️  Downloading latest Cursor..."
    wget --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
         --show-progress \
         -O $cursor_path \
         "https://cursor.com/download/stable/linux-x64"
    
    if test $status -eq 0
        chmod +x $cursor_path
        echo "✅ Cursor updated successfully!"
        
        # Clean up old backups (keep only 3 most recent)
        echo "🧹 Cleaning up old backups..."
        ls -t $cursor_dir/cursor.AppImage.*.bak 2>/dev/null | tail -n +4 | xargs -r rm -v
        
        # Show version info if possible
        $cursor_path --version 2>/dev/null || echo "📌 Version info not available"
    else
        echo "❌ Download failed!"
        # Restore backup if download failed
        if test -f $cursor_dir/$backup_name
            echo "🔄 Restoring previous version..."
            mv $cursor_dir/$backup_name $cursor_path
        end
        return 1
    end
end
