program BlancoYNegro;

uses
  SysUtils, FPImage, FPReadPNG, FPWritePNG, Classes;

type
  TArregloPixeles = array of array of record
    Rojo, Verde, Azul: Byte;
  end;

// función para determinar si un pixel pertenece a una nube o no
function EsNube(Rojo, Verde, Azul: Byte): Boolean;
var
  Resultado: Boolean;
begin
  // las nubes deben tener valores RGB altos, y las diferencias de color deben ser pequeñas
  Resultado := (Rojo > 210) and (Verde > 210) and (Azul > 210) and
               (Abs(Rojo - Verde) < 30) and (Abs(Verde - Azul) < 30);
  EsNube := Resultado;
end;

procedure ConvertirImagen(const NombreEntrada, NombreSalida: String);
var
  Imagen: TFPMemoryImage;
  LectorImagen: TFPCustomImageReader;
  EscritorImagen: TFPWriterPNG;
  Columna, Fila: Integer;
  ColorPixel: TFPColor;
  Blanco, Negro: TFPColor;
  EsTransparente: Boolean;
begin
  // inicializamos la imagen, el lector y el escritor
  Imagen := TFPMemoryImage.Create(0, 0);
  LectorImagen := TFPReaderPNG.Create;
  EscritorImagen := TFPWriterPNG.Create;

  // establecemos los colores Blanco y Negro
  Blanco.Red := $FFFF; Blanco.Green := $FFFF; Blanco.Blue := $FFFF; Blanco.Alpha := 255;
  Negro.Red := 0; Negro.Green := 0; Negro.Blue := 0; Negro.Alpha := 255;

  // cargamos la imagen
  Imagen.LoadFromFile(NombreEntrada, LectorImagen);
  Imagen.UsePalette := False;

  // iniciamos el proceso de conversión
  for Fila := 0 to Imagen.Height - 1 do
    for Columna := 0 to Imagen.Width - 1 do
    begin
      ColorPixel := Imagen.Colors[Columna, Fila];
      EsTransparente := ColorPixel.Alpha = 0;
      if not EsTransparente then   // si el pixel no es transparente, lo modificamos. si lo es, así se queda
        if EsNube(ColorPixel.Red shr 8, ColorPixel.Green shr 8, ColorPixel.Blue shr 8) then
          Imagen.Colors[Columna, Fila] := Blanco  // cambiando a Blanco si es nube
        else
          Imagen.Colors[Columna, Fila] := Negro; // cambiando a Negro si es cielo
    end;

  // guardamos la imagen convertida
  Imagen.SaveToFile(NombreSalida, EscritorImagen);
  WriteLn('Conversión completada. Guardando imagen como ', NombreSalida);

  // liberamos recursos
  LectorImagen.Free;
  EscritorImagen.Free;
  Imagen.Free;
end;

begin
  // llamamos la función con las direcciones de la imagen de entrada y la de salida
  ConvertirImagen('../Imagenes/11838-clean.png', '../Imagenes/11838-clean-convertido.png');
end.
s
