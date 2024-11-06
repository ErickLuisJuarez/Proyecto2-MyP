unit BlancoYNegro;

interface

uses
  SysUtils, FPImage, FPReadPNG, FPWritePNG, Classes, Math;

type
  TArregloPixeles = array of array of record
    Rojo, Verde, Azul: Byte;
  end;

function EsNube(R, G, B: Byte): Boolean;
procedure ConvertirImagen(const NombreEntrada, NombreSalida: String);

implementation

function EsNube(R, G, B: Byte): Boolean;
var
  MaxVal, MinVal: Byte;
  Tono, Saturacion, Brillo: Real;
  Resultado: Boolean;
begin
  MaxVal := Max(Max(R, G), B);
  MinVal := Min(Min(R, G), B);

  // Calculamos el brillo
  Brillo := MaxVal / 255.0;

  // Calculamos la saturación
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

  // Condiciones para detectar píxeles de nubes
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
  // Iniciamos la imagen, el lector y el escritor
  Imagen := TFPMemoryImage.Create(0, 0);
  LectorImagen := TFPReaderPNG.Create;
  EscritorImagen := TFPWriterPNG.Create;

  // Establecemos los colores Blanco y Negro
  Blanco.Red := $FFFF; Blanco.Green := $FFFF; Blanco.Blue := $FFFF;
  Negro.Red := 0; Negro.Green := 0; Negro.Blue := 0;

  // Cargamos la imagen
  Imagen.LoadFromFile(NombreEntrada, LectorImagen);
  Imagen.UsePalette := False;

  // Comenzamos el proceso de conversión
  for Fila := 0 to Imagen.Height - 1 do
    for Columna := 0 to Imagen.Width - 1 do
    begin
      ColorPixel := Imagen.Colors[Columna, Fila];
      EsTransparente := ColorPixel.Alpha = 0;
      if not EsTransparente then   // Si el pixel no es transparente, lo modificamos. Si lo es, así se queda
        // Determinamos si el pixel actual es una nube
        if EsNube(ColorPixel.Red shr 8, ColorPixel.Green shr 8, ColorPixel.Blue shr 8) then
          Imagen.Colors[Columna, Fila] := Blanco  // Si lo es, lo convertimos a blanco
        else
          Imagen.Colors[Columna, Fila] := Negro; // Y si no, a negro
    end;

  // Guardamos la imagen convertida
  Imagen.SaveToFile(NombreSalida, EscritorImagen);
  WriteLn('Conversión completada. Guardando imagen como ', NombreSalida);

  // Liberamos recursos
  LectorImagen.Free;
  EscritorImagen.Free;
  Imagen.Free;
end;

end.
