# Usage

## 1. Install Nix

### Debian

Make sure to log out and back in after changing your groups

```sh
$ sudo apt install nix
$ sudo usermod -aG nix-users enzime
```

### Arch

```sh
$ sudo pacman -S nix
$ sudo systemctl enable nix-daemon.socket
$ sudo systemctl start nix-daemon.socket
$ sudo usermod -aG nix-users enzime
```

## 2. Add Nixpkgs channel

```sh
$ nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
$ nix-channel --update
```

## 3. Clone this repo

```sh
git clone https://github.com/Enzime/dotfiles-nix ~/.config/nixpkgs
```

## 4. Install home-manager

https://github.com/nix-community/home-manager#installation

You can follow these steps, but they may be out of date:

```sh
$ nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
$ nix-channel --update
$ nix-shell '<home-manager>' -A install
```

Ensure `~/.zshrc` was generated correctly, if it was not, run this command after fixing things to regenerate home based of `home.nix`:

```sh
$ home-manager switch
```

Then log out and back in and ensure everything is working

## 5. Update Git remote

Now that everything should be set up, you can update the remote URL:

```sh
git remote set-url origin gh:Enzime/dotfiles-nix
```
