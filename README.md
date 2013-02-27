ruzzle-solver
=============

Quick and dirty script to solve puzzles from the [Ruzzle app](https://play.google.com/store/apps/details?id=se.maginteractive.rumble.free&hl=en). Made as a programming exercise, not to cheat (I promise!)

Requirements
---
* A dictionary file `dictionary.txt` in the same directory as the script, containing valid words separated by newlines.

That's it! [Here](https://code.google.com/p/scrabblehelper2/source/browse/trunk/src/scrabble/dictionary.txt?r=3) is a good place to look for a dict file.

On a first run, the script will index your dictionary file into a more easily searchable tree, and dump that object into a file creatively named `marshal_tree` for quicker loading later. Make sure to delete that file if you switch dictionaries!
