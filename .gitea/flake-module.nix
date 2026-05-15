{
  perSystem =
    { pkgs, ... }:
    {
      packages.gitea-squash-next = pkgs.writeShellApplication {
        name = "gitea-squash-next";
        runtimeInputs = builtins.attrValues { inherit (pkgs) curl git; };
        text = ''
          git config user.name hyperbot
          git config user.email hyperbot@clan.lol

          git fetch origin main next

          commit_count=$(git rev-list --count origin/main..origin/next)
          if [ "$commit_count" -le 1 ]; then
            echo "next is $commit_count commit(s) ahead of main, nothing to squash"
          elif git diff --quiet origin/main origin/next; then
            echo "No tree differences between main and next, resetting next to main"
            git push origin origin/main:refs/heads/next --force
          else
            # Squash all changes into a single commit on top of main
            git checkout origin/main
            git merge --squash origin/next
            git commit -m "flake: bump inputs"
            git push origin HEAD:refs/heads/next --force
          fi

          # Kick off update-flake-inputs now that next has settled, so we don't
          # have to wait for the daily cron. Safe to fire unconditionally:
          # squash-next only runs on PR merges into next (no self-retrigger),
          # so every invocation is a real "next changed" signal.
          curl -sS -X POST \
            -H "Authorization: token $GITEA_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"ref":"main"}' \
            "$GITEA_URL/api/v1/repos/$GITEA_REPO/actions/workflows/update-flake-inputs.yml/dispatches"
        '';
      };

      packages.gitea-rebase-next = pkgs.writeShellApplication {
        name = "gitea-rebase-next";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs)
            curl
            jq
            tea
            git
            gnused
            gnugrep
            ;
        };
        text = ''
          git config user.name hyperbot
          git config user.email hyperbot@clan.lol

          git fetch origin main next

          # Save the current next ref before resetting
          NEXT_REF=$(git rev-parse origin/next)

          # Check if next has any commits beyond main
          if [ "$(git rev-list --count origin/main..origin/next)" -eq 0 ]; then
            echo "next has no commits beyond main, resetting next to main"
            git push origin origin/main:refs/heads/next --force
            exit 0
          fi

          # Check if next has any tree differences from main
          if git diff --quiet origin/main origin/next; then
            echo "No tree differences between main and next, resetting next to main"
            git push origin origin/main:refs/heads/next --force
            exit 0
          fi

          # Close stale update-* PRs targeting next. We're about to force-reset
          # next, putting them in conflict with what we're rebasing forward.
          # update-flake-inputs will recreate fresh PRs against the new next.
          curl -s \
            -H "Authorization: token $GITEA_TOKEN" \
            "$GITEA_URL/api/v1/repos/$GITEA_REPO/pulls?state=open&base_branch=next" \
            | jq -r '.[] | select(.head.ref | startswith("update-")) | .number' \
            | while read -r PR_NUM; do
              echo "Closing stale update-* PR #$PR_NUM"
              curl -s -X PATCH \
                -H "Authorization: token $GITEA_TOKEN" \
                -H "Content-Type: application/json" \
                -d '{"state":"closed"}' \
                "$GITEA_URL/api/v1/repos/$GITEA_REPO/pulls/$PR_NUM" > /dev/null
            done

          # Reset next to main
          git push origin origin/main:refs/heads/next --force

          # Try to squash-merge the old next changes onto main
          # If this fails (e.g. merge conflict) or produces no diff, next is
          # already reset to main and the next-exclusive commits are dropped
          git checkout origin/main
          if ! git merge --squash "$NEXT_REF"; then
            echo "Merge conflict, next has been reset to main"
            exit 0
          fi
          if git diff --cached --quiet; then
            echo "Squash merge produced no changes, next has been reset to main"
            exit 0
          fi
          git commit -m "flake: bump inputs"

          # Force push the rebase branch
          git push origin HEAD:refs/heads/next-rebase --force

          # Check for existing open PR from next-rebase to next
          PR_NUMBER=$(curl -s \
            -H "Authorization: token $GITEA_TOKEN" \
            "$GITEA_URL/api/v1/repos/$GITEA_REPO/pulls?state=open&base_branch=next" \
            | jq -r '[.[] | select(.head.ref == "next-rebase")] | .[0].number')

          if [ -z "$PR_NUMBER" ] || [ "$PR_NUMBER" = "null" ]; then
            # Create PR using tea CLI
            tea logins add \
              --name gitea \
              --url "$GITEA_URL" \
              --token "$GITEA_TOKEN" \
              --no-version-check

            PR_URL=$(tea pulls create \
              --login gitea \
              --repo "$GITEA_REPO" \
              --head next-rebase \
              --base next \
              --title "flake: bump inputs" 2>&1 | tail -1)

            echo "Created PR: $PR_URL"
            PR_NUMBER=$(echo "$PR_URL" | grep -oP '/pulls/\K[0-9]+')
          else
            echo "Reusing existing PR #$PR_NUMBER"
          fi

          # Enable auto-merge. Retry on 405 "Please try again later" — Gitea
          # returns this while the mergeable status is recomputed after a
          # push. 409 means a schedule is already active (survives force-push,
          # since Gitea only clears it via explicit cancel), so treat as ok.
          for attempt in 1 2 3 4 5; do
            HTTP_BODY=$(curl -sS -w $'\n%{http_code}' -X POST \
              -H "Authorization: token $GITEA_TOKEN" \
              -H "Content-Type: application/json" \
              -d '{"merge_when_checks_succeed":true,"delete_branch_after_merge":true}' \
              "$GITEA_URL/api/v1/repos/$GITEA_REPO/pulls/$PR_NUMBER/merge")
            HTTP_CODE=$(printf '%s' "$HTTP_BODY" | tail -n1)
            BODY=$(printf '%s' "$HTTP_BODY" | sed '$d')

            case "$HTTP_CODE" in
              200|201)
                echo "Auto-merge enabled for PR #$PR_NUMBER"
                exit 0
                ;;
              409)
                echo "Auto-merge already scheduled for PR #$PR_NUMBER"
                exit 0
                ;;
              405)
                if echo "$BODY" | grep -q "Please try again later"; then
                  echo "Mergeable check not ready (attempt $attempt/5), retrying in 2s..."
                  sleep 2
                  continue
                fi
                ;;
            esac

            echo "Failed to enable auto-merge for PR #$PR_NUMBER: HTTP $HTTP_CODE $BODY" >&2
            exit 1
          done

          echo "Auto-merge not enabled for PR #$PR_NUMBER after 5 attempts" >&2
          exit 1
        '';
      };
    };
}
