#!/bin/bash

echo ""
echo "Avustaja"
echo ""
echo "Skripti, jonka avulla mahdollista päivittää mm. sovelluksen npm riippuvuudet yms,"
echo "ilman, että täytyy itse näpytellä samoja komentoja moneen kertaan."
echo ""
echo "Tarkoitettu vain helpottamaan työtä, jos et ole varma, mitä tämä skripti tekee"
echo ", on ehkä parempi, että ajat komennot itse yksi kerrallaan, että opit työvaiheet"
echo "jolloin voit tarvittaessa tehdä nämä eri työvaiheet ilman tätä skriptiäkin."
echo ""
echo "Käyttö omalla vastuulla ;)"
echo ""
echo ""
echo "1. Asenna npm paketit/riippuvuudet"
echo "2. Hae uusin versio githubista, asenna npm paketit/riippuvuudet ja luo uusi branch"
echo "3. Kloonaa projekti ja asenna npm paketit/riippuvuudet"
read -p "Valitse: " toiminto

echo "Valitsit $toiminto"

if [[ "$toiminto" == "1" ]]; then
      echo "Valitsit toiminnon 1"
      mkdir -p Kierratysavustin
      cd Kierratysavustin
      cd client
      echo "Asennetaan clientin npm riippuvuudet"
      npm install
      cd ..
      cd server
      echo "Asennetaan serverin npm riippuvuudet"
      npm install
      cd ..
      echo "DONE!"
  fi

if [[ "$toiminto" == "2" ]]; then
      echo "Valitsit toiminnon 2"
      mkdir -p Kierratysavustin
      cd Kierratysavustin
      echo "Muutetaan lokaalin repositorion tila vastaamaan githubissa olevan repositorion tilaa"
      git checkout main
      git fetch origin
      git reset --hard origin/main
      echo "Asennetaan clientin npm riippuvuudet"
      cd client
      npm install
      cd ..
      cd server
      echo "Asennetaan serverin npm riippuvuudet"
      npm install
      cd ..
      echo "Luodaan uusi feature branch"
      read -p "Uuden feature branchin nimi: " ominaisuus
      git checkout -b $ominaisuus
      echo "DONE!"
  fi

if [[ "$toiminto" == "3" ]]; then
      echo "Valitsit toiminnon 3"
      echo "Kloonataan projekti"
      git clone git@github.com:ohtuprojekti-Kierratysavustin/Kierratysavustin.git
      cd Kierratysavustin
      cd client
      echo "Asennetaan clientin npm riippuvuudet"
      npm install
      cd ..
      cd server
      echo "Asennetaan clientin npm riippuvuudet"
      npm install
      cd ..
      echo "DONE!"
  fi
