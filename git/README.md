# Git stuff

Git commands

## Random

### Quick squash

```
git reset --soft `git merge-base origin/master feature/my-branch`
git add -A
git commit
git push origin HEAD --force-with-lease
```

### Re-root a git repo

Imagine you have a repo of:

```
cool-project
├── backend
│   └── foo.py
└── frontend
    └── bar.py
```

And you copy the repo into a new folder called `cool-project-backend`. Delete `frontend` and then run:

```
git filter-branch --prune-empty --index-filter 'git ls-files | grep -vE "backend" | xargs git rm -rf --cached --ignore-unmatch'
```

This should reparent the project and remove the superfulous `./backend` directory that is now replaced by the root.
