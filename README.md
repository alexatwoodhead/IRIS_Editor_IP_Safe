# IRIS_Editor_IP_Safe
A Docker appliance pre-installed with VSCode and IRIS Editor plugins and optional VIM style editing without external AI connectivity.

# Rationale
I need an IRIS code editor on Ubuntu:
1. Isolated from internet
2. Work with IRIS on other docker containers on same host
3. No internet connected AI
4. Pre-installed
5. Pre-configured

# Pre-requisites
RDP client. With ubuntu remmina RDP client is likely already installed:

```bash
whereis remmina
```

Grab the docker code and support files.
Build the docker image
```
git clone --depth 1 https://github.com/alexatwoodhead/IRIS_Editor_IP_Safe.git
cd IRIS_Editor_IP_Safe
docker build -t iris_edit .
```

# Bash alias
Context: Host
Add following to host file: ~/.bash_aliases
```
d_iris_edit() {
  if [ $1 == 'run' ]; then
    if [ `docker ps | grep -q "iris_edit"` ] ; then
      echo "docker already running"
    else
      echo "starting docker iris_edit"
      docker run -d -it --rm --name iris_edit --memory=8g --network no-internet --gpus "device=0" -p 3390 iris_edit /bin/bash -c "while true; do sleep 10; done"
      docker exec -it -u root iris_edit /usr/bin/bash -c "echo \"ubuntu:ubuntu\" | chpasswd"
      docker exec -i -u ubuntu iris_edit /usr/bin/bash -c "echo 'PS1=\"\\[\\033[01;31m\\]\\u@iris_edit\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\] \$ \"\' >> ~/.bashrc"
    fi
    dipaddr=$(docker exec -it iris_edit /usr/bin/bash -c "ip addr | grep \"172.19\" | cut -d \" \" -f 6 | cut -d \"/\" -f 1")
    # Launch default web browser to page
    echo "iris_edit was launched on $dipaddr"
  elif [ $1 == 'exec' ]; then
    docker exec -it -u ubuntu iris_edit /usr/bin/bash
    return
  elif [ $1 == 'stop' ]; then
	docker stop iris_edit
  fi
}
```

# Update open host terminal (if needed)
```
source ~/.bash_aliases
```
# Start IRIS Editor appliance
Context: Host terminal
```bash
d_iris_edit run
```
Note:
When the iris edit appliance starts it prints the IP address that it is using to the terminal.
This is useful for confirming the expected IP for RDP client to connect to.
```output
starting docker iris_edit
9c3ed76f76d850bf97844ef4354cf01b258ef3ce8f53d1adce34b1ba538cd487
iris_edit was launched on 172.19.0.2
```
The alias command demonstrates the following run options:

| flag      | value       | comment                                                                                                       |
| --------- | ----------- | ------------------------------------------------------------------------------------------------------------- |
| --memory  | 8g          | It doesn't need to be this much but probably over 1gb                                                         |
| --network | no-internet | This is kind of the point of the appliance. It can't connect to external AI, logging or code parsing services |
| --gpus    | "device=0"  | Editor may need hardware acceleration                                                                         |

The default credential get set to ubuntu:ubuntu when the IRIS editor docker appliance is started.
Feel free to modify the alias script to employ different values or mechanism to update the default account.
# IRIS Editor Terminal session ( direct )
Context: Host terminal
```bash
d_iris_edit exec
```
Note:
When entering direct terminal sessions from host by default the docker would give a white terminal prompt with username and a generated alphanumeric for host name. For example:

```output
irisowner@ee716d36a343:~$ whereami
```
This creates context risk with the host and or confusion with manging other docker container terminal.
Therefore the alias script helps you by changing the remote terminal prompt to:
* Red text for user and hostname
* Useful Host name = iris_edit
* Current directory locaton
For example:
<img width="314" height="58" alt="image" src="https://github.com/user-attachments/assets/5e606066-4338-448e-b459-0a6fc57c9a61" />

# Stop IRIS Editor
Context: Host terminal
```bash
d_iris_edit stop
```
The container is removed and deleted after use. That a feature for how a new container was provisioned in the alias run command.

# RDP to IRIS Editor
With the iris_editor appliance running.
Now launch the RDP editor:
```bash
remmina
```

