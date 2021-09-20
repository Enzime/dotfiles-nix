# Usage

## 1. Install Nix

### Debian

Make sure to log out and back in after changing your groups

```sh
$ sudo apt install nix
$ sudo usermod -aG nix-users enzime
```

## 2. Install home-manager

https://github.com/nix-community/home-manager#installation

You can follow these steps, but they may be out of date:

```sh
$ nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
$ nix-channel --update
$ nix-shell '<home-manager>' -A install
```

## 3. Set up home

Run this command each time before `home-manager` is properly set up to ensure your `PATH` is correct:

```sh
$ export PATH=~/.nix-profile/bin:$PATH
```

Ensure `~/.config/nixpkgs/home.nix` is correct and then run:

```
$ home-manager switch
```

Ensure `~/.zshrc` was generated correctly, then log out and back in to verify everything is working
