#!/usr/bin/env bash

tld=${PWD};
export tld;

echo -e "\n[INFO] Verifying required dependencies are installed..."
which python2 || { echo -e "Please ensure Python 2.7 is installed and in your path." && exit 1; }
which virtualenv || { echo -e "Please ensure virtualenv is installed and in your path." && exit 1; }
which pip || { echo -e "Please ensure pip is installed and in your path." && exit 1; }
which git ||  { echo -e "Please install latest version of git CLI with package manager." && exit 1; }
which meld ||  { echo -e "Please install latest version of meld with package manager." && exit 1; }

refresh_venv() {

  for repo in ${tld}; do
    echo -e "\n[INFO] Verifying that dev-ranger is up-to-date..."
    cd ${tld} \
    && git config --replace-all merge.tool meld \
    && git stash \
    && git pull github-origin master \
    && git mergetool \
    && git pull github-upstream master \
    && git mergetool \
    && git stash apply;
    cd ${tld};
  done

  echo;
  read -p "Ensure you \"deactivate\" any venvs before proceeding. Hit [CTRL]+[C] to cancel; or [ENTER] to continue."

  echo -e "\n[INFO] Verifying dev-ranger virtualenv (dr-env)..."
  which deactive 2>/dev/null && deactivate;
  mkdir -p dr-env/;
  cd dr-env/ \
  && /usr/bin/virtualenv --always-copy --unzip-setuptools ./ \
  && source bin/activate \
  && for dep in ansible \
                ansible-review \
                ansible-cmdb \
                ansible-toolbox \
                shade \
                grip;
     do
         pip install --upgrade ${dep};
     done \
  && virtualenv --relocatable ./;

  echo;
  read -p "Please run \"source ./dr-env/bin/activate\" to use your venv. Hit [ENTER] to acknowledge."
}

refresh_repo_list() {
  echo;
  read -rp "Please enter your Github username: "
  github_username=${REPLY};
  export github_username;
  cd ${tld};

  echo -e "\n[INFO] Verifying playbooks directory..."
  git clone git@github.com:AFCYBER-DREAM/ansible-playbooks.git playbooks/;
  cd playbooks/;
  git remote remove origin;
  git remote add github-upstream git@github.com:AFCYBER-DREAM/ansible-playbooks.git;
  git remote add github-origin git@github.com:${github_username}/ansible-playbooks.git;
  cd ${tld};

  echo -e "\n[INFO] Verifying inventory directory..."
  git clone git@github.com:AFCYBER-DREAM/ansible-inventory.git inventory/;
  cd inventory/;
  git remote remove origin;
  git remote add github-upstream git@github.com:AFCYBER-DREAM/ansible-inventory.git;
  git remote add github-origin git@github.com:${github_username}/ansible-inventory.git;
  cd ${tld};


  echo -e "\n[INFO] Verifying dev-ranger directory..."
  git remote remove origin;
  git remote add github-upstream git@github.com:AFCYBER-DREAM/dev-ranger.git;
  git remote add github-origin git@github.com:${github_username}/dev-ranger.git;

  mkdir -p roles/;
  for git_repo in director \
                  cephadmin \
                  osp-rbac \
                  nginx \
                  teaming \
                  repos \
                  global_base \
                  authentication \
                  artifactory \
                  postgresql \
                  ansible-role-nfs;
  do
      echo -e "\n[INFO] Verifying ${git_repo}  directory..."
      git clone git@github.com:AFCYBER-DREAM/${git_repo}.git roles/${git_repo} \
      && cd roles/${git_repo} \
      && git remote remove origin \
      && git remote add github-upstream git@github.com:AFCYBER-DREAM/${git_repo}.git \
      && git remote add github-origin git@github.com:${github_username}/${git_repo}.git;
      cd ${tld};
  done

  echo;
  read -p "Please manually fork each newly cloned repo from the web-interface, then hit [ENTER] to continue."
}

refresh_repo_content() {
  cd ${tld};
  for role in $(find roles/ -mindepth 1 -maxdepth 1 -type d); do
    echo -e "\n[INFO] Verifying that ${role} is up-to-date...";
    cd ${role} \
    && git config --replace-all merge.tool meld \
    && git stash \
    && git pull github-origin master \
    && git mergetool \
    && git fetch github-upstream master \
    && git mergetool \
    && git stash apply;
    cd ${tld};
  done

  for repo in ./playbooks/ ./inventory/; do
    echo -e "\n[INFO] Verifying that ${repo} is up-to-date..."
    cd ${repo} \
    && git config --replace-all merge.tool meld \
    && git stash \
    && git pull github-origin master \
    && git mergetool \
    && git fetch github-upstream master \
    && git mergetool \
    && git stash apply;
    cd ${tld};
  done
}

case ${1} in
  --venv)
    refresh_venv
    ;;
  --repolist)
    refresh_repo_list
    ;;
  --repocontent)
    refresh_repo_content
    ;;
  *)
    refresh_venv
    refresh_repo_list
    refresh_repo_content
    ;;
esac