# A Quick RDP configuration
Create a quick connection configuration.
Ensure the IP address is the same that was printed out when the appliance was started ( "d_iris_edit run" ).
Appliance uses the standard RDP port.
The default password is "ubuntu" unless modified in the d_iris_edit alias command.

![Configure RDP connection](imgs/Remmina_IRIS_EDIT.png)

After RDP logon, should be presented with a desktop with "IRIS Editor" shortcut.

<img width="358" height="447" alt="image" src="https://github.com/user-attachments/assets/1209d384-876f-4193-be7d-41b2d3a980d4" />

Double click on this to start vscode with plugins.

After launching the editor. Click on the InterSystems logo plugin and expand servers.
By default the appliance has two connections (172.19.0.3 ) and (172.19.0.4).

<img width="425" height="473" alt="image" src="https://github.com/user-attachments/assets/f379f4fb-cbc9-4f47-9a47-20ebe154ecde" />

Timesaver:
Note: When an IRIS appliance first runs it has default credentails password.
Login to the System Management Portal direclty from the host to change the default logon BEFORE connecting IRIS Editor to the IRIS service. http://172.19.0.3:52773/iris/csp/sys/UtilHome.csp

<img width="729" height="564" alt="image" src="https://github.com/user-attachments/assets/45850a17-be2e-48d3-a2ce-8a6620066387" />
<img width="932" height="424" alt="image" src="https://github.com/user-attachments/assets/3d63251d-6dd6-4909-b186-381a4819a4a6" />

So continuing, using RDP session withg IRIS Editor connecting to another docker conatiner at 172.19.0.3 ( started after iris_edit appliance ).
If you right click on of these servers and 'edit', the settings file is opened.

<img width="425" height="473" alt="image" src="https://github.com/user-attachments/assets/ee7165b2-17dc-4620-bb2d-bd92ec628dca" />

These connection settings come with the docker image. If you had other standard settings then you could substitute the settings file for the docker build. Alternatively copy different settings configuration when running the "iris_edit run" bash aliases.
The configuration as pre-loaded in the docker image.

<img width="622" height="476" alt="image" src="https://github.com/user-attachments/assets/5d761dfc-9c09-45f2-8e07-9261df0ca17f" />

An example of iris running in a second docker appliance connected to from the iris_edit appliance.
RDP with Editor and looking at some code in the User namespace.

<img width="1034" height="787" alt="image" src="https://github.com/user-attachments/assets/64f8e427-448e-4b83-a418-404bfb48c0b5" />

# Editor Bash start
The IRIS Editor is also able to be started from a bash terminal in within the remote desktop.
The utility of doing this is:
1. Understand limitations and warnings in this configuration
2. Confirm unwanted external connectivty is not occuring.

There is a terminal start shortcut off bottom RDP toolbar

<img width="622" height="476" alt="image" src="https://github.com/user-attachments/assets/4eb2203b-fc21-4b19-8e4c-275b63eee5b5" />

<img width="786" height="488" alt="image" src="https://github.com/user-attachments/assets/7dbfeb65-6c71-4dc4-bcd1-766638584464" />

Example of IRIS Editor launch with some 'not connecting' messages:
<img width="1042" height="866" alt="image" src="https://github.com/user-attachments/assets/2807156f-2bea-4b27-aac4-3bed867097c0" />

# VIM style IRIS editing
In open VSCode Editor, open the command palate:

[Shift] + [Control] + p

Type: "Toggle VIM mode"

Accept the selected option.

Shortcuts reminder with code document in view
* When vim mode is normal '-- NORMAL --' is displayed in lower tool bar.
* When vim mode is insert '-- INSERT --' is displayed
* When vim mode is visual ( selecting text ) then "-- VISUAL --" is displayed
* Press [Escape ESC] key to exit current command and return to "NORMAL" mode. If not in normal, press escape key again.

For default always on when opening vscode update the settings.json file to : "vim.disableExtension": false

