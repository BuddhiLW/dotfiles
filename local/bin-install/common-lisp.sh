#!/bin/sh

## Install a CL implementation
echo "Install a CL implementation"
yay -S sbcl

## Install quicklisp
echo "install quicklisp, the library manager for Common Lisp.\n"

echo "Download quiclisp in a temporary file.\n"
curl -o /tmp/ql.lisp http://beta.quicklisp.org/quicklisp.lisp

echo "Installing and setting up quicklisp to always be available.\n"
sbcl --no-sysinit --no-userinit --load /tmp/ql.lisp \
       --eval '(quicklisp-quickstart:install :path "~/.quicklisp")' \
       --eval '(ql:add-to-init-file)' \
       --quit


echo "You probably want =Slime=. If you do, type [y]. Else, [n]."
read answer
if [ ${answer} = "y" ]
then
    sbcl --eval '(ql:quickload :quicklisp-slime-helper)' \
	 --quit
    echo "Ok, quickload installation went off."
fi

echo "You are good to go! 
     Use =Sly= on Emacs, or configure =Slime=."
