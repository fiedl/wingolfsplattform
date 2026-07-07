# Wingolfsplattform

Dies ist der Quellcode der Mitgliederplattform des Erlanger Wingolfs. Sie erfüllt fünf Hauptaufgaben: Hilfestellung bei der Verwaltung der Mitglieder, Netzwerk der Mitglieder, Austausch von Informationen und Dokumenten, Bereitstellung verlässlicher Kommunikationskanäle und Präsentation nach außen.

## Mitarbeit

Die Wingolfsplattform ist ein Produkt vieler ehrenamtlicher Mitwirkender. Wenn Du Interesse hast, das Projekt bei der Konzeption, als Entwickler, Designer, Tester oder auch finanziell zu unterstützen, melde Dich einfach!

## Installation der Entwicklungsumgebung

Die Wingolfsplattform basiert serverseitig auf [Ruby on Rails](http://rubyonrails.org/), clientseitig auf [Vue.js](https://vuejs.org).

Auf einer Entwicklungsmaschine mit [Docker](https://www.docker.com) installierst Du die Entwicklungsversion der Wingolfsplattform wie folgt:

```bash
git clone git@github.com:fiedl/wingolfsplattform.git
cd wingolfsplattform
docker compose build
```

Die frühere your_platform-Engine ist seit 2026 Teil dieses Repositories
(Verzeichnis `your_platform/`) und muss nicht mehr separat geklont werden.

Falls Du die Umgebung alternativ lieber großteils ohne Docker installieren möchtest, guck Dir am Besten unseren alten [Getting-Started-Guide](https://github.com/fiedl/wingolfsplattform/wiki/Getting-Started) an.

### Umgebungsvariablen

Die Datenbank- und Secrets-Konfiguration (`config/database.yml`,
`config/secrets.yml`) ist eingecheckt und liest die Umgebung. Für die
dockerisierte Entwicklung funktionieren die Standardwerte ohne weiteres
Zutun. Zum Übersteuern legst Du eine `.env`-Datei im Projektverzeichnis
an, die docker compose automatisch lädt und die nicht eingecheckt wird:

```dotenv
# .env — Beispiel; alle Einträge sind optional
RAILS_ENV=development
RAILS_PORT=3000

# Datenbank (Standard: das dockerisierte MySQL aus docker-compose.yml)
#DB_HOST=mysql
#DB_PORT=3306
#DB_NAME=wingolfsplattform_development
#DB_USERNAME=root
#DB_PASSWORD=secret

# Secrets (Standard: bekannte Entwicklungs-Dummywerte)
#SECRET_KEY_BASE=
#SECRET_TOKEN=
#SMTP_USER=wingolfsplattform@wingolf.io
#SMTP_PASSWORD=
#SSO_SECRET=
```

In production kommen sämtliche echten Werte ausschließlich aus der
Umgebung; das Repository enthält keine Produktionsgeheimnisse.

### Web-Oberfläche

Starte die Web-Oberfläche mit

```bash
bin/dev
```

und rufe danach http://localhost:3000 auf. Das Skript startet sich
selbst im Docker-Container neu, bereitet beim ersten Lauf die Umgebung
vor (Javascript-Module, Datenbank — siehe `bin/setup.rb`), startet den
webpack-dev-server für das Entwicklungs-Javascript (Port 9000) und den
Rails-Server. Alternativ: `docker compose up web`.

### Konsole

Mit der Rails-Konsole kannst Du auch ohne Web-Oberfläche auf alles zugreifen:

```bash
bin/rails console
```

Alle `bin/`-Wrapper funktionieren sowohl vom Host als auch im Container:
Auf dem Host starten sie sich selbst über `bin/docker_wrapper.rb` im
passenden Compose-Service neu.

### Tests

Es gibt zwei Spec-Bäume — `spec/` für die App und `your_platform/spec/`
für die Engine. Beide laufen gegen dieselbe Anwendung und verwenden
dieselbe Spec-Konfiguration (`spec/spec_helper.rb`), sodass sie in einem
Aufruf kombiniert werden können.

Für die Entwicklung gibt es `bin/rspec`. Das Skript startet sich selbst
im Docker-Container neu (`bin/docker_wrapper.rb`), bereitet die Umgebung
vor (Javascript-Module, Test-Datenbank; höchstens einmal täglich, siehe
`bin/setup.rb`) und reicht die Argumente an rspec durch:

```bash
bin/rspec spec/models/user_spec.rb
bin/rspec spec/models your_platform/spec/models
bin/rspec your_platform/spec/features/events_spec.rb
```

Die CI verwendet stattdessen `bin/rspec_ci`. Dieser Wrapper baut bei Bedarf
das Docker-Image, legt die Test-Datenbank an und wiederholt fehlgeschlagene
Beispiele bis zu dreimal:

```bash
bin/rspec_ci spec/models your_platform/spec/models   # alle Model-Specs
bin/rspec_ci your_platform/spec/features             # Engine-Feature-Specs (Browser)
```

Die Specs laufen dabei seriell; Parallelität entsteht durch die Aufteilung
der CI-Matrix auf mehrere Runner.

Manuell, ohne Wrapper:

```bash
docker compose run --rm tests bash -c "bundle exec rails db:create db:schema:load"
docker compose run --rm tests bash -c "bundle exec rspec spec/models your_platform/spec/models"
```

Auch `cd your_platform && rspec spec/models` funktioniert weiterhin — der
dortige `spec_helper` ist ein Verweis auf den gemeinsamen.

Die CI (`.github/workflows/tests.yml`) führt auf selbst-gehosteten Runnern
dieselben `bin/rspec_ci`-Aufrufe als Job-Matrix aus. Bekannte, noch offene
Baustellen sind als `pending` mit Verweis auf ihr GitHub-Issue markiert;
die Suite muss grün sein ("no new failures" genügt nicht).

Während der Entwicklung kannst Du auch [guard](https://github.com/guard/guard) laufen lassen. Dieses Tool lässt, wenn Du Code-Dateien veränderst, immer die passenden Tests laufen.

```bash
docker compose run guard
```

### Security

Bitte macht euch mit dem [Rails-Security-Guide](http://guides.rubyonrails.org/security.html) vertraut. Kontrolliert euren Code bitte außerdem mit [`brakeman`](https://github.com/presidentbeef/brakeman).

### Datenbank

Datenbank in eine SQL-Datei exportieren:

```bash
docker compose run --rm web bundle exec ruby script/dump
```

Dies erzeugt eine SQL-Datei mit Zeitstempel im Verzeichnis `backups/sql_dumps`.

SQL-Datei importieren:

```bash
docker compose run --rm -T web bash -c "mysql -h mysql -u root --password=secret -D wingolfsplattform_development" < /path/to/sql/file.sql
```


## Screencasts

* [Plattform-Podcast, Ep. #1](https://plattformpodcast.com/1)
* [Was kann die Plattform?](https://youtu.be/xAiQo1wOq5Y)
* [Wie sende ich eine Semesterstatistik an den Vorort?](https://youtu.be/BeqTjedVP8Y)
* [Wie abonniere ich meinen Veranstaltungskalender?](https://youtu.be/ryHnG9fsglg)
* [Wie trage ich ein Semesterprogramm ein?](https://youtu.be/wmP_4n0SGpM)
* [Wie binde ich Veranstaltungen auf einer öffentlichen Homepage ein?](https://youtu.be/4wAdcpLiAfE)
* [Wie erstelle ich eine Amtsträger-Obergruppe?](https://youtu.be/AjROKOdXA8M)
* Weitere Screencasts: https://plattformpodcast.com

## Weiterführende Informationen

* [Trello Board "AK Internet: Entwicklung"](https://trello.com/board/ak-internet-entwicklung/50006d110ad48e941e8496d2)
* YourPlatform-Projekt, https://github.com/fiedl/your_platform


## Urheber, Mitarbeiter und Lizenz

Copyright (c) 2012-2021, Sebastian Fiedlschuster

Mitarbeiter: Jörg Reichardt, Manuel Zerpies, Joachim Back, Willi Helwig, Falk Schimweg, Felix Plapper

Der Quellcode ist unter den Lizenzbestimmungen der [GNU Affero General Public License (AGPL)](AGPL.txt) veröffentlicht. Hiervon sind explizit ausgenommen die Grafiken und Schriftarten in den Verzeichnissen [app/assets/images](app/assets/images) und [app/assets/fonts](app/assets/fonts), die lediglich dem Betrieb der laufenden Primärinstanz dienen.

The Source Code is released under the [GNU Affero General Public License (AGPL)](AGPL.txt). Explicitely excluded are the images and fonts in the directories [app/assets/images](app/assets/images) and [app/assets/fonts](app/assets/fonts), which are only to be used by Wingolf for production.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
[GNU Affero General Public License](AGPL.txt) for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

Vorrangige Sonderbestimmung für den VAW e.V.: Aufgrund des sog. neuen Entwicklungsmodells ist eine Nutzung der Software durch Philister des VAW e.V. ab Commit `c748222315` und später an die finanzielle Vergütung der jeweiligen Entwicklungsarbeit geknüpft.