| Command | Keys | What it does |
| --- | --- | --- |
| ESC | [ Escape ] | I'm unsure what my command state is. Cancel pending commands and just return me to normal mode |
| u | [ u ] | Undo last change |
| i   | [ i ] | From normal mode enter insert mode to add remove characters |
| a   | [ a ] | From normal mode enter insert mode after current character |
| o   | [ o ] | Open new line below current line and switch to insert mode |
| :e! | [ colon (:)] then [ e ] then [ ! ] then [ ENTER ] | Abandon changes and reload previously saved class definition from database |
| :w | [ colon (:) ] then [ w ] then [ Enter ] | Save and compile
| :q | [ colon (:) ] then [ q ] |- Close current document |
| :q! | [ colon (:) ] then [ q ] then [ ! ] |- Close current document without saving |
| :Ex | [ colon (:) ] then [ Shift ] + [ e ] then [ x ] then [ Enter ] | Switch from edit to Source file Explorer view |

## Copy and Paste
There are two clip boards:
* Use the operating system clipboard to pass content between vscode and external tools.
* Use the operating system clipboard to copy characters from document and paste into search command
* Use the vim clipboard to pass content between document open in vscode

| Command | Keys | What it does |
| --- | --- | --- |
| Shift o   | [Shift] + o | Open new line above current line and switch to insert mode |
| Shift v | [Shift] + [v] | Select line | Select whole line switch to visual mode |
| Shift y | [Shift] + [y] | Copy selected line to vim clipboard |
| Shift p | [Shift] + [p] | Paste line from vim clip board |
| Shift X | [Shift] + [x] | Cut current line |
| v | | Enter visual ( select mode ) on current character |
| y | | Copy selected characters to vim clip board |
| p | | Paste characters from vim clipboard |
| x | | Cut selected characters |
| :+y | [colon (:)] then [plus (+)] then [ y ] | In VISUAL mode, Copy the selected characters to Operating System Clipboard |
| Ctrl v | [ Ctrl ] + [ v ] | When in insert mode. Paste from operating system clipboard<br/> Note this is different because the Shift+Ctrl+v combination by default now opens up IRIS "other code view" for example: "int" code compiled from a class defintion |

## Deleting
| Command | Keys | What it does |
| --- | --- | --- |
| dd | [ d ] then [ d ] | delete current line |
| 3dd | [ 3 ] then [ d ] then [ d ] | delete three code lines including the current one |

## Search and replace
| Command | Keys | What it does |
| --- | --- | --- |
| gd | [ g ] [ d ] | When normal mode and cursor is over class or method to jump to definition |
| O | [ shift ] + [ o ] | Jump back to previous code position or file |
| / | [ / ] | Enter search mode from normal mode |
| /cla | [ / ] then [ c ] then [ l ] then [ a ] | Search for the character sequence "cla" in the current file |
| /method |  | Search for character sequence 'method' in the current file |\
| /[^,]$ | | Find all lines that don't end in a comma |
| n | [ n ] | When in search mode, Move to the next found item |
| Ctrl + n | [ CTRL ] + [ n ] | When in search mode, Move to the previous found item |
| / Up | [ / ] then [ Up key ] | Toggle through previous search commands | 
| :1,10s/ABC/abc/g |  | Replace example: From the first to the tenth line of the source file, replace all character sequences containing "ABC" with "abc" |

## Bookmarks
| Command | Keys | What it does |
| --- | --- | --- |
| :mark a |  | Create a bookmark on the current line called "a" |
| `a | [ back tick (`) ] + [ a ] + [ Enter ] | Jump cursor to source code line with bookmark "a" |
| :marks | | show all my bookmarks |
| :delmarks a | | Delete bookmark "a" |
| :delmarks! | | Delete lowercase bookmarks |
| ] | [ close square bracket (]) ] Jump to previous bookmark |
| [ | [ open square bracket ([\) ] jump to previous bookmark |
| `. | [ back tick (`) ] then [ dot (.) ] + [ Enter ] | An automatic bookmark to where you last edited something. In normal mode use to jump to recent source code line |

## Characters with accents
| Command | Keys | What it does |
| --- | --- | --- |
| ctrl+k e^ | [ Ctrl ] + [ k ] then [ e ] then [ carrot (^) ] | Adds letter ê. An "e" with accent "^" |
| ctrl+k e' | [ Ctrl ] + [ k ] then [ e ] then [ single quote (') | Adds letter é. An "e" with accent "'" |



# Limitations
Web pages do not play well viewed within the Editor. Recommend open system management portal directly from host web browser to the IRIS appliance. For example: http://172.19.0.3:52773/iris/csp/sys/UtilHome.csp





