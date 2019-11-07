#!/bin/bash

# Here we go bois

# Declaring array of Biogrid files
BIOGRID_FILES=$(find . -name biogrid)/*

# Declaring ANSI Escape Codes
# https://en.wikipedia.org/wiki/ANSI_escape_code
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'

# ---------------------------------------------------------------------------------
# Function to Initialize project with necessary files
_init_project () {
  $(find . -name ppi_interactions.txt | grep -q ".")
  # Get exit status code of "$(find . -name ppi_interactions.txt | grep -q ".")"
  if [ $? = 0 ]
  then
    echo ${GREEN} "Interactors file found!"
    echo ${WHITE}
  else 
    echo ${RED} "Interactors file not found!"
    echo ${YELLOW} "Generating Interactors File"
    echo ${WHITE}
    _read_files "$BIOGRID_FILES"
  fi
}
# ---------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------
# Function to merge all Biogrid files and extract aliases for Interactor A & B
_read_files () {
  for f in $1
  do
    echo ${WHITE}
    echo "Parsing $f"
    # Output | Remove entrez label | ID Interactor Col A TAB B TAB Aliases Interactor Col A TAB B | Removing ID & Alias Headings | Removing Synonym labels >> Output_File
    echo $(cat $f | sed 's/entrez[[:blank:]]gene\/locuslink://g' | awk -F '\t' '{ print $1,"\t",$2,"\t" $5,"\t",$6 }' | awk '!/#/' | sed 's/([^)]*)//g' >> ppi_interactions.txt)
    echo ${GREEN} "DONE!"
    echo ${WHITE}
  done
  echo "Cleaning up file..."

  # Removing blank newlines
  # echo $(sed -i '/^$/d' ppi_interactions.txt)
  # echo $(sed '/entrez/,/locuslink/d' ppi_interactions.txt)
  echo ${GREEN} "DONE!"
  echo ${WHITE}
}
# ---------------------------------------------------------------------------------


# ---------------------------------------------------------------------------------
# Function to return Protein-to-Protein Interactions
_search_gene () {
  # Output | Pattern matching for protein | Output Column 2 only | Print 1st Alias only | Print non matching proteins only | Remove dashes
  echo ${YELLOW} "$(cat "ppi_interactions.txt" | grep -i -w $1 | awk -F '\t' '{ print $2 }' | sed 's/|.*//' | grep -i -v -e $1 | awk -F- 'NF<=1')"
  # Output | Pattern matching for protein | Output Column 2 only | Print 2nd Alias only | Print non matching proteins only | Remove dashes
  echo ${GREEN} "$(cat "ppi_interactions.txt" | grep -i -w $1 | awk -F '\t' '{ print $1 }' | sed 's/|.*//' | grep -i -v -e $1 | awk -F- 'NF<=1')"
}
# ---------------------------------------------------------------------------------


_init_project 

read -p "Enter Protein Name [Alias]: " ans
_search_gene $ans