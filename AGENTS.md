# Local project and repository workflow

- Project directory: `/Users/perryshao/Documents/Projects/TSSM`
- GitHub checkout: `/Users/perryshao/Documents/GitHub/repositories/Temporal-Self-Similarity-Description`

Keep both directories as independent copies. After editing project source, build
configuration, or documentation, synchronize the files changed by the task into
the other copy before reporting completion. Compare affected files first; if they
differ, preserve and reconcile both versions without overwriting unrelated edits.
Propagate intentional additions, edits, renames, and deletions only. Do not use a
blanket mirror with deletion. Verify synchronized file hashes.

Never synchronize `.git` metadata, credentials, caches, or generated experiment
outputs. Keep raw datasets, papers, and historical research assets in their
existing local locations unless the user explicitly requests moving them.
Use the GitHub checkout for requested commits and pushes. Synchronization alone
does not authorize automatically committing or pushing.
