# On The Edge CSV Exporter

This is a tool that takes in and parses the card list for the On The Edge card game (credits go to [cosine on BGG](https://boardgamegeek.com/filepage/92908/on-the-edge-complete-cards-list))

The script includes a PEG parser definition for the file as well as a matching CLOS class and a csv output function

Most of the work was done in REPL so the code is undocumented, spread out and messy.

https://boardgamegeek.com/filepage/92908/on-the-edge-complete-cards-list


## Running
`sbcl --script main.lisp`

Libraries were loaded via Nix so there's no system configured
