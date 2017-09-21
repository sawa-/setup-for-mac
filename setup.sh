#!/bin/bash

# constants
BREW_DIR="./brew-settings"
BREW_TAP_LIST="brew-tap-list"
BREW_LIST="brew-list"
BREW_CASK_LIST="brew-cask-list"


# functions
has() {
  type "$1" > /dev/null 2>&1
}

callstart() {
  printf "\e[33m(*'-')<\e[m Start: $*...\n"
}

callinstall() {
  printf "\e[32m Install:\e[m $*...\n"
}

callskip() {
  printf "\e[34m Skip:\e[m $*\n"
}

setup_prezto() {
  callstart "install prezto"
  if [ ! -d ~/.zprezto ]; then
    callinstall "prezto"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md; do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
    chsh -s /bin/zsh
  else
    callskip "already installed prezto"
  fi
}

setup_homebrew() {
  install_homebrew &&
  install_homebrew_tap &&
  install_homebrew_packages &&
  install_homebrew_cask_packages
}

install_homebrew() {
  if has "brew"; then
    callskip "already installed homebrew. updating & cleanup homebrew..."
    brew upgrade --cleanup
  else
    callstart "install homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

install_homebrew_tap() {
  callstart "brew tap"
  for tap in `cat $BREW_DIR/$BREW_TAP_LIST`; do
    if brew tap | grep -q "^$tap"; then
      callskip "already installed ${tap}"
    else
      callinstall $tap
      brew tap $tap
    fi
  done
}

install_homebrew_packages() {
  callstart "brew install packages"
  for package in `cat $BREW_DIR/$BREW_LIST`; do
    if brew list -1 | grep -q "^$(basename $package)"; then
      callskip "already installed ${package}"
    else
      callinstall $package
      brew install $package
    fi
  done
}

install_homebrew_cask_packages() {
  callstart "brew cask install packages"
  for cask in `cat $BREW_DIR/$BREW_CASK_LIST`; do
    if brew cask list -1 | grep -q "^$cask"; then
      callskip "already installed ${cask}"
    else
      callinstall $cask
      brew cask install $cask
    fi
  done
}


setup_prezto &&
  setup_homebrew || exit $?

exit

