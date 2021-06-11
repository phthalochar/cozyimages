# cozyimages
Scripts to automatically crop and scale screengrabs from Cozy Grove to produce 200x200 icons for wiki.

Created by Geneva

The primary script is cozyimages.sh, a bash script that relies on Imagemagick to process a flat folder/directory
of source images to produce a flat folder/directory of 200x200 icon images.  See the script source for usage, or run ./cozyimages.sh -h

Also include are snarf.sh, a script to traverse a complex directory of images and pull them into a single flat folder/directory for the 
purposes of being processed by cozyimages.sh
