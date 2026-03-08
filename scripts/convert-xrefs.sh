#!/bin/bash

# Convert xref links to external Microsoft Learn URLs
# Only process content directories (not .claude, .lunet, etc.)

convert_xref_to_link() {
    local file="$1"
    
    # First, handle the <xref:...> pattern with display names
    # Extract the last part of the path as display text
    
    # Use perl for complex regex
    perl -i -e '
        local $/;
        $content = <>;
        
        # Convert <xref:System.Type> or <xref:Microsoft.Type> to .NET API links
        # These are .NET API references
        while ($content =~ s/<xref:(System\.[^>]+)>/mk_net_link($1)/ge) {}
        while ($content =~ s/<xref:(Microsoft\.[^>]+)>/mk_net_link($1)/ge) {}
        
        # Convert <xref:other.path> to ASP.NET Core docs links
        while ($content =~ s/<xref:([^>]+)>/mk_aspnet_link($1)/ge) {}
        
        # Convert [text](xref:path) pattern
        while ($content =~ s/\[([^\]]+)\]\(xref:(System\.[^)]+)\)/mk_net_link_text($1, $2)/ge) {}
        while ($content =~ s/\[([^\]]+)\]\(xref:(Microsoft\.[^)]+)\)/mk_net_link_text($1, $2)/ge) {}
        while ($content =~ s/\[([^\]]+)\]\(xref:([^)]+)\)/mk_aspnet_link_text($1, $2)/ge) {}
        
        print $content;
        
        sub mk_net_link {
            my $xref = shift;
            my $display = $xref;
            $display =~ s/\#.*//;
            $display =~ s/\%2A/ */g;
            $display =~ s/\%60/`/g;
            my $url_path = lc($xref);
            $url_path =~ s/\`.*//;
            return "[$display](https://learn.microsoft.com/dotnet/api/$url_path)";
        }
        
        sub mk_aspnet_link {
            my $xref = shift;
            my $display = $xref;
            $display =~ s/\#.*//;
            $display =~ s/.*\///;
            return "[$display](https://learn.microsoft.com/aspnet/core/$xref)";
        }
        
        sub mk_net_link_text {
            my ($text, $xref) = @_;
            my $url_path = lc($xref);
            $url_path =~ s/\`.*//;
            return "[$text](https://learn.microsoft.com/dotnet/api/$url_path)";
        }
        
        sub mk_aspnet_link_text {
            my ($text, $xref) = @_;
            return "[$text](https://learn.microsoft.com/aspnet/core/$xref)";
        }
    ' "$file"
}

# Process files
for file in $(find . -name "*.md" -not -path "./.lunet/*" -not -path "./.claude/*" -not -name "PLAN.md" -not -name "PROJECT-SUMMARY.md" -not -name "QUICKSTART.md"); do
    echo "Processing: $file"
    convert_xref_to_link "$file"
done

echo "Conversion complete!"
