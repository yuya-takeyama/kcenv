# kcenv

[kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) version manager.

Most of the codes are taken from below tools:

* [rbenv](https://github.com/rbenv/rbenv)
* [tfenv](https://github.com/Zordrak/tfenv)

## Installation

1. Check out kcenv into any path (here is `${HOME}/.kcenv`)

  ```sh
  $ git clone https://github.com/yuya-takeyama/kcenv.git ~/.kcenv
  ```

2. Add `~/.kcenv/bin` to your `$PATH` any way you like

  ```sh
  $ echo 'export PATH="$HOME/.kcenv/bin:$PATH"' >> ~/.bash_profile
  ```

## Usage

```
Usage: kcenv <command> [<args>]

Some useful kcenv commands are:
   local       Set or show the local application-specific kubectl version
   global      Set or show the global kubectl version
   install     Install the specified version of kubectl
   uninstall   Uninstall the specified version of kubectl
   version     Show the current kubectl version and its origin
   versions    List all kubectl versions available to kcenv

See `kcenv help <command>' for information on a specific command.
For full documentation, see: https://github.com/yuya-takeyama/kcenv#readme
```

## License

* kcenv
  * The MIT License
* [rbenv](https://github.com/rbenv/rbenv)
  * The MIT License
* [tfenv](https://github.com/Zordrak/tfenv)
  * The MIT License
