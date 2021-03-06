# language: de

Funktionalität: Passwörter von Benutzern

  Als Ausleihe-Verwalter, Inventar-Verwalter oder Administrator,
  möchte ich eine Benutzer ein Login und Passwort zuteilen

  @javascript
  Szenariogrundriss: Benutzer mit Benutzernamen und Passwort erstellen
    Angenommen man ist "<Person>"
    Und man befindet sich auf der Benutzerliste
    Wenn ich einen Benutzer mit Login "username" und Passwort "password" erstellt habe
    Und der Benutzer hat Zugriff auf ein Inventarpool
    Dann kann sich der Benutzer "username" mit "password" anmelden

    Beispiele:
      | Person |
      | Mike   |
      | Pius   |
      | Gino   |
