# Inspiration

- `using/X` is based off https://github.com/jonringer/nixpkgs-config

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

### Fix missing root `nixpkgs` channel

If you get warnings like:

```plaintext
warning: Nix search path entry '/nix/var/nix/profiles/per-user/root/channels/nixpkgs' does not exist, ignoring
```

On Arch, remove `nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixpkgs` from `NIX_PATH`

The line in `/etc/profile.d/nix-daemon.sh` should look like:

```sh
export NIX_PATH="/nix/var/nix/profiles/per-user/root/channels"
```

## 3. Set up nixpkgs config

1\. Clone the repo to `~/.config/nixpkgs`

```sh
git clone https://github.com/Enzime/dotfiles-nix ~/.config/nixpkgs
```

2\. Create empty files in `using` based on your current system

Possible files are:

- `i3`
- `gnome`
- `hidpi`

If any are missing here, they will be listed in `.gitignore` or at the top of `home.nix`

3\. Create a file `using/hostname` which contains your hostname e.g.

```plaintext
zeta
```

4\. Create a file `<hostname>.nix` with the contents:

```nix
{...}: {}
```

5\. Create an empty file `~/.zshrc.secrets`

## 4. Install home-manager

https://github.com/nix-community/home-manager#installation

You can follow these steps, but they may be out of date:

```sh
$ nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
$ nix-channel --update
$ nix-shell '<home-manager>' -A install
```

Check that `~/.zshrc` was generated correctly:

```
$ source ~/.zshrc
```

To regenerate the home environment based on any changes to `home.nix`, you can run:

```sh
$ home-manager switch
```

After ensuring that `~/.zshrc` has been generated correctly, log out and back in and ensure everything is working

## 5. Update Git remote

Now that everything should be set up, you can update the remote URL:

```sh
git remote set-url origin gh:Enzime/dotfiles-nix
```
