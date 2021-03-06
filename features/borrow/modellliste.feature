# language: de

Funktionalität: Modellliste

  Um Modelle zu bestellen
  möchte ich als Kunde
  die Möglichkeit haben Modelle zu finden

  Szenario: Modelllistenübersicht
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann sieht man die Explorative Suche
    Und man sieht die Modelle der ausgewählten Kategorie
    Und man sieht Sortiermöglichkeiten
    Und man sieht die Gerätepark-Auswahl
    Und man sieht die Einschränkungsmöglichkeit eines Ausleihzeitraums

  Szenario: Ein einzelner Modelllisteneintrag
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und einen einzelner Modelleintrag beinhaltet
    | Bild                 |
    | Modellname           |
    | Herstellname         |
    | Auswahl-Schaltfläche |

  @javascript
  Szenario: Modellliste scrollen
    Angenommen man ist "Normin"
    Und man sieht eine Modellliste die gescroll werden muss
    Wenn bis ans ende der bereits geladenen Modelle fährt
    Dann wird der nächste Block an Modellen geladen und angezeigt
    Wenn man bis zum Ende der Liste fährt
    Dann wurden alle Modelle der ausgewählten Kategorie geladen und angezeigt

  @javascript
  Szenario: Modellliste sortieren
    Angenommen man ist "Normin"
    Und man sich auf der Modellliste befindet
    Wenn man die Liste nach "Modellname (alphabetisch aufsteigend)" sortiert
    Dann ist die Liste nach "Modellname" "(alphabetisch aufsteigend)" sortiert
    Wenn man die Liste nach "Modellname (alphabetisch absteigend)" sortiert
    Dann ist die Liste nach "Modellname" "(alphabetisch absteigend)" sortiert
    Wenn man die Liste nach "Herstellername (alphabetisch aufsteigend)" sortiert
    Dann ist die Liste nach "Herstellername" "(alphabetisch aufsteigend)" sortiert
    Wenn man die Liste nach "Herstellername (alphabetisch absteigend)" sortiert
    Dann ist die Liste nach "Herstellername" "(alphabetisch absteigend)" sortiert

  Szenario: Ausleihezeitraum Standarteinstellung
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Dann ist kein Ausleihzeitraum ausgewählt
