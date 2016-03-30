## [Solidus Guides](http://ashkamel.com/solidus-guides/)

This is a repo containing the
[CFPB/DOCter](https://github.com/CFPB/DOCter) and [18F/guide](https://github.com/18F/guides-template/)-based
[Jekyll](http://jekyllrb.com/) template for
[Solidus Guides](http://ajkamel.github.io/solidus-guides/).

### Getting started



#### Installing Ruby

You will need [Ruby](https://www.ruby-lang.org) ( > version 2.1.5 ). To check
whether it's already installed on a UNIX-like system, open up a terminal
window (e.g. Terminal on OS X) and type `ruby -v` at the command prompt. For
example, you should see something similar to the following:

```shell
$ ruby -v
ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]
```

If the version number is less than 2.1.5, or instead you see something like:

```shell
$ ruby -v
-bash: ruby: command not found
```

Then Ruby is not installed, and you should choose one of the installation
methods below. [The "Installing Ruby" page of the official
Ruby language web
site](https://www.ruby-lang.org/en/documentation/installation/) explains how
to do this in a number of ways across many different systems.

##### Quickest Ruby install/upgrade for OS X

On OS X, you can use [Homebrew](http://brew.sh/) to install Ruby in
`/usr/local/bin`, which may require you to update your `$PATH` environment
variable:

```shell
$ brew update
$ brew install ruby
```

##### Optional: using a version manager

Whether or not Ruby is already installed, we strongly recommend using a Ruby
version manager such as [rbenv](https://github.com/sstephenson/rbenv) or
[rvm](https://rvm.io/) to help ensure that Ruby version upgrades don't mean
all your [gems](https://rubygems.org/) will need to be rebuilt.

#### Serving the Guides Template locally


The `./go` script will check that your Ruby version is supported, install the
[Bundler gem](http://bundler.io/) if it is not yet installed, install all the
gems needed by the template, and launch a running instance on
`http://localhost:4000/`.

`./go serve --baseurl ''`


#### Deploying to Github pages

To deploy to github pages you need to push the site files to its own gh-pages branch if you want it as a project page. Check that your `baseurl` in `config.yml` matches the repo name.

`./go serve`

`cd _site/`

`git init`

`git add remote origin git@githubrepo`

`git checkout -b gh-pages`

`git add .`

`git commit`

`git push origin gh-pages`
