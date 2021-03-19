#!/bin/bash

# Ohtuprojektia varten tehty apuskripti.
# Skripti automatisoi joitain tylsimpiä toistuvia töitä
# , mitä koodin katselmointiin kuuluu.
# Testattu vain Ubuntu matessa

# Avataan terminaalit vasempaan reunaan, muutettava näytön koon mukaisesti...
# mate-terminal --geometry 74x11+0+0
# mate-terminal --geometry 74x11+0+250
# mate-terminal --geometry 74x11+0+500

# Terminaalien avaamisen sijaan voisi myös käynnistää taustalla, esim.
# cd server
# npm run start:test &
# ServerPID=$!
# ...
# kill $ServerPID
# Mutta ei toimi, koska serverin käynnistys näyttää käynnistävän useampia
# prosesseja ja ServerPID=$! saa vain yhden id:n talteen, ja
# kill $ServerPID tuhoaa vain ko. prosessin ja muut jäävät käyntiin taustalle.
# ts. terminaalien avaaminen on yksinkertaisin tapa hoitaa asia ja tällöin myös
# testaamisen kannalta mahdollisesti olennaiset lokit on kokoajan nähtävillä
# terminaaleissa.
#

if [ -d "Kierratysavustin" ]
  then
    echo "Projektista näyttää olevan jo lokaali versio"
    echo "Vaihdetaan main branchiin ja tehdään git pull"
    cd Kierratysavustin
    git checkout main
    retval=$?
    if [[ "$retval" == "0" ]]
      then
        git pull
      else
        echo "Git checkout ei onnistunut! Tarkista, että koodissa ei ole muutoksia"
        echo ", joita ei vielä ole committattu ja yritä uudelleen..."
        echo "Vaihtoehtoisesti voit myös ajaa skriptin jossain kansiossa, jossa"
        echo "ei ole valmiiksi projektia, jolloin se kloonataan uutena"
        exit 1
    fi

  else
    echo "Kloonataan github repo"
    git clone git@github.com:ohtuprojekti-Kierratysavustin/Kierratysavustin.git
    cd Kierratysavustin/
fi


echo "Branchit:"
git branch -r
read -p "Katselmoitavan feature branchin nimi: " ominaisuus
git checkout $ominaisuus
retval=$?
if [[ "$retval" == "0" ]]
  then
    git pull
  else
    echo "Git checkout ei onnistunut! Tarkista, että koodissa ei ole muutoksia"
    echo ", joita ei vielä ole committattu ja yritä uudelleen..."
    echo "Vaihtoehtoisesti voit myös ajaa skriptin jossain kansiossa, jossa"
    echo "ei ole valmiiksi projektia, jolloin se kloonataan uutena"
    exit 1
fi

echo "Asennetaan npm paketit..."
cd client/
npm install
cd ..
cd e2e_tests/
npm install
cd ..
cd server/
npm install
cd ..


echo "Käynnistetään mongo"
if [ ! -f start-mongo-docker.sh ]
  then
    echo "Mongon käynnistyskriptiä ei löydy! Käynnistetään perinteisellä tavalla..."
    cd mongo
    docker-compose up -d
    cd ..
  else
    mate-terminal --geometry 74x11+0+0 -e "./start-mongo-docker.sh"
fi

echo "... odotetaan 30 sekunttia, että mongo varmasti ehtii käynnistyä..."
sleep 30

echo "Ajeteaan serverin jest testit"
cd server
npm run test

echo "Käynnistetään serveri testitilassa"
mate-terminal --geometry 74x11+0+250 -e "bash -c 'npm run start:test'"
# Jos ei oo mate-terminaalia, pitää vaihtaa esim. konsole, gnome-terminal, ...
# Yleisellä tasolla kai ainakin ubuntussa pitäs toimia aina x-terminal-emulator?

echo "... odotetaan 10 sekunttia, että serveri varmasti ehtii käynnistyä..."
sleep 10
cd ..

echo "Ajetaan clientin jest testit"
cd client
CI=true npm run test

echo "Käynnistetään client"
mate-terminal --geometry 74x11+0+500 -e "bash -c 'npm start'"
echo "... odotetaan 45 sekunttia, että client varmasti ehtii käynnistyä..."
sleep 45
cd ..

echo "Ajetaan e2e testit"
cd e2e_tests
npm run test:e2e

echo "Testaile sovellusta lokaalisti, sulje lopuksi avatut terminaalit (CTRL+C)"
echo " ja siirry docker testiin painamalla enter"
read -p ""
cd ..

if [ ! -f start-mongo-docker.sh ]
  then
    echo "Mongon käynnistyskriptiä ei löydy! Sammutetaan perinteisellä tavalla..."
    cd mongo
    docker-compose down
    cd ..
fi

cd mongo

echo "Koska Docker on luonut data-kansiot, niiden poistaminen ei onnistu ilman sudoa..."
sudo rm -rf data

cd ..
cd server
sudo rm -rf data

cd ..
echo "Luodaan ja käynnistetään docker image"
docker build --build-arg PUBLIC_URL=/kierratysavustin -t kierratysavustin-local .
docker-compose up -d
echo ""
echo ""
echo "Sovellus pyörii osoitteessa http://localhost:3001/kierratysavustin"
echo "Sammuta sovellus painamalla Enter"
read -p ""
echo "Sammutetaan docker"
docker-compose down

cd mongo
echo "Koska Docker on luonut data-kansiot, niiden poistaminen ei onnistu ilman sudoa..."
sudo rm -rf data

cd ..
cd server
echo "Koska Docker on luonut data-kansiot, niiden poistaminen ei onnistu ilman sudoa..."
sudo rm -rf data
