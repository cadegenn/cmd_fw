[![latest release](https://img.shields.io/github/release/cadegenn/cmd_fw.svg)](../../releases/latest)
[![license](https://img.shields.io/github/license/cadegenn/cmd_fw.svg)](LICENSE)

<img align="left" width="64" height="64" src="images/cmd_fw.png">

# Tiny %COMSPEC% Framework

`cmd_fw` is a (very) simple %COMSPEC% Framework. Its purpose is to ease scripting in native DOS / Windows command language. This framework helps in writing scripts faster with already accessible variables, builtin functions and debugging facilities.

## Requirements

- command prompt

## How to use

- Download and install latest release from here [![latest release](https://img.shields.io/github/release/cadegenn/cmd_fw.svg)](../../releases/latest)
- copy `skel.cmd` from `%ProgramFiles%\Tiny COMSPEC Framework` to your script repository and rename it as you like
- start coding between tags

```cmd
rem #############################
rem ## YOUR SCRIPT BEGINS HERE ##
rem #############################
```

and

```cmd
rem #############################
rem ## YOUR SCRIPT ENDS   HERE ##
rem #############################
```

Checkout the [`demo.cmd`](./demo.cmd) script !

## Common parameters

The `skel.cmd` skeleton script already take care of some common parameters :

- -q : quiet mode. It disable every output, even if `-v`, `-d` or `-dev` have been specified. Howerver, `-log` is honored correctly.
- -v : verbose -> display more messages, in particular `everbose` calls
- -d : enable debug mode -> display more thing, in particular `edebug` calls
- -dev : enable development mode -> used to display `KEY=value` pairs with `edevel` calls. Also display entering and leaving functions.
- -log : create a log file and log every call to `e*` functions

In the root folder of your script, put a copy of api.cmd.
Then, put this near the top of your script :

## Examples

Display informations on output

```cmd
call einfo An information message
call everbose Additional verbose message
call ewarn PAY ATTENTION TO THIS MESSAGE
```

More advanced example

```cmd
rem read a value from registry
call regread HKLM\Software\7-Zip Path
set 7ZIP=%REGDATA%
call edevel 7ZIP = !7ZIP!
```
