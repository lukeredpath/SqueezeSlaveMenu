# SqueezeSlaveMenu for OSX

SqueezeSlaveMenu is a small menu-bar applet for controlling [SqueezeSlave](http://wiki.slimdevices.com/index.php/SqueezeSlave), a command-line tool that can be used to turn your Windows, Mac or Linux computer into a Squeezebox device.

## Compiling on Snow Leopard

Before you can compile the app in Xcode, you will need to prepare the squeezeslave library, which is referenced as a git submodule (pointing at my Github mirror of the original Subversion repository).

First, initialize the sub-module:

    $ git submodule update --init --recursive
    
Then, use make to compile the necessary static libraries:

    $ cd External/squeezeslave
    $ make -f makefile.osx-intel-display realclean
    $ make -f makefile.osx-ppc-display realclean
    $ make -f makefile.osx-i64-display realclean
    $ make -f makefile.osx-i64-display
    
You should only have to do this once. You should now be able to open the Xcode project and compile and run the app.

## License

This application is licensed under the same terms as the original squeezeslave library, GPLv2.