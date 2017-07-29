#!/bin/bash

## declare an array variable
declare -a arr=('-A16M -qb0'
                '-A32M -qb0'
                '-A64M -qb0'
                '-A16M -qg'
                '-A32M -qg'
                '-A64M -qg'
                '-N1 -qg'
                '-N12 -qg'
                '-N16 -qg'
                '-N1 -qb0 -n4m'
                '-N16 -qb0 -n4m'
                '-N12 -qb0 -n4m'
                '-qg'
                )


ELM_PLATFORM_DIR=~/_REPOS_/elm/Elm-Platform
ELM_CSS_DIR=~/_REPOS_/elm-css
ELM_MAKE_BINARY=$ELM_PLATFORM_DIR/0.18/elm-make/dist/dist-sandbox-aff3f82/build/elm-make/elm-make

## now loop through the above array
for i in "${arr[@]}"
do
    COMPILE_OPTIONS=$(echo $i | sed -e 's/\s/_/g')
    echo "----------- removing existing binary" ;
    sudo rm -fv $ELM_MAKE_BINARY
    echo "----------- cd ~/_REPOS_/elm/"
    cd ~/_REPOS_/elm/
    echo "----------- Attempt with options : $COMPILE_OPTIONS" ;
    find $ELM_PLATFORM_DIR | grep '.cabal$' | xargs -n 1 sudo sed -i "s/-threaded -O2 -W \".+\"/-threaded -O2 -W \"-with-rtsopts=$i\"/" ;
    sudo rg '\-threaded -O2 -W ' $ELM_PLATFORM_DIR ;
    echo "----------- Compile $COMPILE_OPTIONS" ;
    docker exec flamboyant_hypatia runhaskell /opt/elm/BuildFromSource.hs 0.18 ;
    echo "----------- copy backup" ;
    echo $i " --> " $COMPILE_OPTIONS
    cp -v $ELM_MAKE_BINARY ./elm-make.$COMPILE_OPTIONS ;
    echo "----------- cd ~/_REPOS_/elm-css/"
    cd $ELM_CSS_DIR
    echo "----------- Clean artifacts" ;
    rm -rf $ELM_CSS_DIR/elm-stuff/build-artifacts ;
    echo "----------- perf with one core" ;
    perf stat sysconfcpus -n 1 $ELM_MAKE_BINARY &> make.$COMPILE_OPTIONS.onecore.perf ; 
    echo "----------- Clean artifacts again" ;
    rm -rf $ELM_CSS_DIR/elm-stuff/build-artifacts ;
    echo "----------- perf with all cores" ;
    perf stat $ELM_MAKE_BINARY &> make.$COMPILE_OPTIONS.multicore.perf ;
    echo "done"
done

