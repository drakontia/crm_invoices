#/bin/bash

if [[ ! "$WORKSPACE" = /* ]] ||
   [[ ! "$PATH_TO_FATFREE" = /* ]] ||
   [[ ! "$PATH_TO_INVOICES" = /* ]];
then
  echo "You should set"\
       " WORKSPACE, PATH_TO_FATFREE, PATH_TO_INVOICES"\
       " environment variables"
  echo "You set:"\
       "$WORKSPACE"\
       "$PATH_TO_FATFREE"\
       "$PATH_TO_INVOICES"
  exit 1;
fi

export PATH_TO_PLUGINS=./vendor/plugins # for fatfree < 2.0
export MIGRATE_PLUGINS=db:migrate:plugins
export FATFREE_GIT_REPO=git://github.com/fatfreecrm/fat_free_crm.git
export FATFREE_GIT_TAG=master

export BUNDLE_GEMFILE=$PATH_TO_FATFREE/Gemfile.ci

clone_fatfree()
{
  set -e # exit if clone fails
  git clone -b master --depth=100 --quiet $FATFREE_GIT_REPO $PATH_TO_FATFREE
  cd $PATH_TO_FATFREE
  git checkout $FATFREE_GIT_TAG
}

run_tests()
{
  # exit if tests fail
  set -e

  cd $PATH_TO_FATFREE

  # Run specs, acceptance tests, and ensure that assets can compile without errors
  bundle exec rake spec
  #bundle exec rake acceptance
  #RAILS_ENV=production bundle exec rake assets:precompile:primary
}

uninstall()
{
  set -e # exit if migrate fails
  cd $PATH_TO_FATFREE
  # clean up database
  bundle exec rake $MIGRATE_PLUGINS NAME=crm_invoices VERSION=0 RAILS_ENV=test
  bundle exec rake $MIGRATE_PLUGINS NAME=crm_invoices VERSION=0 RAILS_ENV=development
}

run_install()
{
# exit if install fails
set -e

# cd to fatfree folder
cd $PATH_TO_FATFREE
echo current directory is `pwd`

# create a link to the invoices plugin
ln -sf $PATH_TO_INVOICES $PATH_TO_PLUGINS/crm_invoices

# install gems
mkdir -p vendor/bundle
echo "gem 'simple_column_search'" >> $BUNDLE_GEMFILE
bundle install --path vendor/bundle --without heroku

# copy database.yml
cp $WORKSPACE/database.yml config/

# run fatfree database migrations
bundle exec rake db:create RAILS_ENV=test
bundle exec rake db:create RAILS_ENV=development
bundle exec rake db:migrate RAILS_ENV=test --trace
bundle exec rake db:migrate RAILS_ENV=development --trace

export PROCEED=true
bundle exec rake ffcrm:setup USERNAME=admin PASSWORD=password EMAIL=admin@example.com

# setup fatfree default data
bundle exec rake ffcrm:demo:load RAILS_ENV=development

# run invoices database migrations
bundle exec rake $MIGRATE_PLUGINS RAILS_ENV=test
bundle exec rake $MIGRATE_PLUGINS RAILS_ENV=development
}

while getopts :ictu opt
do case "$opt" in
  i)  run_install;  exit 0;;
  c)  clone_fatfree; exit 0;;
  t)  run_tests;  exit 0;;
  u)  uninstall;  exit 0;;
  [?]) echo "i: install; c: clone fatfree; t: run tests; u: uninstall";;
  esac
done
