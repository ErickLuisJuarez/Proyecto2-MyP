Proyecto2-MYP Cobertura nubosa
Este proyecto calcula el Índice de Cobertura Nubosa (CCI) a partir de imágenes en formato JPEG, representando la proporción de cielo cubierto por nubes en cada imagen.

#Requisitos:
Tener instalado Free Pascal

#Instalación:
Para instalar Free Pascal en tu sistema, sigue estos pasos:

En Debian/Ubuntu:
sudo apt update
sudo apt install fpc

En macOS (usando Homebrew):
brew install fpc

En Windows:
Descarga el instalador desde el sitio oficial de Free Pascal: https://www.freepascal.org/download.html

#Uso: Para ejecutar el codigo sigue los siguientes pasos: 1.- Dirigete a la carpeta Codigo fuente con cd Codigo\ fuente/
2.-Compila el programa principal con: fpc Programa.pas

Ejecuta el programa con la opción -s (si aplica) para segmentar la imagen en blanco y negro con: ./Programa -s

Despues de ejecutarse aparece el indice de cobertura nubosa en la terminal y además en la carpeta imagenes se generará la imagen convertida a blanco y negro con el nombre de "11838_final.png"

#Tests: Para ejecutar el codigo sigue los siguientes pasos: 1.- Dirigete a la carpeta Codigo fuente con cd Codigo\ fuente/
Compila las pruebas unitarias con: fpc PruebaPrograma.pas

Ejecuta las pruebas unitarias con: ./PruebaPrograma


#Integrantes del equipo y sus roles:
Líder del equipo: Diego Eduardo Peña Villega
Backend: Luis Juárez Erick, Diego Eduardo Peña Villegas, Brenda Rodríguez Jiménez, Oscar Iván Sánchez González, Tomás Barrera Hernández
