# For Rust projects that use a 'Cargo.toml' at the root of a workspace:
#
#   ln -s \
#       /path/to/dotfiles/.ycm_extra_conf.rust.py \
#       /path/to/project/.ycm_extra_conf.py

import os

def Settings(**kwargs):
    return {
        "ls": {
            "linkedProjects": [
                os.path.join(os.path.dirname(os.path.realpath(__file__)),
                             'Cargo.toml')
            ]
        },
    }
