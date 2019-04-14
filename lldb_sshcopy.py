# This script adds an 'sshcopy' command (a fish shell function that I define
# in my config.fish file) to lldb.
#
# To use it, first import the script from your lldb prompt, then run the
# 'sshcopy' command, followed by an lldb command that produces output to
# stdout or stderr:
#
#     (lldb) command script import ~/Source/system/dotfiles/lldb_sshcopy.py
#     (lldb) sshcopy e printf("Hello, world!\n")
#
# This copies the output to the SSH client machine's macOS pasteboard. This is
# handy when using lldb on a remote machine. For example, you can dump a large
# LLVM IR basic block to your local machine's pasteboard, like so:
#
#     (lldb) sshcopy e BB->dump()
#
# Tested on lldb trunk at the time of this writing.


import os
import subprocess
import tempfile


# NB: lldb Python API documentation available at:
# https://lldb.llvm.org/python_reference/index.html


class OutFile:
    def __init__(self):
        fd, self.name = tempfile.mkstemp()
        self.buffer = os.fdopen(fd, 'a')

    def __del__(self):
        os.unlink(self.name)


def sshcopy(debugger, command, result, dictionary):
    # type: (lldb.SBDebugger, lldb.SBCommandReturnObject, dict) -> None

    # Print metadata to temporary file buffers:
    # The arguments passed to the lldb invocation...
    debugger.GetCommandInterpreter().HandleCommand(
        'settings show target.run-args', result)
    settings_out = result.GetOutput()

    # ...the backtrace...
    debugger.GetCommandInterpreter().HandleCommand('bt', result)
    backtrace_out = result.GetOutput()

    # ...the frame at which lldb is stopped...
    debugger.GetCommandInterpreter().HandleCommand('frame select', result)
    frame_out = result.GetOutput()

    # ...and last, but most importantly, the output from the command that
    # follows the 'sshcopy' command.
    cmd_out = OutFile()
    debugger.SetOutputFileHandle(cmd_out.buffer, False)
    debugger.HandleCommand(command)
    cmd_out.buffer.close()
    # Reset the output file handle.
    # FIXME: Ideally this would set the file back to what it was set to
    #        originally. I can't figure out how to make this work; the script
    #        hangs indefinitely when I try to do the following:
    #
    #            orig_out = debugger.GetOutputFileHandle()
    #            # ...
    #            debugger.SetOutputFileHandle(orig_out, False)
    debugger.SetOutputFileHandle(None, False)

    # Print all the output into a temporary buffer file...
    buffer = tempfile.NamedTemporaryFile()
    with open(buffer.name, 'w') as dest:
        dest.write('===== Arguments =====\n')
        dest.write(settings_out)
        dest.write('\n\n')
        if backtrace_out:
            dest.write('===== Backtrace =====\n')
            dest.write(backtrace_out)
            dest.write('\n\n')
        if frame_out:
            dest.write('===== Frame =====\n')
            dest.write(frame_out)
            dest.write('\n\n')
        dest.write('===== Command =====\n')
        dest.write(command + '\n\n\n')
        with open(cmd_out.name, 'r') as src:
            dest.write('===== Output =====\n')
            dest.write(src.read())
            dest.write('\n\n')

    # ...then pipe the buffer file into 'sshcopy'. Because this is a fish shell
    # function defined in my config.fish, the shell= and executable= arguments
    # are necessary to find it.
    with open(buffer.name, 'r') as buffer:
        scp = subprocess.Popen(['sshcopy'], stdin=buffer, shell=True, executable='fish')
        scp.wait()
        buffer.flush()

    # Finally, clear the lldb return object. Otherwise, the sshcopy command will
    # output the result from the last command -- in this case, the output from
    # 'frame select'.
    result.Clear()


def __lldb_init_module(debugger, dictionary):
    # type: (lldb.SBDebugger, dict) -> None
    debugger.HandleCommand(
        'command script add -f lldb_sshcopy.sshcopy sshcopy ')
