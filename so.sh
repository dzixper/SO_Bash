#!/bin/bash
dir=`pwd`
printMenu() {
  echo -e "\n>$dir\n\n1.Ustaw katalog roboczy\n2.Wyswietl pliki w katalogu roboczym\n3.Odczytaj plik z katalogu roboczego\n4.Wyswietl zajetosc dysku\n5.Sprawdz uruchomione procesy\n6.Wykonaj periodyczne operacje\n9.Wyjscie"
  read -sn 1 option
}
fileList() {
  ls -l $dir | tr -s ' ' | cut -d ' ' -f 9 | tail -n+2
}
saveLogs() {
  echo -e 'Jezeli chcesz zapisac wynik do logow, wcisnij 9.\nJezeli chcesz kontynuwac, wcisnij dowolny inny klawisz'
      read -sn 1 choice
      if [[ $choice -eq 9 ]]; then
        echo -e "\n`date`\n`$@`" >> $dir/log.txt | 2>&0
        echo 'Zapisano'
      fi
}
while [[ $option -ne 9 ]]; do
printMenu
  case $option in
    1)
      clear
      echo -e 'Podaj absolutna sciezke do katalogu:'
      read dirTemp
      #mialo byc od razu czytanie w if, ale nie dziala
      if [[ $dirTemp =~ ^\.+$ ]]; then
        clear
        echo 'Nie psuj!!'
      elif [[ -d $dirTemp  ]]; then
        dir=$dirTemp
      else
        clear
        echo 'Podany katalog nie istnieje lub sciezka jest nieprawidlowa. Sprobuj ponownie.'
      fi
      ;;
    2)
      clear
      echo -e "Lista plikow:\n`fileList`"
      saveLogs fileList
      ;;
    3)
      clear
      ls
      echo -e 'Podaj nazwe pliku do odczytania:'
      read fileTemp
      if [[ -f $fileTemp ]]; then
        clear
        cat $fileTemp
        saveLogs
      else
        echo -e 'Nie ma takiego pliku. Sprobuj ponownie.'
      fi
      ;;
    4)
      clear
      echo -e "Zajetosc dysków:\n`df -Hl`"
      saveLogs df -Hl
      ;;
    5)
      clear
      echo -e 'Zalogowani uzytkownicy:'
      users
      echo -e 'Podaj uzytkownika, dla ktorego chcesz zobaczyc procesy:'
      read userTemp
      if [[ -z `users | grep $userTemp` ]]; then
        echo 'Nie ma takiego uzytkownika. Sprobuj ponownie'
      else
        ps -u $userTemp
      fi
      ;;
    9)
      clear
      echo 'Do zobaczenia!'
      ;;
    *)
      clear
      echo -e 'Opcja nie istnieje. Sprobuj ponownie.\n'
      ;;
  esac
done

