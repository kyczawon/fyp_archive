#!/bin/bash

text=$(printf '%s%%s' ${@})  # concatenate and replace spaces with %s
text=${text%%%s}  # remove the trailing %s
text=${text//\'/\\\'}  # escape single quotes
text=${text//\"/\\\"}  # escape double quotes
echo $text