# Matrix Admin Panel
This is a tool that aims to provide easy [admin api](https://matrix-org.github.io/synapse/latest/usage/administration/admin_api/) access to [Matrix Synapse](https://matrix.org/) homeserver admins. This is a terminal user interface written in Python 3.10.

## Table of contents
* [FAQ](#faq)
* [Features](#features)
* [Instsallation](#installation)
* [Usage](#usage)
* [License](#license)
* [Contributing](#contributing)

## FAQ
**Q**: *Why python for such a simple tool?*\
**A**: This was first intended to be written in *bash*, however matrix synapse api provides json responses which are easier to handle in python, and python provides compatibility with non unix platforms.

**Q**: *What happens with my authentication token?*\
**A**: I know that entering your matrix  account's authentication token in a random script online is not the best security practice, however the token is never stored on disk nor uploaded anywhere, and is read silently from stdin (check [main.py]())

**Q**: *I did a mistake and accidentally deleted/deactivated a room/user account...*\
**A**: Such actions are permanent actions and cannot be reverted. Please **double check**  before executing any action with this tool. I am not responsible for what goes wrong with it. Also **note that this tool is still heavily untested**, so bugs may occur which can negatively affect your homeserver. If you found any bug, please create an issue and I will try to get it fixed asap.

**Q**: *Is there a CLI alternative to this tool?*\
**A**: I am planning on creating a CLI version in the near future.

## Features
#### Users
* List registered users on the homeserver
* Search for a registered user
* Deactivate an user account

#### Registration tokens
* Create registration token
* List active registration tokens
* Delete a registration token

#### Rooms
* List all rooms created on the homeserver
* Search for a room on the homeserver
* Delete/Purge/Block a room

## Installation
#### Requirements
* Python >= 3.10.2
* Pip >= 21.0
* pip requirements (see `requirements.txt`)

For installation, follow the steps:
```bash
git clone https://github.com/Stefan9110/matrix-admin-panel.git 
cd matrix-admin-panel
./install.sh
```
Currently there is an install script only for unix based systems.


#### Manual installation
Copy the following files & directories into a directory of your choosing:
* `clioptions.py`
* `color.py`
* `main.py`
* `commands.py`
* `menu.py`
* `install.sh`
* `.git/`

Create a symlink / shortcut to `main.py` in a directory from `PATH`.

Alternatively, you can run the program using `python main.py`.

#### Uninstalling
```bash
/opt/matrix-admin-cli/install.sh -r
```
This may be different depending on the changes you made to the `install.sh` script yourself. 

#### Updating
```bash
/opt/matrix-admin-cli/install.sh -u
```

## Usage
After installation, you can run the tool using `matrix-admin` in the command line. For a list of options use `matrix-admin -h`. After running, enter your [auth-token](#authentication-tokens) and matrix homeserver url (can be also provided with the `-u` option).

You will be prompted with a menu like so:
![Img](https://i.imgur.com/2NW0zIq.png)

Simply choose an option and enter the required fields (if needed).\
Note that options in **red** will not work, since they are not yet implemented.

#### Authentication tokens
An authentication token is required to access the admin api. It is safer to use an authentication token instead of username + password, because it can be reset simply by logging out of that session.

You can obtain your authentication token in [Element client](https://element.io/) by going to `Settings -> Help & About -> Advanced -> Access Token`.

## License
This project is licensed under the GNU General Public License v3.0. See the `LICENSE` file for more details.

## Contributing
Contributing is highly appreciated. Any bug fixes or implementation improvements can go straight into a pull request. If you want to implement an extra feature, please create a **feature request** issue first.
