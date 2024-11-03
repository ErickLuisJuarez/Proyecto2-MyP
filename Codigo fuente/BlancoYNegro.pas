program BlancoYNegro;

uses
  SysUtils, FPImage, FPReadPNG, FPWritePNG, Classes, Math;

type
  TArregloPixeles = array of array of record
    Rojo, Verde, Azul: Byte;
  end;

// función para determinar si un pixel pertenece a una nube o no
function EsNube(R, G, B: Byte): Boolean;
var
  MaxVal, MinVal: Byte;
  Tono, Saturacion, Brillo: Real;
  Resultado: Boolean;
begin
  MaxVal := Max(Max(R, G), B);
  MinVal := Min(Min(R, G), B);

  // calculamos el grillo
  Brillo := MaxVal / 255.0;

  // Calculamos la saturacion
  if MaxVal = 0 then
    Saturacion := 0
  else
    Saturacion := 1 - (MinVal / MaxVal);

  // Calculamos el tono
  if MaxVal = MinVal then
    Tono := 0
  else if MaxVal = R then
    Tono := 60 * (0 + (G - B) / (MaxVal - MinVal))
  else if MaxVal = G then
    Tono := 60 * (2 + (B - R) / (MaxVal - MinVal))
  else
    Tono := 60 * (4 + (R - G) / (MaxVal - MinVal));
  if Tono < 0 then
    Tono := Tono + 360;

  // Condiciones para detectar pixeles de nubes
  Resultado := (Brillo > 0.8) and (Saturacion < 0.2)
             and not ((Tono >= 200) and (Tono <= 220));
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
  // iniciamos la imagen, el lector y el escritor
  Imagen := TFPMemoryImage.Create(0, 0);
  LectorImagen := TFPReaderPNG.Create;
  EscritorImagen := TFPWriterPNG.Create;

  // establecemos los colores Blanco y Negro
  Blanco.Red := $FFFF; Blanco.Green := $FFFF; Blanco.Blue := $FFFF;
  Negro.Red := 0; Negro.Green := 0; Negro.Blue := 0;

  // cargamos la imagen
  Imagen.LoadFromFile(NombreEntrada, LectorImagen);
  Imagen.UsePalette := False;

  // comenzamos el proceso de conversión
  for Fila := 0 to Imagen.Height - 1 do
    for Columna := 0 to Imagen.Width - 1 do
    begin
      ColorPixel := Imagen.Colors[Columna, Fila];
      EsTransparente := ColorPixel.Alpha = 0;
      if not EsTransparente then   // si el pixel no es transparente, lo modificamos. si lo es, así se queda
        // determinamos si el pixel actual es una nube
        if EsNube(ColorPixel.Red shr 8, ColorPixel.Green shr 8, ColorPixel.Blue shr 8) then
          Imagen.Colors[Columna, Fila] := Blanco  // si lo es, lo convertimos a blanco
        else
          Imagen.Colors[Columna, Fila] := Negro; // y si no, a negro
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