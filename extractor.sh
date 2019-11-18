#!/bin/bash


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
  
  echo ${YELLOW} "Initializing Id_mapping file"
  
  idmapping_dir=$(find . -name idmapping_selected.tab -printf '%h\n') 

  $(find . -name ppi_interactions.txt | grep -q ".")
  if [ $? = 0 ]
  then
    echo ${WHITE} 
    echo "idmapping_selected_clean.tab file found"


    if [ -n "$(ls -A "$idmapping_dir/"small-chunks/ 2>/dev/null)" ]
    then
      # Sort smaller files
      echo "Sorting file chunks..."
      for X in "$idmapping_dir/"small-chunks/*
      do 
        echo "Sorting $X"
        echo $(sort -k1 -n -m $X >> "$idmapping_dir/"idmapping_selected_sorted.tab)
      done 

      #echo "Chunking sorted files..."
      #$(sort -k1 -n -m sorted-small-chunk* > "$idmapping_dir/"idmapping_sorted_selected.tab)

      echo "Removing file chunks..."
      $(rm -r "$idmapping_dir/"small-chunks)
    else {
      # Break big file into smaller files
      echo "Truncating file into smaller chunks..."
      $(mkdir -p "$idmapping_dir/small-chunks" && split -l 2000000 "$idmapping_dir/idmapping_selected_clean.tab" "$idmapping_dir/small-chunks/small-chunk-")
    }
    fi
  else 
    echo "Extracting required data from idmapping_selected.tab..."
    $(cat datasets/idmapping/idmapping_selected.tab | awk -F '\t' '{ print $3,"\t",$1,"\t",$2 }' >> $idmapping_dir/idmapping_selected_clean.tab)
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
    read -p "Enter Protein Name [Alias] or ID: " ans
   # Output | Pattern matching for protein | Output Column 2 only | Print 1st Alias only | Print non matching proteins only | Remove dashes
    echo ${YELLOW} "$(cat "ppi_interactions.txt" | grep -i -w $ans | awk -F '\t' '{ print $2,"\t",$4 }' | sed 's/|.*//' | grep -i -v -e $ans | awk -F- 'NF<=1')"
}
# ---------------------------------------------------------------------------------

_search_cross_references() {}

_menu() {
  # $1 checking 1st argument - menu choice
  if [ "$1" = 1 ] 
  then
    _search_gene
  else
    echo "This feature has not been implemented yet!"
  fi
}

_init_project 
echo "------ -- Protein-to-Protein Query Console -- -------"
echo "|       1. Query PPI using Protein ID/Alias         |"
echo "|       2. xxxxx xxx xxxxx xxxxxxx xxxxx            |"
echo "------ -------------------------------------- -------"
read -p "Enter Choice: " choice
_menu "$choice"
