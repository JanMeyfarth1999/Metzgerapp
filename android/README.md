# Android-Projekt

Das native, app-spezifische Android-Overlay liegt unter `app/src/main` und in `tool/android_overlay`.
Der Gradle-Wrapper (einschließlich binärer JAR), Gradle-Skripte, Standard-Icons und Styles werden beim ersten Aufruf von `setup.ps1` bzw. `setup.sh` aus **deiner installierten Flutter-Version** generiert. Das verhindert einen fest vorgegebenen inkompatiblen Android-Gradle-Stand. Die Dart-Dateien werden dabei nicht überschrieben.
