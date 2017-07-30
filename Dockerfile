FROM haskell:7.10

WORKDIR /opt/elm

RUN apt-get update
RUN apt-get install -y git

COPY ./BuildFromSource.hs ./

CMD ls -lah
