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

ELM_MAKE_BINARY=~/_REPOS_/elm/Elm-Platform/0.18/elm-make/dist/dist-sandbox-aff3f82/build/elm-make/elm-make

ELM_PLATFORM_DIR=~/_REPOS_/elm/Elm-Platform

## now loop through the above array
for i in "${arr[@]}"
do
    ATTEMPT=$(echo $i | sed -e 's/\s/_/g')
    echo "----------- removing existing binary" ;
    rm -v $ELM_MAKE_BINARY
    echo "----------- cd ~/_REPOS_/elm/"
    cd ~/_REPOS_/elm/
    echo "----------- Attempt : $ATTEMPT" ;
    find $ELM_PLATFORM_DIR | rg '.cabal$' | xargs -n 1 sudo sed -i "s/-threaded -O2 -W \".+\"/-threaded -O2 -W \"-with-rtsopts=$i\"/" ;
    sudo rg '\-threaded -O2 -W ' $ELM_PLATFORM_DIR ;
    echo "----------- Compile $ATTEMPT" ;
    docker exec flamboyant_hypatia runhaskell /opt/elm/BuildFromSource.hs 0.18 ;
    echo "----------- copy backup" ;
    echo $i " --> " $ATTEMPT
    cp -v $ELM_MAKE_BINARY ./elm-make.$ATTEMPT ;
    echo "----------- cd ~/_REPOS_/elm-css/"
    cd ~/_REPOS_/elm-css/
    echo "----------- Clean artifacts" ;
    rm -rf ~/_REPOS_/elm-css/elm-stuff/build-artifacts ;
    echo "----------- perf with one core" ;
    perf stat sysconfcpus -n 1 $ELM_MAKE_BINARY &> make.$ATTEMPT.onecore.perf ; 
    echo "----------- Clean artifacts again" ;
    rm -rf ~/_REPOS_/elm-css/elm-stuff/build-artifacts ;
    echo "----------- perf with all cores" ;
    perf stat $ELM_MAKE_BINARY &> make.$ATTEMPT.multicore.perf ;
    echo "done"
done

# You can access them using echo "${arr[0]}", "${arr[1]}" also
