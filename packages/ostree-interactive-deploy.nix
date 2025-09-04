{
  writeShellApplication,
  fzf,
  jq,
  sqlite,
}:
writeShellApplication {
  name = "ostree-interactive-deploy";
  runtimeInputs = [
    fzf
    jq
    sqlite
  ];

  excludeShellChecks = [
    "SC2004"
  ];

  text = ''
    export ANNOTATION_DB="''${XDG_DATA_HOME:-''$HOME/.local/share}/ostree-interactive-deploy/db.sqlite"

    function usage() {
        echo "usage: ostree-interactive-deploy"
        echo ""
        echo "Select and deploy an ostree revision"
        echo ""
        echo "options:"
        echo " -h        Show this help"
        echo " -r        Pull latest ostree revisions"
        echo " -d DEPTH  Traverse DEPTH parents when pulling revisions"

        exit "$1"
    }

    function init_annotation_db() {
        mkdir -p "$(dirname "$ANNOTATION_DB")"
        sqlite3 "$ANNOTATION_DB" "CREATE TABLE IF NOT EXISTS annotations (
            revision TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );"
    }

    function add_annotation() {
        local REVISION
        local TYPE

        REVISION=''${1:?REVISION}
        TYPE=''${2:?TYPE}
        
        sqlite3 "$ANNOTATION_DB" "INSERT OR REPLACE INTO annotations (revision, type) VALUES ('$REVISION', '$TYPE');"
    }

    function get_annotation() {
        local REVISION=''${1:?REVISION}
        sqlite3 "$ANNOTATION_DB" "SELECT type FROM annotations WHERE revision = '$REVISION';"
    }

    function mark_revision_broken() {
        local REVISION=''${1:?REVISION}
        add_annotation "$REVISION" "broken"
        echo "Marked revision $REVISION as broken"
    }

    export -f mark_revision_broken add_annotation get_annotation

    function show_revision() {
        local REVISION=''${1?REVISION}
        ostree show "$REVISION" | grep "Version"

        # Show annotation if exists
        local ANNOTATION_INFO
        ANNOTATION_INFO=$(get_annotation "$REVISION")
        if [[ -n "$ANNOTATION_INFO" ]]; then
            local TYPE
            TYPE=$(echo "$ANNOTATION_INFO" | cut -d'|' -f1)
            echo -e "\033[31mAnnotation: $TYPE\033[0m"
        fi

        echo "Pinned: $(rpm-ostree status --json | jq --arg rev "$REVISION" '(.deployments[] | select(."base-checksum" == $rev) | .pinned) // false')"

        echo "Staged: $(rpm-ostree status --json | jq --arg rev "$REVISION" '(.deployments[] | select(."base-checksum" == $rev) | .staged) // false')"

        echo "Booted: $(rpm-ostree status --json | jq --arg rev "$REVISION" '(.deployments[] | select(."base-checksum" == $rev) | .booted) // false')"

        # showing differences between booted revision & selected revision
        rpm-ostree db diff \
            "$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted == true) | ."base-checksum"')" \
            "$REVISION" \
            | tail -n+3
    }

    export -f show_revision

    function list_revisions() {
        local REMOTE=''${1:?REMOTE}

        local BOOTED_CHECKSUM
        local STAGED_CHECKSUM

        BOOTED_CHECKSUM=$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted == true) | ."base-checksum"')
        STAGED_CHECKSUM=$(rpm-ostree status --json | jq -r '.deployments[] | select(.staged == true) | ."base-checksum"')

        ostree log "$REMOTE" | grep "^commit" | cut -d' ' -f2 | while read -r commit; do
            if [[ "$commit" == "$BOOTED_CHECKSUM" ]]; then
                echo -e "\033[31m$commit\033[0m"
            elif [[ "$commit" == "$STAGED_CHECKSUM" ]]; then
                echo -e "\033[32m$commit\033[0m"
            else
                echo "$commit"
            fi
        done
    }

    function interactive_deploy() {
        local REMOTE=''${1:?REMOTE}

        echo "Select a revision to deploy:"
        echo "Press 'ctrl-b' to mark a revision as broken"
        local SELECTED_COMMIT
        SELECTED_COMMIT=$(list_revisions "$REMOTE" | fzf \
            --preview="show_revision {}" \
            --preview-window=right:50% \
            --ansi \
            --bind="ctrl-b:execute(mark_revision_broken {})")

        if [[ -z "$SELECTED_COMMIT" ]]; then
            echo "No revision selected. Exiting."
            exit 0
        fi

        echo "Selected revision: $SELECTED_COMMIT"
        echo "Current origin: $CURRENT_ORIGIN"

        read -r -p "Proceed with deployment? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Deploying $SELECTED_COMMIT..."
            sudo rpm-ostree deploy "$SELECTED_COMMIT"
            echo "Deployment complete. Reboot to apply changes."
        else
            echo "Deployment cancelled."
        fi
    }

    CURRENT_ORIGIN=$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted == true) | .origin')
    REFRESH="0"
    DEPTH="10"

    while getopts "hrd:" opt ; do
        case $opt in
            h) usage 0;;
            r) REFRESH="1";;
            d) DEPTH="$OPTARG";;
            '?') usage "1" >&2;;
        esac
    done
    shift "$(($OPTIND -1))"

    if [ "$REFRESH" = "1" ]; then
        echo "Pulling latest revisions..."
        sudo ostree pull --depth="$DEPTH" --commit-metadata-only "$CURRENT_ORIGIN"
    fi

    init_annotation_db
    interactive_deploy "$CURRENT_ORIGIN"
  '';
}
