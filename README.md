# dev-ranger
Used to bootstrap the ansible virtualenv needed to manage our development ranges.

Purpose
-------

This tool automates some of the management tasks associated with the DREAM Team ansible repositories.

Installation
------------

If you have yet to download `dev-ranger`, `cd` to the directory you want it to live in, and then clone it.

```
cd ~/my_projects;
git clone https://github.com/AFCYBER-DREAM/dev-ranger.git;
cd ~/my_projects/dev-ranger;
```

Next, you'll want to run the `dev-ranger-up.sh` script to install the venv, playbooks, inventory, and roles associated with the dev ranges.

```
chmod +x ./dev-ranger-up.sh
./dev-ranger-up.sh
```
During the install process, you will be prompted to manually fork all the repositories that were just cloned.
If you don't have `golang` and `hub` installed, you will either have to call the Github API in another way,
or you will have to log into the web-interface and manually fork all the cloned repositories into your personal Github account.
If you have `hub`, just use the `hub fork` subcommand which does this for you. For example:

```
hub fork https://github.com/AFCYBER-DREAM/dev-ranger
```

The installer should download the venv into a sub-directory called `dr-env/`, you'll want to activate that venv before running any plays.
This will ensure you have all the libraries and tools you need to manage the repositories and run the playbooks.

```
cd ~/my_projects/dev-ranger/dr-env/
source ./bin/activate
```

Occassionally, you will want to update your venv, playbooks, inventory, and roles based on upstream. See the Usage section for more info.

Usage
----

The `dev-ranger-up.sh` script has three long options:

`./dev-ranger-up --venv` 

This option will refresh dev-ranger and the venv by upgrading all the packages currently inside of it.

`./dev-ranger-up --repolist` 

This option will `git clone` the DREAM Team ansible repositories into the current working directory.

`./dev-ranger-up --repocontent` 

This option will stash, and then fetch any changes from origin and upstream and do merge deconfliction.

