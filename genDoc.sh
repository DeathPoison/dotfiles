find . | grep '\.nim$' | while read line; do nim doc $line; done
