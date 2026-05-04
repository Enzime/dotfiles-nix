{
  perSystem =
    { pkgs, ... }:
    {
      packages.gitea-squash-next = pkgs.writeShellApplication {
        name = "gitea-squash-next";
        runtimeInputs = builtins.attrValues { inherit (pkgs) git; };
        text = ''
          git config user.name hyperbot
          git config user.email hyperbot@clan.lol

          git fetch origin main next

          # Skip if next is already exactly 1 commit ahead of main (already squashed)
          commit_count=$(git rev-list --count origin/main..origin/next)
          if [ "$commit_count" -le 1 ]; then
            echo "next is $commit_count commit(s) ahead of main, nothing to squash"
            exit 0
          fi

          # Check there are actual tree differences
          if git diff --quiet origin/main origin/next; then
            echo "No tree differences between main and next, resetting next to main"
            git push origin origin/main:refs/heads/next --force
            exit 0
          fi

          # Squash all changes into a single commit on top of main
          git checkout origin/main
          git merge --squash origin/next
          git commit -m "flake: bump inputs"

          git push origin HEAD:refs/heads/next --force
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

          # Reset next to main
          git push origin origin/main:refs/heads/next --force

          # Try to squash-merge the old next changes onto main
          # If this fails (e.g. merge conflict), next is already reset to main
          git checkout origin/main
          if ! git merge --squash "$NEXT_REF"; then
            echo "Merge conflict, next has been reset to main"
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

          curl -s -X POST \
            -H "Authorization: token $GITEA_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"merge_when_checks_succeed":true,"delete_branch_after_merge":true}' \
            "$GITEA_URL/api/v1/repos/$GITEA_REPO/pulls/$PR_NUMBER/merge"

          echo "Auto-merge enabled for PR #$PR_NUMBER"
        '';
      };
    };
}
