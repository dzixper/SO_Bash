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
      read -rsn 1 choice
      if [[ $choice -eq 9 ]]; then
        echo -e "\n`date`\n`$@`" >> $dir/log.txt | 2>&0
        echo 'Zapisano'
      fi
      clear
}
clear
while [[ $option -ne 9 ]]; do
printMenu
clear
  case $option in
    1)
      echo -e 'Podaj absolutna sciezke do katalogu:'
      read dirTemp
      if [[ $dirTemp =~ ^\.+$ ]]; then # w tym miejscu jest duzy potencjal zepsucia dajac sciezke np '/.', ktora nie istnieje, a dziala w skrypcie, ale nie znam wszystkich kombinacji 
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
      echo -e "Lista plikow:\n`fileList`"
      saveLogs fileList
      ;;
    3)
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
      echo -e "Zajetosc dysków:\n`df -Hl`"
      saveLogs df -Hl
      ;;
    5)
      echo 'Zalogowani uzytkownicy:'
      users
      echo 'Podaj uzytkownika, dla ktorego chcesz zobaczyc procesy:'
      read userTemp
      if [[ -z `users | grep $userTemp 2>/dev/null` ]]; then
        echo 'Nie ma takiego uzytkownika. Sprobuj ponownie'
      else
        ps -u $userTemp
        saveLogs ps -u $userTemp # wiem, ze to nie jest najlepsza metoda, bo logi moga przeklamac sytuacje
      fi
      ;;
    6)
      echo -e 'Wybierz operacje:\n1.Skanowanie zalogowanych uzytkownikow\n2.Zajetosc dysku\n3.Polaczenia sieciowe z wykorzystywana maszyna\n4.Pokaz wykonywane periodyczne operacje\n5.Edytuj recznie wykonywane operacje\n6.Usun wszystkie wykonywane operacje'
      read -sn 1 cronOption
      if [[ $cronOption -ne 4 ]]; then
        echo -e 'Jak czesto chcesz wykonywac dana operacje?\nPodawaj w formacie CRON (wiecej informacji na stronie https://crontab.guru): * * * * *\nMinuta (0-59)/Godzina (0-23)/Dzien miesiaca (1-31)/Miesiac (1-12)/Dzien tygodnia (0-6)'
        read cronParams
      fi
      cronLogs() {
        echo "$cronParams $@ >> $dir/cronlogs.txt" | crontab
        #\n`date`\n && 
      }
      clear
      case $cronOption in
        1)
          cronLogs users
          echo 'Zadanie utworzone!'
          ;;
        2)
          cronLogs df -Hl
          echo 'Zadanie utworzone!'
          ;;
        3)
          cronLogs netstat
          echo 'Zadanie utworzone!'
          ;;
        4)
          crontab -l
          ;;
        5)
          crontab -e
          ;;
        6)
          crontab -r
          ;;
        *)
          clear
          echo 'Opcja nie istnieje. Sprobuj ponownie.'
          ;;
      esac
      ;;
    9)
      echo 'Do zobaczenia!'
      ;;
    *) # udaje sie wykrzaczyc skrypt klikajac np. strzalki, wyskakuje wtedy blad
      echo -e 'Opcja nie istnieje. Sprobuj ponownie.\n'
      ;;
  esac
done

